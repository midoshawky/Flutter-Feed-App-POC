import 'dart:typed_data';
import 'package:feed_module/feed_module.dart';
import 'package:feed_module/src/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertagger/fluttertagger.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/post_dto.dart';
import '../../domain/entities/media_attachment.dart';
import '../../domain/entities/post_entity.dart';
import '../../utils/media_type_util.dart';
import '../providers/di_providers.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../services/mock_data_service.dart';
import 'feed_snackbar.dart';
import 'user_avatar.dart';

/// A single attached media entry, either already on the post being edited
/// or newly picked by the user. Images and video share one ordered list so
/// neither clears the other when attached.
class _PendingMedia {
  final String? existingId;
  final String? existingUrl;
  final Uint8List? bytes;
  final XFile? videoFile;
  final bool isVideo;

  const _PendingMedia.existing({
    required this.existingId,
    required this.existingUrl,
    required this.isVideo,
  })  : bytes = null,
        videoFile = null;

  const _PendingMedia.newImage(this.bytes)
      : existingId = null,
        existingUrl = null,
        videoFile = null,
        isVideo = false;

  const _PendingMedia.newVideo(this.videoFile)
      : existingId = null,
        existingUrl = null,
        bytes = null,
        isVideo = true;
}

class CreatePostCard extends ConsumerStatefulWidget {
  final Post? postToEdit;
  const CreatePostCard({super.key, this.postToEdit});

