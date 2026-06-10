import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final String? name;

  const UserAvatar({super.key, required this.url, this.radius = 20, this.name});

  String _initials() {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}'.toUpperCase();
  }

  Color _avatarColor() {
    const colors = [
      Color(0xFF4535C1),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
    ];
    final n = name ?? '';
    return n.isEmpty ? const Color(0xFF9E9E9E) : colors[n.codeUnitAt(0) % colors.length];
  }

  Widget _fallback() {
    final initials = _initials();
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: initials.isEmpty ? Colors.grey[200] : Color(0xFF4833c7),
      child: initials.isEmpty
          ? Icon(Icons.person, color: Colors.grey, size: radius)
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.75,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url.isEmpty
          ? _fallback()
          : Image.network(
              url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, __, ___) => _fallback(),
            ),
    );
  }
}
