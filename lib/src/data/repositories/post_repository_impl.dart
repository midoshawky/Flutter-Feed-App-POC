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
    final List<PostEntity> posts = [];
    for (final dto in dtos) {
      PostEntity? repostedFrom;
      if (dto.repostedFromDto != null) {
        repostedFrom = dto.repostedFromDto!.toEntity();
      } else if (dto.repostedFromId != null) {
        final origDto = await _datasource.getPostById(dto.repostedFromId!);
        if (origDto != null) repostedFrom = origDto.toEntity();
      }
      posts.add(dto.toEntity(repostedFrom: repostedFrom));
    }
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
    final resolvedType = mediaBytes.length == 1
        ? PostTypeEntity.image
        : mediaBytes.length > 1
            ? PostTypeEntity.multiImage
            : type;

    await _datasource.createPost(
      content: content,
      type: PostDto.typeToString(resolvedType),
      tags: tags,
      mediaBytes: mediaBytes,
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
}