  @override
  ConsumerState<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends ConsumerState<CreatePostCard> with AutomaticKeepAliveClientMixin {
  late final FlutterTaggerController _controller;
  final int _maxLength = 2000;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final ScrollController attachmentsController = ScrollController();

  // Ordered list of existing + newly picked media (images and video together)
  final List<_PendingMedia> _media = [];

  // Dummy tags
  final List<String> _tags = [
    'flutter',
    'design',
    'development',
    'ui',
    'dart',
    'coding',
  ];
  List<String> _filteredTags = [];
  bool _isSearching = false;
  bool _isHasInput = false;

  @override
  void initState() {
    super.initState();
    _controller = FlutterTaggerController();
    if (widget.postToEdit != null) {
      _controller.text = widget.postToEdit!.content;
      _isHasInput = widget.postToEdit!.content.isNotEmpty;
      final existingUrls = widget.postToEdit!.mediaUrls.isNotEmpty
          ? widget.postToEdit!.mediaUrls
          : (widget.postToEdit!.imageUrl != null
              ? [widget.postToEdit!.imageUrl!]
              : const <String>[]);
      for (var i = 0; i < existingUrls.length; i++) {
        _media.add(_PendingMedia.existing(
          existingId: i < widget.postToEdit!.mediaIds.length
              ? widget.postToEdit!.mediaIds[i]
              : null,
          existingUrl: existingUrls[i],
          isVideo: isVideoUrl(existingUrls[i]),
        ));
      }
    }
    _controller.addListener(() {
      setState(() {
        _isHasInput = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _removeMediaAt(int index) {
    setState(() => _media.removeAt(index));
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      // Read bytes upfront — works on web, iOS, Android, desktop
      final bytes = await Future.wait(picked.map((f) => f.readAsBytes()));
      setState(() {
        _media.addAll(bytes.map((b) => _PendingMedia.newImage(b)));
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        // Only one video per post — replace any previously picked video.
        _media.removeWhere((m) => m.isVideo && m.existingId == null);
        _media.add(_PendingMedia.newVideo(picked));
      });
    }
  }

  void _onSearch(String query, String triggerCharacter) {
    if (triggerCharacter == '#') {
      setState(() {
        _filteredTags = _tags
            .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isSearching = true;
      });
    }
  }

  void _hideOverlay() {
    setState(() {
      _isSearching = false;
    });
  }

  PostTypeEntity _resolveType() {
    return resolvePostType(
      totalMediaCount: _media.length,
      hasVideo: _media.any((m) => m.isVideo),
    );
  }

  Future<void> _handlePost() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _media.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final tags = _controller.tags.map((t) => '#${t.text}').toList();
      final userId = ref.read(currentUserIdProvider);
      final type = _resolveType();

      final existingMediaIds = _media
          .where((m) => m.existingId != null)
          .map((m) => m.existingId!)
          .toList();

      final newMedia = <MediaAttachment>[];
      for (final m in _media) {
        if (m.existingId != null) continue;
        if (m.videoFile != null) {
          newMedia.add(MediaAttachment(
            bytes: await m.videoFile!.readAsBytes(),
            isVideo: true,
          ));
        } else if (m.bytes != null) {
          newMedia.add(MediaAttachment(bytes: m.bytes!, isVideo: false));
        }
      }

      if (widget.postToEdit != null) {
        await ref
            .read(optimisticFeedProvider.notifier)
            .updatePost(
              widget.postToEdit!.id,
              text,
              type: PostDto.typeToString(type),
              existingMediaIds: existingMediaIds,
              newMedia: newMedia,
            );
      } else {
        await ref
            .read(optimisticFeedProvider.notifier)
            .createPost(
              userId: userId.isNotEmpty ? userId : '2',
              content: text,
              type: type,
              tags: tags,
              media: newMedia,
            );
      }

      // Success: Reset state
      _controller.clear();
      _media.clear();
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        showFeedSnackBar(
          context,
          widget.postToEdit != null ? 'Post updated!' : 'Post shared!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserNameProvider);
    final currentUserAvatar = ref.watch(currentUserAvatarUrlProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      margin: isMobile
          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 16)
          : const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isMobile ? null : Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
        boxShadow: isMobile
            ? null
            : const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  blurRadius: 49,
                  spreadRadius: -22,
                ),
              ],
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: avatar + text field ──────────────────────────────
          Builder(
            builder: (context) {
              final taggerChild = FlutterTagger(
                controller: _controller,
                onSearch: _onSearch,
                overlay: const SizedBox.shrink(),
                triggerCharacterAndStyles: const {
                  '#': TextStyle(
                    color: Color(0xFF4535C1),
                    fontWeight: FontWeight.w500,
                  ),
                },
                builder: (context, textFieldKey) {
                  return TextField(
                    key: textFieldKey,
                    controller: _controller,
                    maxLines: null,
                    expands: isMobile,
                    textAlignVertical: TextAlignVertical.top,
                    enabled: !_isLoading,
                    onChanged: (val) => setState(() {}),
                    maxLength: _maxLength,
                    buildCounter:
                        (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    decoration: InputDecoration(
                      hintText:
                          "What are you working on, ${currentUser.split(' ')[0]}?",
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: const Color(0xFF787878),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color(0xFF1F1F1F),
                      height: 1.5,
                    ),
                  );
                },
              );

              final rowChild = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(url: currentUserAvatar ?? '', name: currentUser),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isMobile)
                          Expanded(child: taggerChild)
                        else
                          taggerChild,
                        const SizedBox(height: 4),
                        Text(
                          '${_maxLength - _controller.text.length} characters left',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF787878),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              return isMobile ? Expanded(child: rowChild) : rowChild;
            },
          ),

          // ── Inline tag suggestions ───────────────────────────────────────
          if (_isSearching && _filteredTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDEDEDE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _filteredTags.length,
                itemBuilder: (context, index) {
                  final tag = _filteredTags[index];
                  return InkWell(
                    onTap: () {
                      _controller.addTag(id: tag, name: tag);
                      _hideOverlay();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tag,
                            size: 16,
                            color: Color(0xFF4535C1),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color(0xFF4535C1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Media attachment previews (images and video together) ─────────
          if (_media.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 168,
              width: double.infinity,
              child: Scrollbar(
                controller: attachmentsController,
                child:  ListView.separated(
                  controller: attachmentsController,
                scrollDirection: Axis.horizontal,
                itemCount: _media.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _media[index];
                  final Widget thumbnail = item.isVideo
                      ? Container(
                          color: Colors.black87,
                          child: const Center(
                            child: Icon(Icons.videocam,
                                color: Colors.white, size: 48),
                          ),
                        )
                      : (item.existingUrl != null
                          ? Image.network(
                              item.existingUrl!,
                              width: 168,
                              height: 168,
                              fit: BoxFit.cover,
                            )
                          : Image.memory(
                              item.bytes!,
                              width: 168,
                              height: 168,
                              fit: BoxFit.cover,
                            ));

                  return Stack(
                    children: [
                      Container(
                        width: 158,
                        height: 168,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.96),
                          border: Border.all(
                            color: const Color(0xFFDEDEDE),
                            width: 0.76,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.96),
                          child: thumbnail,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap:
                              _isLoading ? null : () => _removeMediaAt(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF343434),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )),
            ),
          ],

          // ── Bottom action bar ─────────────────────────────────────────────
          if (isMobile) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFDEDEDE), thickness: 1, height: 1),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Tooltip(
                message: "Add an image or video",
                preferBelow: false,
                verticalOffset: 20,
                padding: EdgeInsets.all(12),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  height: 1.42,
                  letterSpacing: 0,
                  color: Color(0xFF343434),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),child:
              PopupMenuButton<String>(
                enabled: !_isLoading,
                tooltip: "",
                position: PopupMenuPosition.over,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'photo') _pickImages();
                  if (value == 'video') _pickVideo();
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'photo',
                    child: Row(
                      children: const [
                        Icon(Icons.image_outlined, color: Color(0xFF787878), size: 20),
                        SizedBox(width: 8),
                        Text('Photo', style: TextStyle(fontSize: 14, color: Color(0xFF1F1F1F))),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'video',
                    child: Row(
                      children: const [
                        Icon(Icons.videocam_outlined, color: Color(0xFF787878), size: 20),
                        SizedBox(width: 8),
                        Text('Video', style: TextStyle(fontSize: 14, color: Color(0xFF1F1F1F))),
                      ],
                    ),
                  ),
                ],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                child: SvgPicture.asset(
                  'assets/icons/image.svg',
                  package: 'feed_module',
                ),
              )),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading || (!_isHasInput && _media.isEmpty)
                  ? null
                  : _handlePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4535C1),
                  foregroundColor: const Color(0xFFF5F5F5),
                  minimumSize: const Size(80, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        widget.postToEdit != null ? 'Save' : 'Post',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ],
      )),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
