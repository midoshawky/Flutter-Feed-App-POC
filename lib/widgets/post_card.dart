import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/mock_data_service.dart';
import 'post_header.dart';
import 'post_content.dart';
import 'post_actions.dart';
import 'comment_section.dart';
import 'repost_preview_card.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.getUserById(widget.post.userId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDEDEDE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              PostHeader(user: user, timestamp: widget.post.timestamp),
            const SizedBox(height: 12),
            // Reposter's own added text (if any)
            if (widget.post.content.isNotEmpty && widget.post.repostedFrom != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.post.content,
                  style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF1F1F1F)),
                ),
              ),
            // Embedded original post card (repost)
            if (widget.post.repostedFrom != null)
              RepostPreviewCard(post: widget.post.repostedFrom!)
            else
              PostContent(post: widget.post),
            PostActions(
              post: widget.post,
              onCommentPressed: () {
                setState(() {
                  _showComments = !_showComments;
                });
              },
            ),
            if (_showComments) CommentSection(post: widget.post),
          ],
        ),
      ),
    );
  }
}
