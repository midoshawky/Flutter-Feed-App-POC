import 'dart:typed_data';
import '../repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;
  UpdatePostUseCase(this.repository);

  Future<void> call(
    String postId,
    String content, {
    String? type,
    List<String> existingMediaIds = const [],
    List<Uint8List> newMediaBytes = const [],
  }) =>
      repository.updatePost(
        postId,
        content,
        type: type,
        existingMediaIds: existingMediaIds,
        newMediaBytes: newMediaBytes,
      );
}
