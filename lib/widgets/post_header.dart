import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'user_avatar.dart';

class PostHeader extends StatelessWidget {
  final User user;
  final DateTime timestamp;

  const PostHeader({super.key, required this.user, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(url: user.avatarUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${user.username} • ${DateFormat.jm().format(timestamp)}',
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
      ],
    );
  }
}
