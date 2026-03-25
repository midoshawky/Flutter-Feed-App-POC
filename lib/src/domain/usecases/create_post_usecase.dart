import 'dart:typed_data';
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
    List<Uint8List> mediaBytes = const [],
  }) =>
      repository.createPost(
        userId: userId,
        content: content,
        type: type,
        tags: tags,
        mediaBytes: mediaBytes,
      );
}
