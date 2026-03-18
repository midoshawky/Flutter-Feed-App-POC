import 'package:uuid/uuid.dart';
import 'comment.dart';

enum PostType { text, image, video, multiImage }

class Post {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> tags;
  final PostType type;
  final int likesCount;
  final int repostsCount;
  final List<Comment> comments;
  final DateTime timestamp;
  final bool isLiked;
  // When this post is a repost, this holds the original post
  final Post? repostedFrom;

  Post({
    String? id,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.mediaUrls = const [],
    this.tags = const [],
    required this.type,
    this.likesCount = 0,
    this.repostsCount = 0,
    this.comments = const [],
    required this.timestamp,
    this.isLiked = false,
    this.repostedFrom,
  }) : id = id ?? const Uuid().v4();

  Post copyWith({
    int? likesCount,
    int? repostsCount,
    List<Comment>? comments,
    bool? isLiked,
    Post? repostedFrom,
  }) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      mediaUrls: mediaUrls,
      tags: tags,
      type: type,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      comments: comments ?? this.comments,
      timestamp: timestamp,
      isLiked: isLiked ?? this.isLiked,
      repostedFrom: repostedFrom ?? this.repostedFrom,
    );
  }
}
