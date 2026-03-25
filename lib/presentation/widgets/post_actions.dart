import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../providers/di_providers.dart';
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
              icon: Icons.chat_bubble_outline,
              count: post.comments.length,
              color: const Color(0xFF1F1F1F),
              onTap: onCommentPressed,
            ),
            const SizedBox(width: 24),
            _ActionButton(
              icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
              count: post.likesCount,
              color: post.isLiked ? const Color(0xFFF64C4C) : const Color(0xFF1F1F1F),
              onTap: () => ref.read(toggleLikeUseCaseProvider).call(post.id, post.isLiked),
            ),
            const SizedBox(width: 24),
            _ActionButton(
              icon: Icons.repeat,
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
  final IconData icon;
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
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
