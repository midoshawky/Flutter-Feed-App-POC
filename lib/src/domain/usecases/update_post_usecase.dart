import '../repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;
  UpdatePostUseCase(this.repository);

  Future<void> call(String postId, String content, {String? type}) =>
      repository.updatePost(postId, content, type: type);
}
