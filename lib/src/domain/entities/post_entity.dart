import '../../models/post.dart';
import '../../models/user.dart';
import 'comment_entity.dart';
import 'user_entity.dart';

enum PostTypeEntity { text, image, video, multiImage }

class PostEntity {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> mediaIds;
  final List<String> tags;
  final PostTypeEntity type;
  final int likesCount;
  final int repostsCount;
  final List<CommentEntity> comments;
  final int commentsCount;
  final DateTime timestamp;
  final bool isLiked;
  final PostEntity? repostedFrom;
  final UserEntity? user;

  const PostEntity({
    required this.id,
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
    this.repostedFrom,
    this.user,
  });

  PostEntity copyWith({
    String? id,
    String? userId,
    String? content,
    String? imageUrl,
    List<String>? mediaUrls,
    List<String>? mediaIds,
    List<String>? tags,
    PostTypeEntity? type,
    int? likesCount,
    int? repostsCount,
    List<CommentEntity>? comments,
    int? commentsCount,
    DateTime? timestamp,
    bool? isLiked,
    PostEntity? repostedFrom,
    UserEntity? user,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaIds: mediaIds ?? this.mediaIds,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      repostedFrom: repostedFrom ?? this.repostedFrom,
      user: user ?? this.user,
    );
  }

  Post toLegacy({int depth = 0}) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      mediaUrls: mediaUrls,
      mediaIds: mediaIds,
      tags: tags,
      type: PostType.values[type.index],
      likesCount: likesCount,
      repostsCount: repostsCount,
      comments: comments.map((c) => c.toLegacy(depth: depth + 1)).toList(),
      commentsCount: commentsCount,
      timestamp: timestamp,
      isLiked: isLiked,
      repostedFrom: (depth < 5 && repostedFrom != null)
          ? repostedFrom!.toLegacy(depth: depth + 1)
          : null,
      user: user != null
          ? User(
              id: user!.id,
              name: user!.name,
              username: user!.username,
              avatarUrl: user!.avatarUrl,
              isFollowing: user!.isFollowing,
            )
          : null,
    );
  }
}
