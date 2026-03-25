import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';
import 'comment_dto.dart';

class PostDto {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> tags;
  final String type; // stored as string in Firestore
  final int likesCount;
  final int repostsCount;
  final DateTime timestamp;
  final String? repostedFromId;
  final List<CommentDto> comments;

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
  });

  factory PostDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostDto(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      mediaUrls: List<String>.from(data['mediaUrls'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      type: data['type'] as String? ?? 'text',
      likesCount: (data['likesCount'] as int?) ?? 0,
      repostsCount: (data['repostsCount'] as int?) ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      repostedFromId: data['repostedFromId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'mediaUrls': mediaUrls,
        'tags': tags,
        'type': type,
        'likesCount': likesCount,
        'repostsCount': repostsCount,
        'timestamp': Timestamp.fromDate(timestamp),
        if (repostedFromId != null) 'repostedFromId': repostedFromId,
      };

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

  PostEntity toEntity({bool isLiked = false, PostEntity? repostedFrom}) {
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
      isLiked: isLiked,
      repostedFrom: repostedFrom,
    );
  }
}
