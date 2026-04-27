import '../../domain/entities/post_entity.dart';
import 'comment_dto.dart';
import 'user_dto.dart';

class PostDto {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> tags;
  final String type;
  final int likesCount;
  final int repostsCount;
  final DateTime timestamp;
  final String? repostedFromId;
  final List<CommentDto> comments;
  final bool isLiked;
  final UserDto? userDto;
  final PostDto? repostedFromDto;

  const PostDto({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.mediaUrls = const [],
    this.tags = const [],
    required this.type,
    this.likesCount = 0,
    this.repostsCount = 0,
    required this.timestamp,
    this.repostedFromId,
    this.comments = const [],
    this.isLiked = false,
    this.userDto,
    this.repostedFromDto,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    final mediaList = (json['media'] as List? ?? []);
    final mediaUrls = mediaList
        .map((m) => (m as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final userJson = json['user'] as Map<String, dynamic>?;
    final repostedFromJson = json['reposted_from'] as Map<String, dynamic>?;

    return PostDto(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      content: json['content'] as String? ?? '',
      imageUrl: mediaUrls.isNotEmpty ? mediaUrls.first : null,
      mediaUrls: mediaUrls,
      tags: (json['tags'] as List? ?? [])
          .map((t) => (t as Map<String, dynamic>)['name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      type: json['type'] as String? ?? 'text',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      repostsCount: (json['reposts_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      repostedFromId: json['reposted_from_id']?.toString(),
      comments: (json['comments'] as List? ?? [])
          .map((c) => CommentDto.fromJson(c as Map<String, dynamic>))
          .toList(),
      userDto: userJson != null ? UserDto.fromJson(userJson) : null,
      repostedFromDto: repostedFromJson != null
          ? PostDto.fromJson(repostedFromJson)
          : null,
    );
  }

  static PostTypeEntity _typeFromString(String s) {
    switch (s) {
      case 'image':
        return PostTypeEntity.image;
      case 'video':
        return PostTypeEntity.video;
      case 'multiImage':
        return PostTypeEntity.multiImage;
      default:
        return PostTypeEntity.text;
    }
  }

  static String typeToString(PostTypeEntity t) {
    switch (t) {
      case PostTypeEntity.image:
        return 'image';
      case PostTypeEntity.video:
        return 'video';
      case PostTypeEntity.multiImage:
        return 'multiImage';
      default:
        return 'text';
    }
  }

  PostEntity toEntity({bool? isLiked, PostEntity? repostedFrom}) {
    return PostEntity(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      mediaUrls: mediaUrls,
      tags: tags,
      type: _typeFromString(type),
      likesCount: likesCount,
      repostsCount: repostsCount,
      comments: comments.map((c) => c.toEntity()).toList(),
      timestamp: timestamp,
      isLiked: isLiked ?? this.isLiked,
      repostedFrom: repostedFrom,
      user: userDto?.toEntity(),
    );
  }
}
