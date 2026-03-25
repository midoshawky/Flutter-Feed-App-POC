import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/mock_data_service.dart';

final feedProvider = NotifierProvider<FeedNotifier, List<Post>>(() {
  return FeedNotifier();
});

class FeedNotifier extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    return MockDataService.posts;
  }

  void toggleLike(String postId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            likesCount: post.isLiked
                ? post.likesCount - 1
                : post.likesCount + 1,
            isLiked: !post.isLiked,
          )
        else
          post,
    ];
  }

  void addComment(String postId, Comment comment) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(comments: [...post.comments, comment])
        else
          post,
    ];
  }

  void addReply(String postId, String parentCommentId, Comment reply) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            comments: _addReplyToComments(post.comments, parentCommentId, reply),
          )
        else
          post,
    ];
  }

  List<Comment> _addReplyToComments(
    List<Comment> comments,
    String parentId,
    Comment reply,
  ) {
    return [
      for (final c in comments)
        if (c.id == parentId)
          c.copyWith(replies: [...c.replies, reply])
        else
          c.copyWith(replies: _addReplyToComments(c.replies, parentId, reply)),
    ];
  }

  void repost(Post originalPost, String addedText) {
    // Increment the original post's repost count
    state = [
      for (final post in state)
        if (post.id == originalPost.id)
          post.copyWith(repostsCount: post.repostsCount + 1)
        else
          post,
    ];

    // Prepend a new repost to the top of the feed
    final repostEntry = Post(
      userId: MockDataService.users[0].id, // current user
      content: addedText,
      type: PostType.text,
      timestamp: DateTime.now(),
      repostedFrom: originalPost,
    );

    state = [repostEntry, ...state];
  }
}
