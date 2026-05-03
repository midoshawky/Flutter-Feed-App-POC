import '../../domain/entities/user_entity.dart';

class UserDto {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isFollowing;

  const UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.isFollowing = false,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['profile_picture_url'] as String? ?? '',
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    username: username,
    avatarUrl: avatarUrl,
    isFollowing: isFollowing,
  );
}
