import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/comment.dart';
import '../../domain/entities/comment_entity.dart';
import '../providers/di_providers.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../utils/responsive_layout.dart';
import 'report_dialog.dart';
import 'user_avatar.dart';

class CommentItem extends ConsumerStatefulWidget {
  final Comment comment;
  final bool isReply;

  /// Post ID needed to dispatch to the provider
  final String postId;

  /// User ID of the post author — used to determine delete permission for post owners.
  final String postOwnerId;

  /// ID of the direct parent comment (for nested replies, this is the top-level comment ID)
  final String parentCommentId;
  final void Function(Comment replyTarget, String topLevelCommentId)?
  onReplyTap;
  final String? replyingToId;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.postOwnerId,
    required this.parentCommentId,
    this.isReply = false,
    this.onReplyTap,
    this.replyingToId,
  });

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  bool _showReplies = false;
  bool _showReplyInput = false;
  bool _isEditing = false;
  final TextEditingController _replyController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();
  final FocusNode _editFocus = FocusNode();

  @override
  void dispose() {
    _replyController.dispose();
    _editController.dispose();
    _replyFocus.dispose();
    _editFocus.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    final text = _editController.text.trim();
    if (text.isEmpty || text == widget.comment.text) {
      setState(() => _isEditing = false);
      return;
    }
    try {
      await ref
          .read(optimisticFeedProvider.notifier)
          .updateComment(widget.postId, widget.comment.id, text);
      if (mounted) setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error updating: $e')));
      }
    }
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

    final reply = CommentEntity(
      id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
      userId: ref.read(currentUserIdProvider),
      userName: ref.read(currentUserNameProvider),
      userUsername: ref.read(currentUserUsernameProvider),
      userAvatarUrl: ref.read(currentUserAvatarUrlProvider) ?? '',
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
    final avatarUrl = widget.comment.userAvatarUrl;
    final handle = widget.comment.userUsername.isNotEmpty
        ? '@${widget.comment.userUsername}'
        : '';
    final currentUserId = ref.read(currentUserIdProvider);
    final isCommentOwner = widget.comment.userId == currentUserId;
    final isPostOwner = widget.postOwnerId == currentUserId;
    final isPending = widget.comment.id.startsWith('pending-');

    final isHighlighted = widget.replyingToId == widget.comment.id;

    return Container(
      color: isHighlighted ? const Color(0xFFF3F3FF) : Colors.transparent,
      padding: EdgeInsets.only(
        top: 16,
        left: widget.isReply ? 48 : 16,
        right: 16,
        bottom: isHighlighted ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Comment bubble ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 8),child:UserAvatar(url: avatarUrl, radius: 20, name: widget.comment.userName),),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          widget.comment.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: widget.isReply ? 12 : 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          handle,
                          style: TextStyle(
                            color: const Color(0xFF787878),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '• ${_getTimeAgo(widget.comment.timestamp)}',
                          style: TextStyle(
                            color: const Color(0xFF787878),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Color(0xFF787878),
                          ),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          position: PopupMenuPosition.under,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'delete') {
                              ref
                                  .read(optimisticFeedProvider.notifier)
                                  .deleteComment(
                                    widget.postId,
                                    widget.comment.id,
                                  );
                            } else if (value == 'edit') {
                              setState(() {
                                _isEditing = true;
                                _editController.text = widget.comment.text;
                              });
                              Future.microtask(() => _editFocus.requestFocus());
                            } else if (value == 'report') {
                              showReportSheet(
                                context,
                                ref,
                                targetId: widget.comment.id,
                                type: ReportType.comment,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            if (isCommentOwner && !isPending) ...[
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
                                    const Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1F1F1F),
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
                                    const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (!isCommentOwner && isPostOwner) ...[
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
                                    const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/report.svg',
                                      package: 'feed_module',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Report',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (!isCommentOwner && !isPostOwner) ...[
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/report.svg',
                                      package: 'feed_module',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Report',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    // Comment text / inline edit field
                    if (_isEditing)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDEDEDE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _editController,
                                focusNode: _editFocus,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1F1F1F),
                                ),
                                maxLines: null,
                                onSubmitted: (_) => _submitEdit(),
                              ),
                            ),
                            GestureDetector(
                              onTap: _submitEdit,
                              child: const Icon(Icons.send,
                                  size: 18, color: Color(0xFF4535C1)),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isEditing = false),
                              child: const Icon(Icons.close,
                                  size: 18, color: Color(0xFF787878)),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        widget.comment.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F1F1F),
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Reply / view-replies row — hidden while editing
                    if (!_isEditing)
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
                            style: TextStyle(
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
                                    style: TextStyle(
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
                  UserAvatar(
                    url: ref.read(currentUserAvatarUrlProvider) ?? '',
                    radius: 16,
                    name: ref.read(currentUserNameProvider),
                  ),
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
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF787878),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(
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
                postOwnerId: widget.postOwnerId,
                // Replies always point to the top-level comment, not themselves,
                // so the provider can find the correct parent.
                parentCommentId: widget.parentCommentId,
                isReply: true,
                onReplyTap: widget.onReplyTap,
                replyingToId: widget.replyingToId,
              ),
            ),
        ],
      ),
    );
  }
}
