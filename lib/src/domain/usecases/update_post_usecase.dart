import '../entities/media_attachment.dart';
import '../repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;
  UpdatePostUseCase(this.repository);

  Future<void> call(
    String postId,
    String content, {
    String? type,
    List<String> existingMediaIds = const [],
    List<MediaAttachment> newMedia = const [],
  }) =>
      repository.updatePost(
        postId,
        content,
        type: type,
        existingMediaIds: existingMediaIds,
        newMedia: newMedia,
      );
}
