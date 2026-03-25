import 'package:flutter/material.dart';
import '../../models/post.dart';
import 'comment_input.dart';
import 'comment_item.dart';

class CommentSection extends StatelessWidget {
  final Post post;

  const CommentSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        CommentInput(post: post),
        if (post.comments.isNotEmpty) const SizedBox(height: 8),
        ...post.comments.map((comment) => CommentItem(
              comment: comment,
              postId: post.id,
              parentCommentId: comment.id,
            )),
      ],
    );
  }
}
