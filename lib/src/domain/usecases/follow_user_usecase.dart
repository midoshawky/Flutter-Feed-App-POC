import '../repositories/user_repository.dart';

class FollowUserUseCase {
  final UserRepository repository;
  FollowUserUseCase(this.repository);

  Future<void> call(String userId, bool isFollowing) async {
    if (isFollowing) {
      await repository.unfollowUser(userId);
    } else {
      await repository.followUser(userId);
    }
  }
}
