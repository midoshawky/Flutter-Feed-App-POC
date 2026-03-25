import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetFeedUseCase {
  final PostRepository repository;
  GetFeedUseCase(this.repository);

  Stream<List<PostEntity>> call({int limit = 20}) =>
      repository.getFeed(limit: limit);
}
