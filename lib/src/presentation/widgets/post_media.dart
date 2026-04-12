import 'package:flutter/material.dart';
import '../../models/post.dart';
import 'image_slider_preview.dart';

class PostMedia extends StatelessWidget {
  final Post post;

  const PostMedia({super.key, required this.post});

  void _openSlider(BuildContext context, List<String> urls, int index) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ImageSliderPreview(imageUrls: urls, initialIndex: index);
      },
    );
  }

  Widget _buildSingleMedia(
    BuildContext context,
    String url, {
    bool isVideo = false,
  }) {
    return GestureDetector(
      onTap: isVideo ? null : () => _openSlider(context, [url], 0),
      child: Stack(
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
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<String> urls) {
    if (urls.length == 2) {
      return SizedBox(
        height: 320,
        child: Row(
          children: [
            Expanded(
              child: _buildCroppedImage(
                context,
                urls,
                0,
                BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildCroppedImage(
                context,
                urls,
                1,
                BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Grid calculation for more than 2 elements
    return SizedBox(
      height: 320,
      child: Row(
        children: [
          Expanded(
            child: _buildCroppedImage(
              context,
              urls,
              0,
              BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildCroppedImage(
                    context,
                    urls,
                    1,
                    BorderRadius.only(topRight: Radius.circular(16)),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildCroppedImage(
                    context,
                    urls,
                    2,
                    BorderRadius.only(bottomRight: Radius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCroppedImage(
    BuildContext context,
    List<String> urls,
    int index,
    BorderRadius borderRadius,
  ) {
    return GestureDetector(
      onTap: () => _openSlider(context, urls, index),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          urls[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (post.type == PostType.image &&
        post.imageUrl != null &&
        post.mediaUrls.isEmpty) {
      return _buildSingleMedia(context, post.imageUrl!);
    } else if (post.type == PostType.video && post.imageUrl != null) {
      return _buildSingleMedia(context, post.imageUrl!, isVideo: true);
    } else if (post.mediaUrls.isNotEmpty) {
      if (post.mediaUrls.length == 1) {
        return _buildSingleMedia(context, post.mediaUrls.first);
      }
      return _buildMediaGrid(context, post.mediaUrls);
    }
    return const SizedBox.shrink();
  }
}
