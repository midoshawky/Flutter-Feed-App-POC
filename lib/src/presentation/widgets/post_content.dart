import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import 'post_media.dart';

class PostContent extends StatelessWidget {
  final Post post;

  const PostContent({super.key, required this.post});

  List<TextSpan> _buildTextSpans(String text) {
    final words = text.split(' ');
    return words.map((word) {
      if (word.startsWith('#')) {
        return TextSpan(
          text: '$word ',
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFF4535C1),
            fontWeight: FontWeight.w500,
          ),
          recognizer: TapGestureRecognizer()..onTap = () {},
        );
      }
      return TextSpan(
        text: '$word ',
        style: GoogleFonts.inter(
          fontSize: 15,
          height: 1.5,
          color: const Color(0xFF1F1F1F),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: RichText(
              text: TextSpan(children: _buildTextSpans(post.content)),
            ),
          ),
        if (post.type != PostType.text) PostMedia(post: post),
      ],
    );
  }
}
