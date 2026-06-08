import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post_entity.dart';
import 'di_providers.dart';

// ── Feed (page 1 only — pagination is managed by OptimisticFeedNotifier) ──────
final feedStreamProvider = FutureProvider<List<PostEntity>>((ref) {
  return ref.watch(getFeedUseCaseProvider).call(page: 1, limit: 10);
});

// ── Like action (optimistic update) ──────────────────────────────────────────
final feedActionsProvider = Provider<FeedActions>((ref) => FeedActions(ref));

class FeedActions {
  final Ref _ref;
  FeedActions(this._ref);

  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    await _ref
        .read(toggleLikeUseCaseProvider)
        .call(postId, currentlyLiked);
  }

  Future<void> repost({
    required String byUserId,
    required String originalPostId,
    required String addedText,
    required PostEntity originalPost,
  }) async {
    await _ref.read(repostUseCaseProvider).call(
          byUserId: byUserId,
          originalPostId: originalPostId,
          addedText: addedText,
          originalPost: originalPost,
        );
  }
}
