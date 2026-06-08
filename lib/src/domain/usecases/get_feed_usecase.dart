import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetFeedUseCase {
  final PostRepository repository;
  GetFeedUseCase(this.repository);

  Future<List<PostEntity>> call({int page = 1, int limit = 10}) =>
      repository.getFeed(page: page, limit: limit);
}
