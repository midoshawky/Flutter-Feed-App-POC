import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/feed_api_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final FeedApiDataSource _datasource;
  final Map<String, UserEntity> _cache = {};

  UserRepositoryImpl(this._datasource);

  @override
  Future<UserEntity?> getUserById(String id) async {
    if (_cache.containsKey(id)) return _cache[id];
    final dto = await _datasource.getUserById(id);
    if (dto == null) return null;
    final entity = dto.toEntity();
    _cache[id] = entity;
    return entity;
  }

  @override
  Future<List<UserEntity>> getUsers(List<String> ids) async {
    final dtos = await _datasource.getUsers(ids);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<void> followUser(String userId) async {
    final user = await getUserById(userId);
    if (user != null) {
      await _datasource.toggleFollow(user.username);
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final user = await getUserById(userId);
    if (user != null) {
      await _datasource.toggleFollow(user.username);
    }
  }
}
