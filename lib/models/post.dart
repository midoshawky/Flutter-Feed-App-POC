import 'package:uuid/uuid.dart';
import 'comment.dart';

enum PostType { text, image }

class Post {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final PostType type;
  final int likesCount;
  final List<Comment> comments;
  final DateTime timestamp;
  final bool isLiked;

  Post({
    String? id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.type,
    this.likesCount = 0,
    this.comments = const [],
    required this.timestamp,
    this.isLiked = false,
  }) : id = id ?? const Uuid().v4();

  Post copyWith({int? likesCount, List<Comment>? comments, bool? isLiked}) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      type: type,
      likesCount: likesCount ?? this.likesCount,
      comments: comments ?? this.comments,
      timestamp: timestamp,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
