import 'package:flutter/material.dart';
import '../../models/post.dart';

class PostMedia extends StatelessWidget {
  final Post post;

  const PostMedia({super.key, required this.post});

  Widget _buildSingleMedia(String url, {bool isVideo = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            height: 320,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              height: 320,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.error, color: Colors.grey),
            ),
          ),
        ),
        if (isVideo)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
          ),
      ],
    );
  }

  Widget _buildMediaGrid(List<String> urls) {
    if (urls.length == 2) {
      return SizedBox(
        height: 320,
        child: Row(
          children: [
            Expanded(child: _buildCroppedImage(urls[0], BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
            const SizedBox(width: 4),
            Expanded(child: _buildCroppedImage(urls[1], BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)))),
          ],
        ),
      );
    }
    
    // Grid calculation for more than 2 elements
    return SizedBox(
      height: 320,
      child: Row(
        children: [
          Expanded(child: _buildCroppedImage(urls[0], BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildCroppedImage(urls[1], BorderRadius.only(topRight: Radius.circular(16)))),
                const SizedBox(height: 4),
                Expanded(child: _buildCroppedImage(urls[2], BorderRadius.only(bottomRight: Radius.circular(16)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCroppedImage(String url, BorderRadius borderRadius) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (post.type == PostType.image && post.imageUrl != null && post.mediaUrls.isEmpty) {
      return _buildSingleMedia(post.imageUrl!);
    } else if (post.type == PostType.video && post.imageUrl != null) {
      return _buildSingleMedia(post.imageUrl!, isVideo: true);
    } else if (post.mediaUrls.isNotEmpty) {
      if (post.mediaUrls.length == 1) {
        return _buildSingleMedia(post.mediaUrls.first);
      }
      return _buildMediaGrid(post.mediaUrls);
    }
    return const SizedBox.shrink();
  }
}
