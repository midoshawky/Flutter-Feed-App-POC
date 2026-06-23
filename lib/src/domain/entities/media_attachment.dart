import 'dart:typed_data';
import 'post_entity.dart';

class MediaAttachment {
  final Uint8List bytes;
  final bool isVideo;

  const MediaAttachment({required this.bytes, required this.isVideo});
}

PostTypeEntity resolvePostType({
  required int totalMediaCount,
  required bool hasVideo,
}) {
  if (hasVideo) return PostTypeEntity.video;
  if (totalMediaCount == 0) return PostTypeEntity.text;
  if (totalMediaCount == 1) return PostTypeEntity.image;
  return PostTypeEntity.multiImage;
}
