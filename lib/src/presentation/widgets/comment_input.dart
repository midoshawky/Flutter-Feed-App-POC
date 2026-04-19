import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../../domain/entities/comment_entity.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../services/mock_data_service.dart';
import '../../utils/responsive_layout.dart';
import 'user_avatar.dart';

class CommentInput extends ConsumerStatefulWidget {
  final Post post;
  final bool isReply;
  final String? replyToUsername;
  final String? parentCommentId;
  final VoidCallback? onCancelReply;

  const CommentInput({
    super.key,
    required this.post,
    this.isReply = false,
    this.replyToUsername,
    this.parentCommentId,
    this.onCancelReply,
  });

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    _commentController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    final comment = CommentEntity(
      id: '', // Firestore will generate
      userId: '2', // Sara Hany
      userName: MockDataService.users[1].name,
      text: text,
      timestamp: DateTime.now(),
    );

    try {
      if (widget.isReply && widget.parentCommentId != null) {
        await ref
            .read(optimisticFeedProvider.notifier)
            .addReply(widget.post.id, widget.parentCommentId!, comment);
      } else {
        await ref
            .read(optimisticFeedProvider.notifier)
            .addComment(widget.post.id, comment);
      }
      _commentController.clear();
      if (mounted && widget.isReply) {
        if (widget.onCancelReply != null) widget.onCancelReply!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding comment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final user = MockDataService.users[1]; // Sara Hany

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            if (!widget.isReply) ...[
              UserAvatar(url: user.avatarUrl, radius: 22),
              const SizedBox(width: 8),
            ],
            if (widget.isReply && widget.replyToUsername != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '@${widget.replyToUsername}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF4535C1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (widget.onCancelReply != null)
                          widget.onCancelReply!();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF4535C1),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: widget.isReply
                      ? 'Write a reply...'
                      : 'Write a comment...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF787878),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4535C1),
                foregroundColor: const Color(0xFFF5F5F5),
                fixedSize: Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                    : const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : isMobile
                  ? Icon(Icons.send_rounded)
                  : Text(
                      'Comment',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    // Default (inline/web)

    return Row(
      children: [
        UserAvatar(url: user.avatarUrl, radius: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 12),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 1,

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
                ),
                if (_commentController.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: ElevatedButton(
                      onPressed: _isLoading || _commentController.text.isEmpty
                          ? null
                          : _submitComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4535C1),
                        foregroundColor: const Color(0xFFF5F5F5),
                        fixedSize: Size.fromHeight(35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Comment',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
