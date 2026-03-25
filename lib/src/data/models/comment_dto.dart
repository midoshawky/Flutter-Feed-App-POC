import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment_entity.dart';

class CommentDto {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final int likesCount;
  final List<CommentDto> replies;

  const CommentDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.likesCount = 0,
    this.replies = const [],
  });

  factory CommentDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentDto(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: (data['likesCount'] as int?) ?? 0,
    );
  }

  factory CommentDto.fromMap(String id, Map<String, dynamic> data) {
    return CommentDto(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: (data['likesCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'text': text,
        'timestamp': Timestamp.fromDate(timestamp),
        'likesCount': likesCount,
      };

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      timestamp: timestamp,
      likesCount: likesCount,
      replies: replies.map((r) => r.toEntity()).toList(),
    );
  }
}
