import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../utils/responsive_layout.dart';
import 'comment_input.dart';
import 'comment_item.dart';

class CommentSection extends StatelessWidget {
  final Post post;
  final void Function(Comment replyTarget, String topLevelCommentId)? onReplyTap;

  const CommentSection({
    super.key, 
    required this.post,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          const SizedBox(height: 16),
          CommentInput(post: post),
        ],
        if (post.comments.isNotEmpty) const SizedBox(height: 8),
        ...post.comments.map((comment) => CommentItem(
              comment: comment,
              postId: post.id,
              parentCommentId: comment.id,
              onReplyTap: onReplyTap,
            )),
      ],
    );
  }
}

