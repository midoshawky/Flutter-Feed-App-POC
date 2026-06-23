import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/datasources/api_client.dart';
import '../providers/di_providers.dart';
import '../providers/optimistic_feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_card_skeleton.dart';
import '../widgets/create_post_card.dart';
import '../../utils/responsive_layout.dart';
import '../widgets/user_avatar.dart';

/// Entry point for the feed module.
///
/// Pass [authToken] and [currentUserId] so the module can authenticate API
/// requests and attribute new posts/comments to the correct user.
class FeedScreen extends StatefulWidget {
  final String? authToken;
  final String currentUserId;
  final String currentUserName;
  final String currentUserUsername;
  final String? currentUserAvatarUrl;
  final bool? myFeed;
  final String? postId;

  const FeedScreen({
    super.key,
    this.authToken,
    this.currentUserId = '',
    this.currentUserName = '',
    this.currentUserUsername = '',
    this.currentUserAvatarUrl,
    this.myFeed,
    this.postId,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    
    String? effectiveToken = widget.authToken;
    String effectiveUserId = widget.currentUserId;
    String effectiveUserName = widget.currentUserName;
    String effectiveUserUsername = widget.currentUserUsername;
    String? effectiveAvatarUrl = widget.currentUserAvatarUrl;
    bool? effectiveMyFeed = widget.myFeed;
    String? effectivePostId = widget.postId;

    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('token')) {
        effectiveToken = uri.queryParameters['token'];
      }
      if (uri.queryParameters.containsKey('user_id')) {
        effectiveUserId = uri.queryParameters['user_id']!;
      }
      if (uri.queryParameters.containsKey('user_name')) {
        effectiveUserName = uri.queryParameters['user_name']!;
      }
      if (uri.queryParameters.containsKey('username')) {
        effectiveUserUsername = uri.queryParameters['username']!;
      }
      if (uri.queryParameters.containsKey('avatar_url')) {
        effectiveAvatarUrl = uri.queryParameters['avatar_url'];
      }
      if (uri.queryParameters.containsKey('my_feed')) {
        effectiveMyFeed = bool.tryParse(uri.queryParameters['my_feed']??'');
      }
      if (uri.queryParameters.containsKey('post_id')) {
        effectivePostId = uri.queryParameters['post_id'];
      }
    }

    _container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith(
          (ref) => ApiClient(tokenProvider: () => effectiveToken),
        ),
        currentUserIdProvider.overrideWithValue(effectiveUserId),
        currentUserNameProvider.overrideWithValue(effectiveUserName),
        currentUserUsernameProvider.overrideWithValue(effectiveUserUsername),
        currentUserAvatarUrlProvider.overrideWithValue(effectiveAvatarUrl),
        myFeedProvider.overrideWithValue(effectiveMyFeed ?? false),
        postIdProvider.overrideWithValue(effectivePostId),
      ],
    );
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: const _FeedScreenBody(),
    );
  }
}

class _FeedScreenBody extends ConsumerStatefulWidget {
  const _FeedScreenBody();

  @override
  ConsumerState<_FeedScreenBody> createState() => _FeedScreenBodyState();
}

class _FeedScreenBodyState extends ConsumerState<_FeedScreenBody> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_isLoadingMore) return;
    final notifier = ref.read(optimisticFeedProvider.notifier);
    if (!notifier.hasMore) return;
    setState(() => _isLoadingMore = true);
    await notifier.loadMore();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _showCreatePostSheet(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => UncontrolledProviderScope(
        container: container,
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.8,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: const CreatePostCard(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(optimisticFeedProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showCreatePostSheet(context),
              backgroundColor: const Color(0xFF4535C1),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: feedAsync.when(
            loading: () => ListView.builder(
              itemCount: 4,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return isMobile
                      ? GestureDetector(
                          onTap: () => _showCreatePostSheet(context),
                          child: const MobileCreatePostTrigger(),
                        )
                      : const CreatePostCard();
                }
                return const PostCardSkeleton();
              },
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: Color(0xFF787878),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load feed',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF787878),
                    ),
                  ),
                ],
              ),
            ),
            data: (posts) => RefreshIndicator(
              color: const Color(0xFF4535C1),
              onRefresh: () =>
                  ref.read(optimisticFeedProvider.notifier).refresh(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + 2, // +1 create card, +1 footer
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return isMobile
                        ? GestureDetector(
                            onTap: () => _showCreatePostSheet(context),
                            child: const MobileCreatePostTrigger(),
                          )
                        : const CreatePostCard();
                  }
                  if (index == posts.length + 1) {
                    // Footer: spinner while loading more, end-of-feed otherwise
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _isLoadingMore
                            ? const CircularProgressIndicator(
                                color: Color(0xFF4535C1),
                                strokeWidth: 2,
                              )
                            : ref.read(optimisticFeedProvider.notifier).hasMore
                                ? const SizedBox.shrink()
                                : Text(
                                    'You\'re all caught up',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF787878),
                                    ),
                                  ),
                      ),
                    );
                  }
                  final entity = posts[index - 1];
                  return PostCard(post: entity.toLegacy());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileCreatePostTrigger extends ConsumerWidget {
  const MobileCreatePostTrigger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserName = ref.read(currentUserNameProvider);
    final currentUserAvatar = ref.read(currentUserAvatarUrlProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(url: currentUserAvatar ?? '', name: currentUserName),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "What are you working on, ${currentUserName.split(' ')[0]}?",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF787878),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
