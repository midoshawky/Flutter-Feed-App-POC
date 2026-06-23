const _videoExtensions = {'mp4', 'mov', 'm4v', 'webm', 'avi', 'mkv'};

bool isVideoUrl(String url) {
  final withoutQuery = url.split('?').first;
  final dotIndex = withoutQuery.lastIndexOf('.');
  if (dotIndex == -1) return false;
  final extension = withoutQuery.substring(dotIndex + 1).toLowerCase();
  return _videoExtensions.contains(extension);
}
