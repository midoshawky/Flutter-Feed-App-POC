import 'dart:typed_data';
import 'package:feed_module/feed_module.dart';

import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getFeed({int page = 1, int limit = 10});

  Future<List<CommentEntity>> getPostComments(String postId);

  Future<void> createPost({
    required String userId,
    required String content,
    required PostTypeEntity type,
    required List<String> tags,
    List<Uint8List> mediaBytes,
  });

  Future<void> toggleLike(String postId, bool currentlyLiked);

  Future<void> repost({
    required String byUserId,
    required String originalPostId,
    required String addedText,
    required PostEntity originalPost,
  });

  Future<CommentEntity> addComment(String postId, CommentEntity comment);

  Future<CommentEntity> addReply({
    required String postId,
    required String parentCommentId,
    required CommentEntity reply,
  });

  Future<void> updatePost(String postId, String content, {String? type});

  Future<void> deletePost(String postId);

  Future<void> deleteComment(String commentId);

  Future<void> updateComment(String commentId, String text);

  Future<void> report(String targetId, String type, String reason);
}
