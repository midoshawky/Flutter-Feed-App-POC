import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/post.dart';
import 'post_media.dart';

class PostContent extends StatefulWidget {
  final Post post;

  const PostContent({super.key, required this.post});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  bool _expanded = false;

  static const int _charThreshold = 300;
  static const int _maxLines = 5;

  bool get _needsExpansion =>
      widget.post.content.length > _charThreshold;

  List<TextSpan> _buildTextSpans(String text) {
    final words = text.split(' ');
    return words.map((word) {
      if (word.startsWith('#')) {
        return TextSpan(
          text: '$word ',
          style: TextStyle(
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
        style: TextStyle(
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
        if (widget.post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: _buildTextSpans(widget.post.content),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4535C1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.post.type != PostType.text) PostMedia(post: widget.post),
      ],
    );
  }
}
