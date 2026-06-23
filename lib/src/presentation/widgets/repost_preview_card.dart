import 'package:feed_module/src/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:feed_module/src/models/post.dart';
import 'package:feed_module/src/services/mock_data_service.dart';
import 'post_media.dart';
import 'user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/di_providers.dart';
import '../providers/optimistic_feed_provider.dart';

/// A compact read-only card that embeds the original post inside a repost.
class RepostPreviewCard extends ConsumerStatefulWidget {
  final Post post;

  const RepostPreviewCard({super.key, required this.post});

  @override
  ConsumerState<RepostPreviewCard> createState() => _RepostPreviewCardState();
}

class _RepostPreviewCardState extends ConsumerState<RepostPreviewCard> {
  bool _expanded = false;

  static const int _charThreshold = 300;
  static const int _maxLines = 4;

  bool get _needsExpansion => widget.post.content.length > _charThreshold;

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final user = post.user ?? MockDataService.getUserById(post.userId);
    final currentUserId = ref.watch(currentUserIdProvider);
    final isCurrentUser = user?.id == currentUserId;
    final isMobile = ResponsiveLayout.isMobile(context);
    final isFollowing = user?.isFollowing ?? false;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(url: user?.avatarUrl ?? ''),
                  if (isMobile && !isCurrentUser && user != null)
                    Positioned(
                      bottom: 0,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => ref.read(optimisticFeedProvider.notifier).toggleFollow(user.id, isFollowing),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isFollowing ? Colors.grey : const Color(0xFF4535C1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFollowing ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isMobile
                                ? '• ${_getTimeAgo(post.timestamp)}'
                                : '${user?.username} • ${_getTimeAgo(post.timestamp)}',
                            style: const TextStyle(
                              color: Color(0xFF787878),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isMobile) const SizedBox(height: 2),
                    if (isMobile)
                      Text(
                        user?.username ?? 'Unknown',
                        style: const TextStyle(
                          color: Color(0xFF787878),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMobile && !isCurrentUser && user != null)
                    TextButton.icon(
                      onPressed: () => ref.read(optimisticFeedProvider.notifier).toggleFollow(user.id, isFollowing),
                      icon: Icon(
                        isFollowing ? Icons.check_rounded : Icons.add_rounded,
                        color: isFollowing ? Colors.grey : const Color(0xFF4535C1),
                        size: 20,
                      ),
                      label: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: isFollowing ? Colors.grey : const Color(0xFF4535C1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // ...

          // Text content
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F1F1F),
                height: 1.5,
              ),
              maxLines: _needsExpansion && !_expanded ? _maxLines : null,
              overflow: _needsExpansion && !_expanded
                  ? TextOverflow.ellipsis
                  : TextOverflow.clip,
            ),
            if (_needsExpansion)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? 'See less' : 'See more',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4535C1),
                    ),
                  ),
                ),
              ),
          ],

          // Media
          if (post.mediaUrls.isNotEmpty || post.imageUrl != null) ...[
            const SizedBox(height: 8),
            PostMedia(post: post),
          ],
        ],
      ),
    );
  }
}
