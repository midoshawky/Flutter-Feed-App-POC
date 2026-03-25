import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserDto {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;

  const UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });

  factory UserDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDto(
      id: doc.id,
      name: data['name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'username': username,
        'avatarUrl': avatarUrl,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        username: username,
        avatarUrl: avatarUrl,
      );
}
