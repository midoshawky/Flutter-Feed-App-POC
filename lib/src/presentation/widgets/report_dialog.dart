import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/di_providers.dart';
import 'feed_snackbar.dart';

enum ReportType { post, comment }

Future<void> showReportSheet(
  BuildContext context,
  WidgetRef ref, {
  required String targetId,
  required ReportType type,
}) {
  return showDialog(
    context: context,
    builder: (_) => _ReportDialog(ref: ref, targetId: targetId, type: type),
  );
}

class _ReportDialog extends StatefulWidget {
  final WidgetRef ref;
  final String targetId;
  final ReportType type;

  const _ReportDialog({
    required this.ref,
    required this.targetId,
    required this.type,
  });

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
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
      widget.type == ReportType.post ? 'post_media' : 'comment';

  Future<void> _submit() async {
    final reason = _controller.text.trim();
    if (reason.length < _minChars) return;
    setState(() => _isLoading = true);
    try {
      final ds = widget.ref.read(feedApiDataSourceProvider);
      await ds.report(widget.targetId, _typeString, reason);
      if (mounted) {
        Navigator.of(context).pop();
        showFeedSnackBar(
          context,
          widget.type == ReportType.post ? 'Post reported' : 'Comment reported',
        );
      }
    } on DioException catch (err) {
      if (mounted) {
        setState((){
          _isLoading = false;
          print(err.response?.data["message"]);
          _error = err.response?.data["message"];
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //       content: Text('Failed to submit report. Please try again.')),
        // );
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
              const SizedBox(height: 8),
              // ── Title ───────────────────────────────────────────────────
              const Text(
                'Report an issue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1.44,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 24),
              // ── Textarea ────────────────────────────────────────────────
              Container(
                height: 186,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE1E1E1)),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _controller,
                  maxLength: _maxChars,
                  maxLines: null,
                  expands: true,
                  
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue...',
                    errorText: _error,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF787878),
                      fontFamily: 'Product Sans',
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F1F1F),
                    fontFamily: 'Product Sans',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ── Character counter ───────────────────────────────────────
              Text(
                '$remaining characters left (min $_minChars)',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF787878),
                  fontFamily: 'Product Sans',
                ),
              ),
              const SizedBox(height: 24),
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
                      onPressed: canSubmit ? _submit : null,
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
                              'Submit',
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
