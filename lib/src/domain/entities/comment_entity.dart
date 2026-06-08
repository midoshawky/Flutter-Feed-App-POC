import '../../models/comment.dart';

class CommentEntity {
  final String id;
  final String userId;
  final String userName;
  final String userUsername;
  final String userAvatarUrl;
  final String text;
  final DateTime timestamp;
  final List<CommentEntity> replies;
  final int likesCount;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userUsername = '',
    this.userAvatarUrl = '',
    required this.text,
    required this.timestamp,
    this.replies = const [],
    this.likesCount = 0,
  });

  CommentEntity copyWith({
    String? text,
    List<CommentEntity>? replies,
    int? likesCount,
  }) {
    return CommentEntity(
      id: id,
      userId: userId,
      userName: userName,
      userUsername: userUsername,
      userAvatarUrl: userAvatarUrl,
      text: text ?? this.text,
      timestamp: timestamp,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  Comment toLegacy({int depth = 0}) {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      userUsername: userUsername,
      userAvatarUrl: userAvatarUrl,
      text: text,
      timestamp: timestamp,
      likesCount: likesCount,
      replies: (depth < 10)
          ? replies.map((r) => r.toLegacy(depth: depth + 1)).toList()
          : [],
    );
  }
}
