import 'package:flutter/material.dart';
import 'web_safe_image.dart';

class UserAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const UserAvatar({super.key, required this.url, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? const Icon(Icons.person, color: Colors.grey)
            : WebSafeImage(
                url: url,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: const Icon(Icons.person, color: Colors.grey),
              ),
      ),
    );
  }
}
