import 'dart:typed_data';
import 'package:feed_module/feed_module.dart';
import 'package:feed_module/src/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertagger/fluttertagger.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/post_dto.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/di_providers.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../services/mock_data_service.dart';
import 'feed_snackbar.dart';
import 'user_avatar.dart';

class CreatePostCard extends ConsumerStatefulWidget {
  final Post? postToEdit;
  const CreatePostCard({super.key, this.postToEdit});

  @override
  ConsumerState<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends ConsumerState<CreatePostCard> {
  late final FlutterTaggerController _controller;
  final int _maxLength = 2000;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Existing media URLs loaded from the post being edited
  final List<String> _existingMediaUrls = [];

  // Newly picked images as bytes (works on all platforms including web)
  final List<Uint8List> _attachedMedia = [];

  // A single picked video file (mutually exclusive with images)
  XFile? _attachedVideo;

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
      if (widget.postToEdit!.mediaUrls.isNotEmpty) {
        _existingMediaUrls.addAll(widget.postToEdit!.mediaUrls);
      } else if (widget.postToEdit!.imageUrl != null) {
        _existingMediaUrls.add(widget.postToEdit!.imageUrl!);
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

  void _removeExistingMedia(int index) {
    setState(() => _existingMediaUrls.removeAt(index));
  }

  void _removeMedia(int index) {
    setState(() => _attachedMedia.removeAt(index));
  }

  void _removeVideo() {
    setState(() => _attachedVideo = null);
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      // Read bytes upfront — works on web, iOS, Android, desktop
      final bytes = await Future.wait(picked.map((f) => f.readAsBytes()));
      setState(() {
        _attachedVideo = null; // images and video are mutually exclusive
        _attachedMedia.addAll(bytes);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _attachedMedia.clear(); // images and video are mutually exclusive
        _attachedVideo = picked;
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
    if (_attachedVideo != null) return PostTypeEntity.video;
    final totalMedia = _existingMediaUrls.length + _attachedMedia.length;
    if (totalMedia == 0) return PostTypeEntity.text;
    if (totalMedia == 1) return PostTypeEntity.image;
    return PostTypeEntity.multiImage;
  }

  Future<void> _handlePost() async {
    final text = _controller.text.trim();
    final totalMedia = _existingMediaUrls.length + _attachedMedia.length;
    if (text.isEmpty && totalMedia == 0 && _attachedVideo == null) return;

    setState(() => _isLoading = true);

    try {
      final tags = _controller.tags.map((t) => '#${t.text}').toList();
      final userId = ref.read(currentUserIdProvider);
      final type = _resolveType();

      if (widget.postToEdit != null) {
        await ref
            .read(optimisticFeedProvider.notifier)
            .updatePost(widget.postToEdit!.id, text,
                type: PostDto.typeToString(type));
      } else {
        List<Uint8List> allBytes = List.from(_attachedMedia);
        if (_attachedVideo != null) {
          final videoBytes = await _attachedVideo!.readAsBytes();
          allBytes = [videoBytes];
        }
        await ref
            .read(optimisticFeedProvider.notifier)
            .createPost(
              userId: userId.isNotEmpty ? userId : '2',
              content: text,
              type: type,
              tags: tags,
              mediaBytes: allBytes,
            );
      }

      // Success: Reset state
      _controller.clear();
      _attachedMedia.clear();
      _attachedVideo = null;
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
      child: Column(
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

          // ── Video preview ─────────────────────────────────────────────────
          if (_attachedVideo != null) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8.96),
                    border: Border.all(color: const Color(0xFFDEDEDE), width: 0.76),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.96),
                    child: const Center(
                      child: Icon(Icons.videocam, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _removeVideo,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF343434),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ── Media attachment previews ─────────────────────────────────────
          if (_existingMediaUrls.isNotEmpty || _attachedMedia.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _existingMediaUrls.length + _attachedMedia.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isExisting = index < _existingMediaUrls.length;
                  final Widget image = isExisting
                      ? Image.network(
                          _existingMediaUrls[index],
                          width: 168,
                          height: 168,
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          _attachedMedia[index - _existingMediaUrls.length],
                          width: 168,
                          height: 168,
                          fit: BoxFit.cover,
                        );

                  return Stack(
                    children: [
                      Container(
                        width: 168,
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
                          child: image,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => isExisting
                                  ? _removeExistingMedia(index)
                                  : _removeMedia(
                                      index - _existingMediaUrls.length),
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
              ),
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
                onPressed: _isLoading ||
                      (!_isHasInput &&
                          _existingMediaUrls.isEmpty &&
                          _attachedMedia.isEmpty)
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
      ),
    );
  }
}
