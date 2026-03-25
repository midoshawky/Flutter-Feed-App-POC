import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<List<UserEntity>> getUsers(List<String> ids);
}
