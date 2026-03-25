import 'package:flutter/material.dart';
import 'package:flutter_feed_poc/models/post.dart';
import 'package:flutter_feed_poc/services/mock_data_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_media.dart';
import 'user_avatar.dart';

/// A compact read-only card that embeds the original post inside a repost.
class RepostPreviewCard extends StatelessWidget {
  final Post post;

  const RepostPreviewCard({super.key, required this.post});

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.getUserById(post.userId);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) UserAvatar(url: user.avatarUrl, radius: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: [
                    Text(
                      user?.name ?? 'Unknown',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '${user?.username ?? ''} • ${_getTimeAgo(post.timestamp)}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF787878),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Text content
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              post.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1F1F1F),
                height: 1.5,
              ),
            ),
          ],

          // Media
          if (post.type != PostType.text) ...[
            const SizedBox(height: 8),
            PostMedia(post: post),
          ],
        ],
      ),
    );
  }
}
