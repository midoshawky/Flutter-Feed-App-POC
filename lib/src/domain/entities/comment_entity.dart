import '../../models/comment.dart';

class CommentEntity {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final List<CommentEntity> replies;
  final int likesCount;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.replies = const [],
    this.likesCount = 0,
  });

  CommentEntity copyWith({List<CommentEntity>? replies, int? likesCount}) {
    return CommentEntity(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      timestamp: timestamp,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  Comment toLegacy() {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      timestamp: timestamp,
      likesCount: likesCount,
      replies: replies.map((r) => r.toLegacy()).toList(),
    );
  }
}
