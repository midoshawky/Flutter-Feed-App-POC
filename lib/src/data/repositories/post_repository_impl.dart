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
  Stream<List<PostEntity>> getFeed({int limit = 20}) async* {
    final dtos = await _datasource.getFeedPosts(limit: limit);
    
    // Fetch original posts for reposts in parallel
    final posts = await Future.wait(dtos.map((dto) async {
      PostEntity? repostedFrom;
      if (dto.repostedFromDto != null) {
        repostedFrom = dto.repostedFromDto!.toEntity();
      } else if (dto.repostedFromId != null) {
        try {
          final origDto = await _datasource.getPostById(dto.repostedFromId!);
          if (origDto != null) repostedFrom = origDto.toEntity();
        } catch (_) {
          // If fetch fails, we just don't show the repost preview
        }
      }
      return dto.toEntity(repostedFrom: repostedFrom);
    }));
    
    yield posts;
  }

  @override
  Future<void> createPost({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<Uint8List> mediaBytes = const [],
  }) async {
    // 1. Upload all media files in parallel to get their IDs
    final List<String> mediaIds = await Future.wait(
      mediaBytes.asMap().entries.map((entry) => 
        _datasource.uploadMedia(entry.value, 'media_${entry.key}.jpg')
      ),
    );

    // 2. Resolve post type based on media presence if it was not explicitly set correctly
    final resolvedType = mediaIds.isEmpty
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
  Future<void> addComment(String postId, CommentEntity comment) async {
    await _datasource.addComment(postId, text: comment.text);
  }

  @override
  Future<void> addReply({
    required String postId,
    required String parentCommentId,
    required CommentEntity reply,
  }) async {
    await _datasource.addComment(postId,
        text: reply.text, parentId: parentCommentId);
  }

  @override
  Future<void> updatePost(String postId, String content) async {
    await _datasource.updatePost(postId, content: content);
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
}
