import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class RepostUseCase {
  final PostRepository repository;
  RepostUseCase(this.repository);

  Future<void> call({
    required String byUserId,
    required String originalPostId,
    required String addedText,
    required PostEntity originalPost,
  }) =>
      repository.repost(
        byUserId: byUserId,
        originalPostId: originalPostId,
        addedText: addedText,
        originalPost: originalPost,
      );
}
