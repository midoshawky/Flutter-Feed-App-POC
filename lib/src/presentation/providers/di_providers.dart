import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../domain/usecases/repost_usecase.dart';
import '../../domain/usecases/comment_usecases.dart';

// ── Data-source ──────────────────────────────────────────────────────────────
final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  return FeedRemoteDataSource();
});

// ── Repositories ─────────────────────────────────────────────────────────────
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.watch(feedRemoteDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(feedRemoteDataSourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────
final getFeedUseCaseProvider = Provider<GetFeedUseCase>((ref) {
  return GetFeedUseCase(ref.watch(postRepositoryProvider));
});

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(ref.watch(postRepositoryProvider));
});

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  return ToggleLikeUseCase(ref.watch(postRepositoryProvider));
});

final repostUseCaseProvider = Provider<RepostUseCase>((ref) {
  return RepostUseCase(ref.watch(postRepositoryProvider));
});

final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) {
  return AddCommentUseCase(ref.watch(postRepositoryProvider));
});

final addReplyUseCaseProvider = Provider<AddReplyUseCase>((ref) {
  return AddReplyUseCase(ref.watch(postRepositoryProvider));
});
