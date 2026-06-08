import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../utils/responsive_layout.dart';
import '../providers/optimistic_feed_provider.dart';
import 'comment_input.dart';
import 'comment_item.dart';
import 'post_card_skeleton.dart';

class CommentSection extends ConsumerWidget {
  final Post post;
  final void Function(Comment replyTarget, String topLevelCommentId)? onReplyTap;
  final String? replyingToId;

  const CommentSection({
    super.key,
    required this.post,
    this.onReplyTap,
    this.replyingToId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isLoading = ref
        .watch(optimisticFeedProvider.notifier)
        .isLoadingCommentsForPost(post.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          const SizedBox(height: 16),
          CommentInput(post: post),
        ],
        if (isLoading) ...[
          const SizedBox(height: 8),
          const _CommentItemSkeleton(),
          const _CommentItemSkeleton(),
          const _CommentItemSkeleton(),
        ] else ...[
          if (post.comments.isNotEmpty) const SizedBox(height: 8),
          ...post.comments.map((comment) => CommentItem(
                comment: comment,
                postId: post.id,
                postOwnerId: post.userId,
                parentCommentId: comment.id,
                onReplyTap: onReplyTap,
                replyingToId: replyingToId,
              )),
        ],
      ],
    );
  }
}

class _CommentItemSkeleton extends StatelessWidget {
  const _CommentItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 40, height: 40, borderRadius: 100),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: const [
                    ShimmerBox(width: 80, height: 10, borderRadius: 8),
                    SizedBox(width: 8),
                    ShimmerBox(width: 60, height: 10, borderRadius: 8),
                  ],
                ),
                const SizedBox(height: 8),
                const ShimmerBox(
                    width: double.infinity, height: 10, borderRadius: 8),
                const SizedBox(height: 6),
                const ShimmerBox(width: 160, height: 10, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
