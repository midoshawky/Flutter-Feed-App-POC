import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import 'feed_providers.dart';
import 'di_providers.dart';

final optimisticFeedProvider = NotifierProvider<OptimisticFeedNotifier, AsyncValue<List<PostEntity>>>(() {
  return OptimisticFeedNotifier();
});

class OptimisticFeedNotifier extends Notifier<AsyncValue<List<PostEntity>>> {
  @override
  AsyncValue<List<PostEntity>> build() {
    return ref.watch(feedStreamProvider);
  }

  /// Optimistically toggle like
  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    // 1. Update local state immediately
    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            likesCount: currentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
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

  /// Optimistically adds a reply
  Future<void> addReply(String postId, String parentCommentId, CommentEntity reply) async {
    final oldState = state;
    final currentPosts = state.value;
    if (currentPosts == null) return;

    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            comments: _addReplyToComments(post.comments, parentCommentId, reply),
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
          c.copyWith(replies: _addReplyToComments(c.replies, parentId, reply)),
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
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }
}
