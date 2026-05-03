class UserEntity {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isFollowing;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.isFollowing = false,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? avatarUrl,
    bool? isFollowing,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
