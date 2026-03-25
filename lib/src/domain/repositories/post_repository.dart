import 'dart:typed_data';
import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';

abstract class PostRepository {
  /// Real-time stream of the feed (newest first, paginated to [limit])
  Stream<List<PostEntity>> getFeed({int limit = 20});

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

  Future<void> addComment(String postId, CommentEntity comment);

  Future<void> addReply({
    required String postId,
    required String parentCommentId,
    required CommentEntity reply,
  });
}
