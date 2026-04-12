import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../providers/optimistic_feed_provider.dart';
import 'repost_dialog.dart';

class PostActions extends ConsumerWidget {
  final Post post;
  final VoidCallback onCommentPressed;

  const PostActions({
    super.key,
    required this.post,
    required this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Color(0xFFDEDEDE), thickness: 1, height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _ActionButton(
              icon: SvgPicture.asset(
                "assets/icons/comment.svg",
                package: 'feed_module',
              ),
              count: post.comments.length,
              color: const Color(0xFF1F1F1F),
              onTap: onCommentPressed,
            ),
            const SizedBox(width: 24),
            _ActionButton(
              icon: post.isLiked
                  ? SvgPicture.asset(
                      "assets/icons/heart_like_filled.svg",
                      package: 'feed_module',
                    )
                  : SvgPicture.asset(
                      "assets/icons/heart_like.svg",
                      package: 'feed_module',
                    ),
              count: post.likesCount,
              color: post.isLiked
                  ? const Color(0xFFF64C4C)
                  : const Color(0xFF1F1F1F),
              onTap: () => ref
                  .read(optimisticFeedProvider.notifier)
                  .toggleLike(post.id, post.isLiked),
            ),
            const SizedBox(width: 24),
            _ActionButton(
              icon: SvgPicture.asset(
                "assets/icons/repost.svg",
                package: 'feed_module',
              ),
              count: post.repostsCount,
              color: const Color(0xFF333333),
              onTap: () => showRepostDialog(context, ref, post),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 4),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
