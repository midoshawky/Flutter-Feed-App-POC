import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import 'feed_providers.dart';
import 'di_providers.dart';

final optimisticFeedProvider =
    NotifierProvider<OptimisticFeedNotifier, AsyncValue<List<PostEntity>>>(() {
  return OptimisticFeedNotifier();
});

class OptimisticFeedNotifier
    extends Notifier<AsyncValue<List<PostEntity>>> {
  @override
  AsyncValue<List<PostEntity>> build() {
    return ref.watch(feedStreamProvider);
  }

  /// Create a new post — optimistically prepends it, then refreshes from server.
  Future<void> createPost({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<Uint8List> mediaBytes = const [],
  }) async {
    final oldState = state;
    final currentPosts = state.value ?? [];

    final resolvedType = mediaBytes.length == 1
        ? PostTypeEntity.image
        : mediaBytes.length > 1
            ? PostTypeEntity.multiImage
            : type;

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
            mediaBytes: mediaBytes,
          );
      // Replace optimistic post with real server data (no loading state emitted).
      final freshPosts =
          await ref.read(getFeedUseCaseProvider).call().first;
      state = AsyncValue.data(freshPosts);
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
      await ref.read(addCommentUseCaseProvider).call(postId, comment);
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
      await ref.read(addReplyUseCaseProvider).call(
            postId: postId,
            parentCommentId: parentCommentId,
            reply: reply,
          );
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
      // Refresh to replace the pending repost with the real one from server.
      final freshPosts =
          await ref.read(getFeedUseCaseProvider).call().first;
      state = AsyncValue.data(freshPosts);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  /// Optimistically update a post
  Future<void> updatePost(String postId, String content) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId) post.copyWith(content: content) else post,
    ]);

    try {
      await ref.read(updatePostUseCaseProvider).call(postId, content);
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

  /// Re-fetch the feed from the server
  Future<void> refresh() async {
    ref.invalidate(feedStreamProvider);
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
                  user: post.repostedFrom?.user?.copyWith(isFollowing: !isFollowing),
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
