import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/feed_providers.dart';
import '../widgets/post_card.dart';
import '../widgets/post_card_skeleton.dart';
import '../widgets/create_post_card.dart';
import '../../services/firestore_seed_service.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedStreamProvider);

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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: feedAsync.when(
            // ── Loading: 3 skeleton cards ─────────────────────────────────
            loading: () => ListView.builder(
              itemCount: 4,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (_, i) =>
                  i == 0 ? const CreatePostCard() : const PostCardSkeleton(),
            ),

            // ── Error ──────────────────────────────────────────────────────
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: Color(0xFF787878)),
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
                if (index == 0) return const CreatePostCard();

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
