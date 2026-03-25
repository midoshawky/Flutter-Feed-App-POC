import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_dto.dart';
import '../models/comment_dto.dart';
import '../models/user_dto.dart';



class FeedRemoteDataSource {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  FeedRemoteDataSource({FirebaseFirestore? db, FirebaseStorage? storage})
      : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ── Posts ───────────────────────────────────────────────────────────────

  Stream<List<PostDto>> getFeedStream({int limit = 20}) {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<PostDto> posts = [];
      for (final doc in snapshot.docs) {
        final dto = PostDto.fromFirestore(doc);
        // Load comments subcollection
        final commentsSnap = await _db
            .collection('posts')
            .doc(doc.id)
            .collection('comments')
            .orderBy('timestamp')
            .get();

        final List<CommentDto> comments = [];
        for (final cDoc in commentsSnap.docs) {
          final comment = CommentDto.fromFirestore(cDoc);
          // Load replies subcollection
          final repliesSnap = await _db
              .collection('posts')
              .doc(doc.id)
              .collection('comments')
              .doc(cDoc.id)
              .collection('replies')
              .orderBy('timestamp')
              .get();
          final replies = repliesSnap.docs
              .map((r) => CommentDto.fromFirestore(r))
              .toList();
          comments.add(CommentDto(
            id: comment.id,
            userId: comment.userId,
            userName: comment.userName,
            text: comment.text,
            timestamp: comment.timestamp,
            likesCount: comment.likesCount,
            replies: replies,
          ));
        }

        posts.add(PostDto(
          id: dto.id,
          userId: dto.userId,
          content: dto.content,
          imageUrl: dto.imageUrl,
          mediaUrls: dto.mediaUrls,
          tags: dto.tags,
          type: dto.type,
          likesCount: dto.likesCount,
          repostsCount: dto.repostsCount,
          timestamp: dto.timestamp,
          repostedFromId: dto.repostedFromId,
          comments: comments,
        ));
      }
      return posts;
    });
  }

  Future<PostDto?> getPostById(String postId) async {
    final doc = await _db.collection('posts').doc(postId).get();
    if (!doc.exists) return null;
    return PostDto.fromFirestore(doc);
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    await _db.collection('posts').add(data);
  }

  Future<void> updatePostField(
      String postId, Map<String, dynamic> fields) async {
    await _db.collection('posts').doc(postId).update(fields);
  }

  Future<void> incrementRepostCount(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'repostsCount': FieldValue.increment(1),
    });
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  Future<void> addComment(
      String postId, Map<String, dynamic> commentData) async {
    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(commentData);
  }

  Future<void> addReply(String postId, String commentId,
      Map<String, dynamic> replyData) async {
    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .add(replyData);
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<UserDto?> getUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return UserDto.fromFirestore(doc);
  }

  Future<List<UserDto>> getUsers(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = await Future.wait(ids.map(getUserById));
    return results.whereType<UserDto>().toList();
  }

  // ── Storage ───────────────────────────────────────────────────────────────

  Future<String> uploadMedia(Uint8List bytes, String path) async {
    final ref = _storage.ref(path);
    final task = await ref.putData(bytes);
    return await task.ref.getDownloadURL();
  }
}
