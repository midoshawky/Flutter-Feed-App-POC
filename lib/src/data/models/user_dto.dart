import 'package:flutter/foundation.dart' show kIsWeb;
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
      avatarUrl: _proxifyUrl(json['profile_picture_url'] as String? ?? ''),
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  static String _proxifyUrl(String url) {
    if (kIsWeb && url.startsWith('https://dev-backend-shuwier.pomac.info/')) {
      return url.replaceFirst('https://dev-backend-shuwier.pomac.info/', '/');
    }
    return url;
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        username: username,
        avatarUrl: avatarUrl,
        isFollowing: isFollowing,
      );
}
