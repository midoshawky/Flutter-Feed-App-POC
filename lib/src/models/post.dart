import 'comment.dart';
import 'user.dart';

enum PostType { text, image, video, multiImage }

class Post {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> mediaIds;
  final List<String> tags;
  final PostType type;
  final int likesCount;
  final int repostsCount;
  final List<Comment> comments;
  final int commentsCount;
  final DateTime timestamp;
  final bool isLiked;
  final String? repostedFromId;
  final Post? repostedFrom;
  final User? user;

  Post({
    String? id,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.mediaUrls = const [],
    this.mediaIds = const [],
    this.tags = const [],
    required this.type,
    this.likesCount = 0,
    this.repostsCount = 0,
    this.comments = const [],
    this.commentsCount = 0,
    required this.timestamp,
    this.isLiked = false,
    this.repostedFromId,
    this.repostedFrom,
    this.user,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Post copyWith({
    String? content,
    int? likesCount,
    int? repostsCount,
    List<Comment>? comments,
    int? commentsCount,
    bool? isLiked,
    Post? repostedFrom,
    User? user,
  }) {
    return Post(
      id: id,
      userId: userId,
      content: content ?? this.content,
      imageUrl: imageUrl,
      mediaUrls: mediaUrls,
      mediaIds: mediaIds,
      tags: tags,
      type: type,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      timestamp: timestamp,
      isLiked: isLiked ?? this.isLiked,
      repostedFromId: repostedFromId,
      repostedFrom: repostedFrom ?? this.repostedFrom,
      user: user,
    );
  }
}
