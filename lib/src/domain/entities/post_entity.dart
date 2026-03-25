import '../../models/post.dart';
import 'comment_entity.dart';

enum PostTypeEntity { text, image, video, multiImage }

class PostEntity {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> tags;
  final PostTypeEntity type;
  final int likesCount;
  final int repostsCount;
  final List<CommentEntity> comments;
  final DateTime timestamp;
  final bool isLiked;
  final PostEntity? repostedFrom;

  const PostEntity({
    required this.id,
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
  });

  PostEntity copyWith({
    int? likesCount,
    int? repostsCount,
    List<CommentEntity>? comments,
    bool? isLiked,
    PostEntity? repostedFrom,
  }) {
    return PostEntity(
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

  Post toLegacy() {
    return Post(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      mediaUrls: mediaUrls,
      tags: tags,
      type: PostType.values[type.index],
      likesCount: likesCount,
      repostsCount: repostsCount,
      comments: comments.map((c) => c.toLegacy()).toList(),
      timestamp: timestamp,
      isLiked: isLiked,
      repostedFrom: repostedFrom?.toLegacy(),
    );
  }
}
