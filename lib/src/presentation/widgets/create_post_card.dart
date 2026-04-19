import 'dart:typed_data';
import 'package:feed_module/src/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertagger/fluttertagger.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/di_providers.dart';
import '../../services/mock_data_service.dart';
import 'user_avatar.dart';

class CreatePostCard extends ConsumerStatefulWidget {
  const CreatePostCard({super.key});

  @override
  ConsumerState<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends ConsumerState<CreatePostCard> {
  late final FlutterTaggerController _controller;
  final int _maxLength = 2000;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Picked images as bytes (works on all platforms including web)
  final List<Uint8List> _attachedMedia = [];

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

  void _removeMedia(int index) {
    setState(() {
      _attachedMedia.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      // Read bytes upfront — works on web, iOS, Android, desktop
      final bytes = await Future.wait(picked.map((f) => f.readAsBytes()));
      setState(() {
        _attachedMedia.addAll(bytes);
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

  Future<void> _handlePost() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedMedia.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final tags = _controller.tags.map((t) => '#${t.text}').toList();

      await ref
          .read(createPostUseCaseProvider)
          .call(
            userId: '2', // Mocking current user as 'Sara Hany' (id: 2) for now
            content: text,
            type: _attachedMedia.isEmpty
                ? PostTypeEntity.text
                : _attachedMedia.length == 1
                ? PostTypeEntity.image
                : PostTypeEntity.multiImage,
            tags: tags,
            mediaBytes: _attachedMedia,
          );

      // Success: Reset state
      _controller.clear();
      _attachedMedia.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post shared!')));
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
    final currentUser = MockDataService.users[1]; // Using Sara Hany for demo

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
                          "What are you working on, ${currentUser.name.split(' ')[0]}?",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 20,
                        color: const Color(0xFF787878),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.inter(
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
                  UserAvatar(url: currentUser.avatarUrl),
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
                          style: GoogleFonts.inter(
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
                            style: GoogleFonts.inter(
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

          // ── Media attachment previews ─────────────────────────────────────
          if (_attachedMedia.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _attachedMedia.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
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
                          child: Image.memory(
                            _attachedMedia[index],
                            width: 168,
                            height: 168,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _isLoading ? null : () => _removeMedia(index),
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
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _pickImages,
                  icon: SvgPicture.asset(
                    'assets/icons/image.svg',
                    package: 'feed_module',
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading || !_isHasInput ? null : _handlePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4535C1),
                  foregroundColor: const Color(0xFFF5F5F5),
                  fixedSize: Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
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
                        'Post',
                        style: GoogleFonts.inter(
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
