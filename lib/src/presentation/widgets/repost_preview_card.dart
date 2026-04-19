import 'package:feed_module/src/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:feed_module/src/models/post.dart';
import 'package:feed_module/src/services/mock_data_service.dart';
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
    final isCurrentUser = user?.id == '2';
    final isMobile = ResponsiveLayout.isMobile(context);

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(url: user?.avatarUrl ?? ''),
                  if (isMobile && !isCurrentUser)
                    Positioned(
                      bottom: 0,
                      right: -4,
                      child: GestureDetector(
                        onTap: () {}, // TODO: follow logic
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4535C1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?.name ?? 'Unknown',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isMobile
                                ? '• ${_getTimeAgo(post.timestamp)}'
                                : '${user?.username} • ${_getTimeAgo(post.timestamp)}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF787878),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isMobile) const SizedBox(height: 2),
                    if (isMobile)
                      Text(
                        user?.username ?? 'Unknown',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF787878),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMobile && !isCurrentUser)
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF4535C1),
                        size: 20,
                      ),
                      label: Text(
                        'Follow',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4535C1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
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
