import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../providers/feed_provider.dart';

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
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                count: post.likesCount,
                color: post.isLiked ? Colors.red : Colors.grey[700],
                onTap: () =>
                    ref.read(feedProvider.notifier).toggleLike(post.id),
              ),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Comment',
                count: post.comments.length,
                color: Colors.grey[700],
                onTap: onCommentPressed,
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                color: Colors.grey[700],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality mocked!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              count != null ? '$count' : label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: color,
                fontWeight: count != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
