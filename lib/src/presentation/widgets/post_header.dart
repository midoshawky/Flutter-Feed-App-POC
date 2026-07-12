import 'package:feed_module/feed_module.dart';
import 'package:feed_module/src/presentation/widgets/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import '../providers/di_providers.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../utils/responsive_layout.dart';
import 'feed_snackbar.dart';
import 'report_dialog.dart';
import 'user_avatar.dart';
import 'create_post_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostHeader extends ConsumerWidget {
  final Post post;

  const PostHeader({super.key, required this.post});

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String targetId) {
    showDeleteSheet(
      context,
      ref,
      targetId: targetId,
      type: DeleteDialogType.post,
      onAction: () {
        Navigator.pop(context);
        ref.read(optimisticFeedProvider.notifier).deletePost(post.id);
        showFeedSnackBar(context, 'Post deleted');
      },
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final container = ProviderScope.containerOf(context);

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,

        backgroundColor: Colors.transparent,
        builder: (context) => UncontrolledProviderScope(
          container: container,
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
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
                    Expanded(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: CreatePostCard(postToEdit: post),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => UncontrolledProviderScope(
          container: container,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            child: SizedBox(
              width: 600,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: CreatePostCard(postToEdit: post),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = post.user!;
    final isMobile = ResponsiveLayout.isMobile(context);
    final isCurrentUser = user.id == ref.read(currentUserIdProvider);
    final isFollowing = user.isFollowing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(url: user.avatarUrl, name: user.name),
            if (isMobile && !isCurrentUser)
              Positioned(
                bottom: 0,
                right: -4,
                child: GestureDetector(
                  onTap: () => ref
                      .read(optimisticFeedProvider.notifier)
                      .toggleFollow(user.id, isFollowing),
                  child: Container(
                    width: 20,
                    height: 20,

                    decoration: BoxDecoration(
                      color: isFollowing
                          ? Colors.grey
                          : const Color(0xFF4535C1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                  Flexible(
                    child: Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      isMobile
                          ? '• ${_getTimeAgo(post.timestamp)}'
                          : '@${user.username} • ${_getTimeAgo(post.timestamp)}',
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
                  '@${user.username}',
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
            if (!isMobile && !isCurrentUser)
              TextButton.icon(
                onPressed: () => ref
                    .read(optimisticFeedProvider.notifier)
                    .toggleFollow(user.id, isFollowing),
                icon: Icon(
                  isFollowing ? Icons.check_rounded : Icons.add_rounded,
                  color: isFollowing ? Colors.grey : const Color(0xFF4535C1),
                  size: 20,
                ),
                label: Text(
                  isFollowing ? 'Following' : 'Make Follow',
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Color(0xFF787878)),
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditSheet(context, ref);
                    break;
                  case 'copy':
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            'https://dev-front-shuwier.pomac.info/timeline?postId=${post.id}',
                      ),
                    );
                    showFeedSnackBar(context, 'Link copied to clipboard');
                    break;
                  case 'delete':
                    _showDeleteDialog(context, ref, post.id);
                    break;
                  case 'report':
                    showReportSheet(
                      context,
                      ref,
                      targetId: post.id,
                      type: ReportType.post,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                if (isCurrentUser) ...[
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
                ],
                PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/copy.svg',
                        package: 'feed_module',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Copy link',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser) ...[
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
                if (!isCurrentUser) ...[
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
      ],
    );
  }
}
