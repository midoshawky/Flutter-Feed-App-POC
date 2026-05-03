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

  factory CommentDto.fromJson(Map<String, dynamic> json, {int depth = 0}) {
    if (depth > 10) {
      // Prevent infinite recursion from circular replies
      return CommentDto(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        userName: '',
        text: '...',
        timestamp: DateTime.now(),
      );
    }
    final user = json['user'] as Map<String, dynamic>?;
    return CommentDto(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: user?['name'] as String? ?? '',
      text: json['text'] as String? ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      replies: (json['replies'] as List? ?? [])
          .map((r) => CommentDto.fromJson(r as Map<String, dynamic>, depth: depth + 1))
          .toList(),
    );
  }

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
