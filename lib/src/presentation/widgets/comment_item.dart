import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/comment.dart';
import '../../domain/entities/comment_entity.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../services/mock_data_service.dart';
import '../../utils/responsive_layout.dart';
import 'user_avatar.dart';

class CommentItem extends ConsumerStatefulWidget {
  final Comment comment;
  final bool isReply;

  /// Post ID needed to dispatch to the provider
  final String postId;

  /// ID of the direct parent comment (for nested replies, this is the top-level comment ID)
  final String parentCommentId;
  final void Function(Comment replyTarget, String topLevelCommentId)?
  onReplyTap;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.parentCommentId,
    this.isReply = false,
    this.onReplyTap,
  });

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  bool _showReplies = false;
  bool _showReplyInput = false;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final currentUser = MockDataService.users[1]; // Sara Hany
    final reply = CommentEntity(
      id: '', // Firestore will generate
      userId: currentUser.id,
      userName: currentUser.name,
      text: text,
      timestamp: DateTime.now(),
    );

    try {
      await ref
          .read(optimisticFeedProvider.notifier)
          .addReply(widget.postId, widget.parentCommentId, reply);

      _replyController.clear();
      if (mounted) {
        setState(() {
          _showReplyInput = false;
          _showReplies = true; // auto-expand to show the new reply
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error replying: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.getUserById(widget.comment.userId);
    final avatarUrl = user?.avatarUrl ?? 'https://i.pravatar.cc/150';
    final handle = user?.username ?? '@user';
    final currentUser = MockDataService.users[1]; // Sara Hany
    final isCurrentUser = currentUser.id == '2';

    return Padding(
      padding: EdgeInsets.only(top: 16, left: widget.isReply ? 48 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Comment bubble ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(url: avatarUrl, radius: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author row
                    Row(
                      spacing: 4,
                      children: [
                        Text(
                          widget.comment.userName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: widget.isReply ? 12 : 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          handle,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF787878),
                            fontSize: widget.isReply ? 12 : 12,
                          ),
                        ),
                        Text(
                          '• ${_getTimeAgo(widget.comment.timestamp)}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF787878),
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrentUser)
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Color(0xFF787878),
                            ),
                            padding: EdgeInsets.zero,
                            position: PopupMenuPosition.under,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {},
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/edit.svg',
                                      package: 'feed_module',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Edit',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/delete.svg',
                                      package: 'feed_module',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Comment text
                    Text(
                      widget.comment.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1F1F1F),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Reply tap
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (ResponsiveLayout.isMobile(context)) {
                              if (widget.onReplyTap != null) {
                                widget.onReplyTap!(
                                  widget.comment,
                                  widget.parentCommentId,
                                );
                              }
                            } else {
                              setState(() {
                                _showReplyInput = !_showReplyInput;
                              });
                              if (_showReplyInput) {
                                Future.microtask(
                                  () => _replyFocus.requestFocus(),
                                );
                              }
                            }
                          },
                          child: Text(
                            'Reply',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4535C1),
                            ),
                          ),
                        ),
                        if (widget.comment.replies.isNotEmpty)
                          Text(
                            " • ",
                            style: TextStyle(color: const Color(0xFF787878)),
                          ), // ── View Replies toggle ─────────────────────────────────────────
                        if (widget.comment.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _showReplies = !_showReplies),
                              child: Row(
                                children: [
                                  Text(
                                    _showReplies
                                        ? 'Hide ${widget.comment.replies.length} repl${widget.comment.replies.length == 1 ? 'y' : 'ies'}'
                                        : 'View ${widget.comment.replies.length} repl${widget.comment.replies.length == 1 ? 'y' : 'ies'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF787878),
                                    ),
                                  ),
                                  Icon(
                                    _showReplies
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: const Color(0xFF787878),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Inline reply input ──────────────────────────────────────────
          if (_showReplyInput)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(url: currentUser.avatarUrl, radius: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              focusNode: _replyFocus,
                              decoration: InputDecoration(
                                hintText:
                                    'Reply to ${widget.comment.userName.split(' ')[0]}…',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF787878),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF1F1F1F),
                              ),
                              onSubmitted: (_) => _submitReply(),
                            ),
                          ),
                          GestureDetector(
                            onTap: _submitReply,
                            child: const Icon(
                              Icons.send,
                              size: 18,
                              color: Color(0xFF4535C1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Expanded replies ────────────────────────────────────────────
          if (_showReplies)
            ...widget.comment.replies.map(
              (reply) => CommentItem(
                comment: reply,
                postId: widget.postId,
                // Replies always point to the top-level comment, not themselves,
                // so the provider can find the correct parent.
                parentCommentId: widget.parentCommentId,
                isReply: true,
                onReplyTap: widget.onReplyTap,
              ),
            ),
        ],
      ),
    );
  }
}
