import 'package:feed_module/feed_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../utils/responsive_layout.dart';
import 'user_avatar.dart';

class PostHeader extends StatelessWidget {
  final User user;
  final DateTime timestamp;

  const PostHeader({super.key, required this.user, required this.timestamp});

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isCurrentUser = user.id == '2';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(url: user.avatarUrl),
            if (isMobile && !isCurrentUser)
              Positioned(
                bottom: 0,
                right: -4,
                child: GestureDetector(
                  onTap: () {}, // TODO: follow logic
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4535C1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
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
                    user.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      isMobile
                          ? '• ${_getTimeAgo(timestamp)}'
                          : '${user.username} • ${_getTimeAgo(timestamp)}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF787878),
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
                  user.username,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF787878),
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
                onPressed: () {},
                icon: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF4535C1),
                  size: 20,
                ),
                label: Text(
                  'Follow',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4535C1),
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
              onSelected: (value) {},
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
                      Text(
                        'Copy link',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF1F1F1F),
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
                        Text(
                          'Report',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF1F1F1F),
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
