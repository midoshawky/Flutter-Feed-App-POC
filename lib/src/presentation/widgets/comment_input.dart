import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../../domain/entities/comment_entity.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../services/mock_data_service.dart';
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

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final comment = CommentEntity(
      id: '', // Firestore will generate
      userId: '2', // Sara Hany
      userName: MockDataService.users[1].name,
      text: text,
      timestamp: DateTime.now(),
    );

    try {
      await ref.read(optimisticFeedProvider.notifier).addComment(widget.post.id, comment);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.users[1]; // Sara Hany

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
