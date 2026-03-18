import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/feed_provider.dart';
import '../services/mock_data_service.dart';
import 'user_avatar.dart';

class CommentInput extends ConsumerStatefulWidget {
  final Post post;

  const CommentInput({super.key, required this.post});

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final comment = Comment(
      userId: '1', 
      userName: MockDataService.users[0].name,
      text: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    ref.read(feedProvider.notifier).addComment(widget.post.id, comment);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.users[0]; // Current user mock

    return Row(
      children: [
        UserAvatar(url: user.avatarUrl, radius: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF787878),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF1F1F1F),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
