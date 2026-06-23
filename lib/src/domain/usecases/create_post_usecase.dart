import '../entities/media_attachment.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;
  CreatePostUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<MediaAttachment> media = const [],
  }) =>
      repository.createPost(
        userId: userId,
        content: content,
        type: type,
        tags: tags,
        media: media,
      );
}
