class User {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isFollowing;
  final String? bio;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.isFollowing = false,
    this.bio,
  });

  User copyWith({
    String? name,
    String? username,
    String? avatarUrl,
    bool? isFollowing,
    String? bio,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      bio: bio ?? this.bio,
    );
  }
}
