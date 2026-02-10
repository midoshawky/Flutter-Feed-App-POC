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
}
