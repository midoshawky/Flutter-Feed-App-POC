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
  final String? currentUserAvatarUrl;

  const FeedScreen({
    super.key,
    this.authToken,
    this.currentUserId = '',
    this.currentUserName = '',
    this.currentUserAvatarUrl,
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
    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('token')) {
        effectiveToken = uri.queryParameters['token'];
      }
    }

    _container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith(
          (ref) => ApiClient(tokenProvider: () => effectiveToken),
        ),
        currentUserIdProvider.overrideWithValue(widget.currentUserId),
        currentUserNameProvider.overrideWithValue(widget.currentUserName),
        currentUserAvatarUrlProvider.overrideWithValue(
          'https://i.pravatar.cc/150?u=${widget.currentUserId}',
        ),
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

class _FeedScreenBody extends ConsumerWidget {
  const _FeedScreenBody();

  void _showCreatePostSheet(BuildContext context, WidgetRef ref) {
    final container = ProviderScope.containerOf(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => UncontrolledProviderScope(
        container: container,
        child: DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) => Container(
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(optimisticFeedProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showCreatePostSheet(context, ref),
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
                          onTap: () => _showCreatePostSheet(context, ref),
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
            data: (posts) => ListView.builder(
              itemCount: posts.length + 1,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return isMobile
                      ? GestureDetector(
                          onTap: () => _showCreatePostSheet(context, ref),
                          child: const MobileCreatePostTrigger(),
                        )
                      : const CreatePostCard();
                }
                final entity = posts[index - 1];
                return PostCard(post: entity.toLegacy());
              },
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
          UserAvatar(url: currentUserAvatar ?? ''),
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
