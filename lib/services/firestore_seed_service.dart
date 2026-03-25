import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'mock_data_service.dart';

/// Seeds Firestore with MockDataService data ONCE (guarded by a `meta/seed` doc).
/// Call from main() in DEBUG mode only.
class FirestoreSeedService {
  final FirebaseFirestore _db;

  FirestoreSeedService([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  /// Seeds Firestore with MockDataService data.
  /// If [force] is true, it will even if already seeded.
  Future<void> seedIfNeeded({bool force = false}) async {
    print('🌱 Checking if Firestore seeding is needed...');
    if (!force) {
      final metaDoc = await _db.collection('meta').doc('seed').get();
      if (metaDoc.exists) {
        print('✅ Firestore already seeded.');
        return;
      }
    }

    print('🌱 Seeding Firestore with dummy data...');
    final batch = _db.batch();

    // ── Users ──────────────────────────────────────────────────────────────
    for (final user in MockDataService.users) {
      final ref = _db.collection('users').doc(user.id);
      batch.set(ref, {
        'name': user.name,
        'username': user.username,
        'avatarUrl': user.avatarUrl,
      });
    }

    // ── Posts + subcollections ─────────────────────────────────────────────
    for (final post in MockDataService.posts) {
      final postRef = _db.collection('posts').doc(post.id);
      batch.set(postRef, {
        'userId': post.userId,
        'content': post.content,
        'type': _typeStr(post.type),
        'tags': post.tags,
        'mediaUrls': post.mediaUrls,
        if (post.imageUrl != null) 'imageUrl': post.imageUrl,
        'likesCount': post.likesCount,
        'repostsCount': post.repostsCount,
        'timestamp': Timestamp.fromDate(post.timestamp),
      });

      // Comments
      for (final comment in post.comments) {
        final cRef = postRef.collection('comments').doc(comment.id);
        batch.set(cRef, {
          'userId': comment.userId,
          'userName': comment.userName,
          'text': comment.text,
          'timestamp': Timestamp.fromDate(comment.timestamp),
          'likesCount': comment.likesCount,
        });

        // Replies
        for (final reply in comment.replies) {
          final rRef = cRef.collection('replies').doc(reply.id);
          batch.set(rRef, {
            'userId': reply.userId,
            'userName': reply.userName,
            'text': reply.text,
            'timestamp': Timestamp.fromDate(reply.timestamp),
            'likesCount': reply.likesCount,
          });
        }
      }
    }

    // Mark as seeded
    batch.set(_db.collection('meta').doc('seed'), {'seededAt': FieldValue.serverTimestamp()});
    await batch.commit();
    print('✅ Firestore seeding complete!');
  }

  String _typeStr(PostType t) {
    switch (t) {
      case PostType.image:
        return 'image';
      case PostType.video:
        return 'video';
      case PostType.multiImage:
        return 'multiImage';
      default:
        return 'text';
    }
  }
}
