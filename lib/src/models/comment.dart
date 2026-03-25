import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final List<Comment> replies;
  final int likesCount;

  Comment({
    String? id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.replies = const [],
    this.likesCount = 0,
  }) : id = id ?? const Uuid().v4();

  Comment copyWith({
    List<Comment>? replies,
    int? likesCount,
  }) {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      timestamp: timestamp,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
