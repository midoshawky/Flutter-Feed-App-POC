import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/feed_api_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../domain/usecases/repost_usecase.dart';
import '../../domain/usecases/comment_usecases.dart';
import '../../domain/usecases/update_post_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/follow_user_usecase.dart';

/// Bearer token for API auth. Overridden by FeedScreen via its authToken param.
final authTokenProvider = Provider<String?>((ref) => null);

/// ID of the currently logged-in user. Overridden by FeedScreen via its currentUserId param.
final currentUserIdProvider = Provider<String>((ref) => '');

/// Display name of the current user (used in optimistic comment/reply display).
final currentUserNameProvider = Provider<String>((ref) => '');

final currentUserAvatarUrlProvider = Provider<String?>((ref) => null);

// ── Infrastructure ────────────────────────────────────────────────────────────
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenProvider: () => ref.watch(authTokenProvider));
});

final feedApiDataSourceProvider = Provider<FeedApiDataSource>((ref) {
  return FeedApiDataSource(ref.watch(apiClientProvider));
});

// ── Repositories ─────────────────────────────────────────────────────────────
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.watch(feedApiDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(feedApiDataSourceProvider));
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

final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>((ref) {
  return DeleteCommentUseCase(ref.watch(postRepositoryProvider));
});

final updateCommentUseCaseProvider = Provider<UpdateCommentUseCase>((ref) {
  return UpdateCommentUseCase(ref.watch(postRepositoryProvider));
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  return UpdatePostUseCase(ref.watch(postRepositoryProvider));
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  return DeletePostUseCase(ref.watch(postRepositoryProvider));
});

final followUserUseCaseProvider = Provider<FollowUserUseCase>((ref) {
  return FollowUserUseCase(ref.watch(userRepositoryProvider));
});
