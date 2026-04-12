import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/optimistic_feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_card_skeleton.dart';
import '../widgets/create_post_card.dart';
import '../../services/firestore_seed_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/responsive_layout.dart';
import '../widgets/user_avatar.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  Future<void> _handleManualSeed(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeding Firestore...')),
      );
      await FirestoreSeedService().seedIfNeeded(force: true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seeding complete!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(optimisticFeedProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'Social Feed',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _handleManualSeed(context),
            tooltip: 'Seed Data',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showCreatePostSheet(context),
              backgroundColor: const Color(0xFF4535C1),
              child: const Icon(Icons.add),
            )
          : null,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: feedAsync.when(
            // ── Loading: 3 skeleton cards ─────────────────────────────────
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

            // ── Error ──────────────────────────────────────────────────────
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

            // ── Data: live feed from Firestore ─────────────────────────────
            data: (posts) => ListView.builder(
              itemCount: posts.length + 1,
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

                // Convert PostEntity → Post (old model) for existing widgets
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

class MobileCreatePostTrigger extends StatelessWidget {
  const MobileCreatePostTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = MockDataService.users[1]; // Using Sara Hany for demo

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
          UserAvatar(url: currentUser.avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "What are you working on, ${currentUser.name.split(' ')[0]}?",
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
