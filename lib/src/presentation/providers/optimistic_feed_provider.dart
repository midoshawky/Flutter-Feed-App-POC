import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_attachment.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import 'di_providers.dart';

final optimisticFeedProvider =
    NotifierProvider<OptimisticFeedNotifier, AsyncValue<List<PostEntity>>>(() {
  return OptimisticFeedNotifier();
});

class OptimisticFeedNotifier
    extends Notifier<AsyncValue<List<PostEntity>>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final _loadedCommentPostIds = <String>{};
  final _loadingCommentPostIds = <String>{};

  @override
  AsyncValue<List<PostEntity>> build() {
    _loadPage(1);
    return const AsyncValue.loading();
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool isLoadingCommentsForPost(String postId) =>
      _loadingCommentPostIds.contains(postId);

  bool isLoadedCommentsForPost(String postId) =>
      _loadedCommentPostIds.contains(postId);

  Future<void> _loadPage(int page) async {
    try {
      final posts = await ref
          .read(getFeedUseCaseProvider)
          .call(page: page, limit: 10);
      final current = page == 1 ? <PostEntity>[] : (state.value ?? []);
      state = AsyncValue.data([...current, ...posts]);
      _currentPage = page;
      _hasMore = posts.length >= 10;
    } catch (e, s) {
      if (page == 1) state = AsyncValue.error(e, s);
      // On subsequent pages, keep existing data and swallow the error
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    await _loadPage(_currentPage + 1);
    _isLoadingMore = false;
  }

  /// Lazy-load comments for a single post — fetches only once per session.
  Future<void> loadCommentsForPost(String postId) async {
    if (_loadedCommentPostIds.contains(postId)) return;
    _loadingCommentPostIds.add(postId);
    try {
      final comments =
          await ref.read(getPostCommentsUseCaseProvider).call(postId);
      _loadingCommentPostIds.remove(postId);
      _loadedCommentPostIds.add(postId); // mark loaded only after success
      final posts = state.value;
      if (posts == null) return;
      state = AsyncValue.data([
        for (final p in posts)
          if (p.id == postId) p.copyWith(comments: comments) else p,
      ]);
    } catch (_) {
      _loadingCommentPostIds.remove(postId);
      // not added to _loadedCommentPostIds — allows retry on next open
    }
  }

  /// Create a new post — optimistically prepends it, then refreshes from server.
  Future<void> createPost({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<MediaAttachment> media = const [],
  }) async {
    final oldState = state;
    final currentPosts = state.value ?? [];

    final resolvedType = resolvePostType(
      totalMediaCount: media.length,
      hasVideo: media.any((m) => m.isVideo),
    );

    final optimisticPost = PostEntity(
      id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: content,
      type: resolvedType,
      tags: tags,
      timestamp: DateTime.now(),
      likesCount: 0,
      repostsCount: 0,
      comments: [],
      isLiked: false,
    );

    state = AsyncValue.data([optimisticPost, ...currentPosts]);

    try {
      await ref.read(createPostUseCaseProvider).call(
            userId: userId,
            content: content,
            type: type,
            tags: tags,
            media: media,
          );
      _loadedCommentPostIds.clear();
      await _loadPage(1);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically toggle like
  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            likesCount:
                currentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
            isLiked: !currentlyLiked,
          )
        else
          post,
    ]);

    try {
      await ref.read(toggleLikeUseCaseProvider).call(postId, currentlyLiked);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically add a comment
  Future<void> addComment(String postId, CommentEntity comment) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(comments: [...post.comments, comment])
        else
          post,
    ]);

    try {
      final serverComment = await ref.read(addCommentUseCaseProvider).call(postId, comment);
      // Preserve local user data when the API response omits the user object
      final resolved = serverComment.userName.isEmpty
          ? serverComment.copyWith(
              userName: comment.userName,
              userUsername: comment.userUsername,
              userAvatarUrl: comment.userAvatarUrl,
            )
          : serverComment;
      // Use fresh state to avoid losing comments that arrived while awaiting
      final latestPosts = state.value ?? currentPosts;
      state = AsyncValue.data([
        for (final post in latestPosts)
          if (post.id == postId)
            post.copyWith(
              comments: [
                for (final c in post.comments)
                  if (c.id == comment.id) resolved else c,
                // If optimistic comment was already removed (edge case), append
                if (!post.comments.any((c) => c.id == comment.id)) resolved,
              ],
            )
          else
            post,
      ]);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically add a reply
  Future<void> addReply(
      String postId, String parentCommentId, CommentEntity reply) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            comments:
                _addReplyToComments(post.comments, parentCommentId, reply),
          )
        else
          post,
    ]);

    try {
      final serverReply = await ref.read(addReplyUseCaseProvider).call(
            postId: postId,
            parentCommentId: parentCommentId,
            reply: reply,
          );
      // Preserve local user data when the API response omits the user object
      final resolved = serverReply.userName.isEmpty
          ? serverReply.copyWith(
              userName: reply.userName,
              userUsername: reply.userUsername,
              userAvatarUrl: reply.userAvatarUrl,
            )
          : serverReply;
      final latestPosts = state.value ?? currentPosts;
      state = AsyncValue.data([
        for (final post in latestPosts)
          if (post.id == postId)
            post.copyWith(
              comments: _replaceReplyInComments(post.comments, reply.id, resolved),
            )
          else
            post,
      ]);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  List<CommentEntity> _addReplyToComments(
    List<CommentEntity> comments,
    String parentId,
    CommentEntity reply,
  ) {
    return [
      for (final c in comments)
        if (c.id == parentId)
          c.copyWith(replies: [...c.replies, reply])
        else
          c.copyWith(
              replies: _addReplyToComments(c.replies, parentId, reply)),
    ];
  }

  List<CommentEntity> _replaceReplyInComments(
    List<CommentEntity> comments,
    String targetId,
    CommentEntity replacement,
  ) {
    return [
      for (final c in comments)
        if (c.id == targetId)
          replacement
        else
          c.copyWith(
              replies: _replaceReplyInComments(c.replies, targetId, replacement)),
    ];
  }

  /// Optimistically repost
  Future<void> repost({
    required String byUserId,
    required String originalPostId,
    required String addedText,
    required PostEntity originalPost,
  }) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    final optimisticRepost = PostEntity(
      id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
      userId: byUserId,
      content: addedText,
      type: PostTypeEntity.text,
      timestamp: DateTime.now(),
      repostedFrom: originalPost,
      likesCount: 0,
      repostsCount: 0,
      comments: [],
      isLiked: false,
    );

    state = AsyncValue.data([
      optimisticRepost,
      for (final post in currentPosts)
        if (post.id == originalPostId)
          post.copyWith(repostsCount: post.repostsCount + 1)
        else
          post,
    ]);

    try {
      await ref.read(repostUseCaseProvider).call(
            byUserId: byUserId,
            originalPostId: originalPostId,
            addedText: addedText,
            originalPost: originalPost,
          );
      _loadedCommentPostIds.clear();
      await _loadPage(1);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically update a post
  Future<void> updatePost(
    String postId,
    String content, {
    String? type,
    List<String> existingMediaIds = const [],
    List<MediaAttachment> newMedia = const [],
  }) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId) post.copyWith(content: content) else post,
    ]);

    try {
      await ref.read(updatePostUseCaseProvider).call(
            postId,
            content,
            type: type,
            existingMediaIds: existingMediaIds,
            newMedia: newMedia,
          );
      _loadedCommentPostIds.clear();
      await _loadPage(1);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically delete a post
  Future<void> deletePost(String postId) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data(
      currentPosts.where((post) => post.id != postId).toList(),
    );

    try {
      await ref.read(deletePostUseCaseProvider).call(postId);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically delete a comment (or reply) from a post
  Future<void> deleteComment(String postId, String commentId) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            comments: _removeComment(post.comments, commentId),
          )
        else
          post,
    ]);

    try {
      await ref.read(deleteCommentUseCaseProvider).call(commentId);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  List<CommentEntity> _removeComment(
    List<CommentEntity> comments,
    String commentId,
  ) {
    return [
      for (final c in comments)
        if (c.id != commentId)
          c.copyWith(replies: _removeComment(c.replies, commentId)),
    ];
  }

  /// Optimistically update a comment's text (works for replies too)
  Future<void> updateComment(
      String postId, String commentId, String newText) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            comments: _updateCommentText(post.comments, commentId, newText),
          )
        else
          post,
    ]);

    try {
      await ref.read(updateCommentUseCaseProvider).call(commentId, newText);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  List<CommentEntity> _updateCommentText(
    List<CommentEntity> comments,
    String commentId,
    String newText,
  ) {
    return [
      for (final c in comments)
        if (c.id == commentId)
          c.copyWith(text: newText)
        else
          c.copyWith(
              replies: _updateCommentText(c.replies, commentId, newText)),
    ];
  }

  /// Re-fetch the feed from page 1
  Future<void> refresh() async {
    _loadedCommentPostIds.clear();
    _loadingCommentPostIds.clear();
    state = const AsyncValue.loading();
    await _loadPage(1);
  }

  /// Optimistically toggle follow
  Future<void> toggleFollow(String userId, bool isFollowing) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        post.copyWith(
          user: post.user?.id == userId
              ? post.user?.copyWith(isFollowing: !isFollowing)
              : post.user,
          repostedFrom: post.repostedFrom?.user?.id == userId
              ? post.repostedFrom?.copyWith(
                  user: post.repostedFrom?.user
                      ?.copyWith(isFollowing: !isFollowing),
                )
              : post.repostedFrom,
        ),
    ]);

    try {
      await ref.read(followUserUseCaseProvider).call(userId, isFollowing);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }
}
