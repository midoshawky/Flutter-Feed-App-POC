import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../utils/media_type_util.dart';
import 'image_slider_preview.dart';
import 'video_player_widget.dart';

class PostMedia extends StatelessWidget {
  final Post post;

  const PostMedia({super.key, required this.post});

  List<String> get _mediaUrls => post.mediaUrls.isNotEmpty
      ? post.mediaUrls
      : (post.imageUrl != null ? [post.imageUrl!] : const []);

  void _openSlider(BuildContext context, List<String> urls, int index) {
    showDialog(
      context: context,

      builder: (context) =>
          ImageSliderPreview(imageUrls: urls, initialIndex: index),
    );
  }

  Widget _buildSingleMedia(
    BuildContext context,
    String url, {
    bool isVideo = false,
  }) {
    if (isVideo) {
      return VideoPlayerWidget(url: url);
    }
    return GestureDetector(
      onTap: () => _openSlider(context, [url], 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
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
                  child: urls.length > 3
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildCroppedImage(
                              context,
                              urls,
                              2,
                              BorderRadius.only(
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            GestureDetector(child:ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(16),
                              ),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                alignment: Alignment.center,
                                child: Text(
                                  '+${urls.length - 3}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),onTap : ()=> _openSlider(context, urls, 2))
                          ],
                        )
                      : _buildCroppedImage(
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
    final url = urls[index];
    final Widget thumbnail = isVideoUrl(url)
        ? Container(
            color: Colors.black87,
            alignment: Alignment.center,
            child: const Icon(Icons.play_circle_fill,
                color: Colors.white, size: 40),
          )
        : Image.network(
            url,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
          );

    return GestureDetector(
      onTap: () => _openSlider(context, urls, index),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: thumbnail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = _mediaUrls;
    if (urls.isEmpty) return const SizedBox.shrink();
    if (urls.length == 1) {
      return _buildSingleMedia(context, urls.first, isVideo: isVideoUrl(urls.first));
    }
    return _buildMediaGrid(context, urls);
  }
}
