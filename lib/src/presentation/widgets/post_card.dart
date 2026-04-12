import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../services/mock_data_service.dart';
import '../../utils/responsive_layout.dart';
import 'post_header.dart';
import 'post_content.dart';
import 'post_actions.dart';
import 'comment_section.dart';
import 'comment_input.dart';
import 'repost_preview_card.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;

  void _showCommentSheet(BuildContext context) {
    Comment? replyingTo;
    String? topLevelCommentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CommentSection(
                      post: widget.post,
                      onReplyTap: (replyTarget, topLevelId) {
                        setSheetState(() {
                          replyingTo = replyTarget;
                          topLevelCommentId = topLevelId;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: CommentInput(
                    post: widget.post,
                    isReply: replyingTo != null,
                    replyToUsername: replyingTo?.userName.replaceAll(' ', ''),
                    parentCommentId: topLevelCommentId,
                    onCancelReply: () {
                      setSheetState(() {
                        replyingTo = null;
                        topLevelCommentId = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.getUserById(widget.post.userId);
    final isMobile = ResponsiveLayout.isMobile(context);

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
            if (widget.post.content.isNotEmpty &&
                widget.post.repostedFrom != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.post.content,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFF1F1F1F)),
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
                if (isMobile) {
                  _showCommentSheet(context);
                } else {
                  setState(() {
                    _showComments = !_showComments;
                  });
                }
              },
            ),
            if (!isMobile && _showComments) CommentSection(post: widget.post),
          ],
        ),
      ),
    );
  }
}
