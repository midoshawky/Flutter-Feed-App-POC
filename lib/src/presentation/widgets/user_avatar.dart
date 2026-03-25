import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const UserAvatar({super.key, required this.url, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: NetworkImage(url),
      child: url.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
    );
  }
}
