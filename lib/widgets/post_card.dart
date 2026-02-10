import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/mock_data_service.dart';
import 'post_header.dart';
import 'post_content.dart';
import 'post_actions.dart';
import 'comment_section.dart';

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
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              PostHeader(user: user, timestamp: widget.post.timestamp),
            const SizedBox(height: 12),
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
