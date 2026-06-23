import '../../domain/entities/media_attachment.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/feed_api_datasource.dart';
import '../models/post_dto.dart';

class PostRepositoryImpl implements PostRepository {
  final FeedApiDataSource _datasource;

  PostRepositoryImpl(this._datasource);

  @override
  Future<List<PostEntity>> getFeed({
    int page = 1,
    int limit = 10,
    String? userId,
    String? postId,
  }) async {
    if (postId != null) {
      final dto = await _datasource.getPostById(postId);
      if (dto == null) return [];
      final repostCache = await _fetchRepostCache([dto]);
      return [_dtoToEntity(dto, repostCache)];
    }

    final dtos = await _datasource.getFeedPosts(
      page: page,
      limit: limit,
      userId: userId,
    );
    final repostCache = await _fetchRepostCache(dtos);
    return dtos.map((dto) => _dtoToEntity(dto, repostCache)).toList();
  }

  /// Batch-fetches reposted originals that weren't inlined by the API
  /// (one round-trip per unique ID).
  Future<Map<String, PostDto?>> _fetchRepostCache(List<PostDto> dtos) async {
    final missingIds = dtos
        .where((d) => d.repostedFromDto == null && d.repostedFromId != null)
        .map((d) => d.repostedFromId!)
        .toSet()
        .toList();

    final fetched = await Future.wait(
      missingIds.map((id) async {
        try {
          return await _datasource.getPostById(id);
        } catch (_) {
          return null;
        }
      }),
    );
    return Map.fromIterables(missingIds, fetched);
  }

  PostEntity _dtoToEntity(PostDto dto, Map<String, PostDto?> repostCache) {
    PostEntity? repostedFrom;
    if (dto.repostedFromDto != null) {
      repostedFrom = dto.repostedFromDto!.toEntity();
    } else if (dto.repostedFromId != null) {
      final orig = repostCache[dto.repostedFromId!];
      if (orig != null) repostedFrom = orig.toEntity();
    }
    return dto.toEntity(repostedFrom: repostedFrom);
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
    List<MediaAttachment> media = const [],
  }) async {
    // 1. Upload all media files in parallel to get their IDs
    final List<String> mediaIds = await Future.wait(
      media.asMap().entries.map((entry) {
        final filename = entry.value.isVideo
            ? 'media_${entry.key}.mp4'
            : 'media_${entry.key}.jpg';
        return _datasource.uploadMedia(entry.value.bytes, filename);
      }),
    );

    // 2. Resolve post type based on media presence
    final resolvedType = resolvePostType(
      totalMediaCount: mediaIds.length,
      hasVideo: media.any((m) => m.isVideo),
    );

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
    List<MediaAttachment> newMedia = const [],
  }) async {
    // 1. Upload any newly attached media files in parallel to get their IDs
    final uploadedIds = await Future.wait(
      newMedia.asMap().entries.map((entry) {
        final filename = entry.value.isVideo
            ? 'media_${entry.key}.mp4'
            : 'media_${entry.key}.jpg';
        return _datasource.uploadMedia(entry.value.bytes, filename);
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
