import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/feed_remote_datasource.dart';
import '../models/post_dto.dart';

class PostRepositoryImpl implements PostRepository {
  final FeedRemoteDataSource _datasource;

  PostRepositoryImpl(this._datasource);

  @override
  Stream<List<PostEntity>> getFeed({int limit = 20}) {
    return _datasource.getFeedStream(limit: limit).asyncMap((dtos) async {
      final List<PostEntity> posts = [];
      for (final dto in dtos) {
        PostEntity? repostedFrom;
        if (dto.repostedFromId != null) {
          final origDto = await _datasource.getPostById(dto.repostedFromId!);
          if (origDto != null) repostedFrom = origDto.toEntity();
        }
        posts.add(dto.toEntity(repostedFrom: repostedFrom));
      }
      return posts;
    });
  }

  @override
  Future<void> createPost({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<Uint8List> mediaBytes = const [],
  }) async {
    final mediaUrls = <String>[];
    for (int i = 0; i < mediaBytes.length; i++) {
      final path = 'posts/${const Uuid().v4()}_$i.jpg';
      final url = await _datasource.uploadMedia(mediaBytes[i], path);
      mediaUrls.add(url);
    }

    final resolvedType = mediaUrls.length == 1
        ? PostTypeEntity.image
        : mediaUrls.length > 1
            ? PostTypeEntity.multiImage
            : type;

    await _datasource.createPost({
      'userId': userId,
      'content': content,
      'type': PostDto.typeToString(resolvedType),
      'tags': tags,
      'mediaUrls': mediaUrls,
      if (mediaUrls.isNotEmpty) 'imageUrl': mediaUrls.first,
      'likesCount': 0,
      'repostsCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    await _datasource.updatePostField(postId, {
      'likesCount': FieldValue.increment(currentlyLiked ? -1 : 1),
    });
  }

  @override
  Future<void> repost({
    required String byUserId,
    required String originalPostId,
    required String addedText,
    required PostEntity originalPost,
  }) async {
    await _datasource.incrementRepostCount(originalPostId);
    await _datasource.createPost({
      'userId': byUserId,
      'content': addedText,
      'type': 'text',
      'tags': <String>[],
      'mediaUrls': <String>[],
      'likesCount': 0,
      'repostsCount': 0,
      'repostedFromId': originalPostId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addComment(String postId, CommentEntity comment) async {
    await _datasource.addComment(postId, {
      'userId': comment.userId,
      'userName': comment.userName,
      'text': comment.text,
      'timestamp': FieldValue.serverTimestamp(),
      'likesCount': 0,
    });
  }

  @override
  Future<void> addReply({
    required String postId,
    required String parentCommentId,
    required CommentEntity reply,
  }) async {
    await _datasource.addReply(postId, parentCommentId, {
      'userId': reply.userId,
      'userName': reply.userName,
      'text': reply.text,
      'timestamp': FieldValue.serverTimestamp(),
      'likesCount': 0,
    });
  }
}
