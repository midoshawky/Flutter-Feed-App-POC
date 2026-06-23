import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../providers/di_providers.dart';
import 'feed_snackbar.dart';

enum DeleteDialogType { post, comment }

Future<void> showDeleteSheet(
  BuildContext context,
  WidgetRef ref, {
  required String targetId,
  required DeleteDialogType type,
  required VoidCallback onAction,
}) {
  return showDialog(
    context: context,
    builder: (_) => _DeleteDialog(ref: ref, targetId: targetId, type: type,onAction:onAction),
  );
}

class _DeleteDialog extends StatefulWidget {
  final WidgetRef ref;
  final String targetId;
  final DeleteDialogType type;
  final VoidCallback onAction;
  const _DeleteDialog({
    required this.ref,
    required this.targetId,
    required this.type,
    required this.onAction
  });

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  static const _maxChars = 500;
  static const _minChars = 8;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _typeString =>
      widget.type == DeleteDialogType.post ? 'post_media' : 'comment';

  Future<void> _delete() async {
    final reason = _controller.text.trim();
    if (reason.length < _minChars) return;
    setState(() => _isLoading = true);
    try {
      final ds = widget.ref.read(feedApiDataSourceProvider);
      await ds.deletePost(widget.targetId);
      if (mounted) {
        Navigator.of(context).pop();
        showFeedSnackBar(
          context,
          widget.type == DeleteDialogType.post ? 'Post reported' : 'Comment reported',
        );
      }
    } on DioException catch (err) {
      if (mounted) {
        setState((){
          _isLoading = false;
          print(err.response?.data["message"]);
          _error = err.response?.data["message"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxChars - _controller.text.length;
    final canSubmit = _controller.text.trim().length >= _minChars && !_isLoading;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 494),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Close button row ────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Transform.rotate(
                    angle: 0.785398, // 45 degrees in radians
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              SvgPicture.asset('assets/icons/delete_icon.svg',
                                      package: 'feed_module',width: 120,height: 120,),
              SizedBox(height: 16,),
              // ── Title ───────────────────────────────────────────────────
              Text(
                'Delete ${widget.type == DeleteDialogType.post ? 'Post' : 'Comment'}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  height: 1.44,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this ${widget.type == DeleteDialogType.post ? 'post' : 'comment'}? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.44,
                  color: Color(0xFF787878),
                ),
              ),
              SizedBox(height: 16,),
              // ── Buttons row ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel
                  Expanded(child:SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4535C1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: const Color(0xFF4535C1),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          color: Color(0xFF4535C1),
                        ),
                      ),
                    ),
                  ),),
                  const SizedBox(width: 16),
                  // Submit
                  Expanded(child:SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:widget.onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4535C1),
                        disabledBackgroundColor: const Color(0xFFB0A8E0),
                        foregroundColor: const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Product Sans',
                                color: Color(0xFFF5F5F5),
                              ),
                            ),
                    ),
                  ),)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
