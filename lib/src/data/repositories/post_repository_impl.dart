import 'dart:typed_data';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/feed_api_datasource.dart';
import '../models/post_dto.dart';

class PostRepositoryImpl implements PostRepository {
  final FeedApiDataSource _datasource;

  PostRepositoryImpl(this._datasource);

  @override
  Future<List<PostEntity>> getFeed({int page = 1, int limit = 10}) async {
    final dtos = await _datasource.getFeedPosts(page: page, limit: limit);

    // Collect IDs of reposted originals that weren't inlined by the API
    final missingIds = dtos
        .where((d) => d.repostedFromDto == null && d.repostedFromId != null)
        .map((d) => d.repostedFromId!)
        .toSet()
        .toList();

    // Batch-fetch all missing originals in parallel (one round-trip per unique ID)
    final fetched = await Future.wait(
      missingIds.map((id) async {
        try {
          return await _datasource.getPostById(id);
        } catch (_) {
          return null;
        }
      }),
    );
    final repostCache = Map.fromIterables(missingIds, fetched);

    return dtos.map((dto) {
      PostEntity? repostedFrom;
      if (dto.repostedFromDto != null) {
        repostedFrom = dto.repostedFromDto!.toEntity();
      } else if (dto.repostedFromId != null) {
        final orig = repostCache[dto.repostedFromId!];
        if (orig != null) repostedFrom = orig.toEntity();
      }
      return dto.toEntity(repostedFrom: repostedFrom);
    }).toList();
  }

  @override
  Future<List<CommentEntity>> getPostComments(String postId) async {
    final dtos = await _datasource.getPostComments(postId);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<void> createPost({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<Uint8List> mediaBytes = const [],
  }) async {
    final isVideo = type == PostTypeEntity.video;

    // 1. Upload all media files in parallel to get their IDs
    final List<String> mediaIds = await Future.wait(
      mediaBytes.asMap().entries.map((entry) {
        final filename = isVideo
            ? 'media_${entry.key}.mp4'
            : 'media_${entry.key}.jpg';
        return _datasource.uploadMedia(entry.value, filename);
      }),
    );

    // 2. Resolve post type based on media presence, preserving video type
    final resolvedType = isVideo
        ? PostTypeEntity.video
        : mediaIds.isEmpty
            ? PostTypeEntity.text
            : mediaIds.length == 1
                ? PostTypeEntity.image
                : PostTypeEntity.multiImage;

    // 3. Create the post using the collected media IDs
    await _datasource.createPost(
      content: content,
      type: PostDto.typeToString(resolvedType),
      tags: tags,
      mediaIds: mediaIds,
    );
  }

  @override
  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    await _datasource.toggleLike(postId);
  }

  @override
  Future<void> repost({
    required String byUserId,
    required String originalPostId,
    required String addedText,
    required PostEntity originalPost,
  }) async {
    await _datasource.createRepost(originalPostId, addedText);
  }

  @override
  Future<CommentEntity> addComment(String postId, CommentEntity comment) async {
    final commentDto = await _datasource.addComment(postId, text: comment.text);
    return commentDto.toEntity();
  }

  @override
  Future<CommentEntity> addReply({
    required String postId,
    required String parentCommentId,
    required CommentEntity reply,
  }) async {
   final commentDto = await _datasource.addComment(postId,
        text: reply.text, parentId: parentCommentId);
    return commentDto.toEntity();
  }

  @override
  Future<void> updatePost(
    String postId,
    String content, {
    String? type,
    List<String> existingMediaIds = const [],
    List<Uint8List> newMediaBytes = const [],
  }) async {
    final isVideo = type == 'video';

    // 1. Upload any newly attached media files in parallel to get their IDs
    final uploadedIds = await Future.wait(
      newMediaBytes.asMap().entries.map((entry) {
        final filename = isVideo
            ? 'media_${entry.key}.mp4'
            : 'media_${entry.key}.jpg';
        return _datasource.uploadMedia(entry.value, filename);
      }),
    );

    // 2. Send the post update with kept existing IDs plus newly uploaded IDs
    await _datasource.updatePost(
      postId,
      content: content,
      type: type,
      mediaIds: [...existingMediaIds, ...uploadedIds],
    );
  }

  @override
  Future<void> deletePost(String postId) async {
    await _datasource.deletePost(postId);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _datasource.deleteComment(commentId);
  }

  @override
  Future<void> updateComment(String commentId, String text) async {
    await _datasource.updateComment(commentId, text);
  }

  @override
  Future<void> report(String targetId, String type, String reason) async {
    await _datasource.report(targetId, type, reason);
  }
}
