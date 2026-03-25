import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;
  ToggleLikeUseCase(this.repository);

  Future<void> call(String postId, bool currentlyLiked) =>
      repository.toggleLike(postId, currentlyLiked);
}
