import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertagger/fluttertagger.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/optimistic_feed_provider.dart';
import '../../services/mock_data_service.dart';
import 'repost_preview_card.dart';
import 'user_avatar.dart';

void showRepostDialog(BuildContext context, WidgetRef ref, Post post) {
  showDialog(
    context: context,
    builder: (ctx) => _RepostDialog(post: post),
  );
}

class _RepostDialog extends ConsumerStatefulWidget {
  final Post post;

  const _RepostDialog({required this.post});

  @override
  ConsumerState<_RepostDialog> createState() => _RepostDialogState();
}

class _RepostDialogState extends ConsumerState<_RepostDialog> {
  late final FlutterTaggerController _controller;
  final List<String> _tags = ['flutter', 'design', 'development', 'ui', 'dart'];
  List<String> _filteredTags = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = FlutterTaggerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query, String trigger) {
    if (trigger == '#') {
      setState(() {
        _filteredTags = _tags
            .where((t) => t.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isSearching = true;
      });
    }
  }

  void _hideOverlay() => setState(() => _isSearching = false);

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(optimisticFeedProvider.notifier).repost(
            byUserId: '2', // Sara Hany
            originalPostId: widget.post.id,
            addedText: _controller.text.trim(),
            originalPost: PostEntity(
              id: widget.post.id,
              userId: widget.post.userId,
              content: widget.post.content,
              imageUrl: widget.post.imageUrl,
              mediaUrls: widget.post.mediaUrls,
              tags: widget.post.tags,
              type: PostTypeEntity.values[widget.post.type.index],
              timestamp: widget.post.timestamp,
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reposting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MockDataService.users[1]; // Sara Hany

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatar(url: currentUser.avatarUrl, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: FlutterTagger(
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
                        enabled: !_isLoading,
                        onChanged: (v) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Add details to your post',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF787878),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF1F1F1F),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoading)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Color(0xFF787878)),
                  ),
              ],
            ),

            if (_isSearching && _filteredTags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
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
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.tag,
                                size: 16, color: Color(0xFF4535C1)),
                            const SizedBox(width: 6),
                            Text(
                              '#$tag',
                              style: GoogleFonts.inter(
                                fontSize: 14,
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

            const SizedBox(height: 16),
            RepostPreviewCard(post: widget.post),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4535C1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFB3ADEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
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
                        'Repost',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
