import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(url: user.avatarUrl),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      '${user.username} • ${_getTimeAgo(timestamp)}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF787878),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_circle, color: Color(0xFF4535C1), size: 16),
          label: Text(
            'Follow',
            style: GoogleFonts.inter(
              color: const Color(0xFF4535C1),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
