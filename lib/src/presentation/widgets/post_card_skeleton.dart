import 'package:flutter/material.dart';

/// A widget that renders a shimmering animated placeholder.
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}

/// PostCardSkeleton – matches the Figma skeleton spec exactly:
/// - Circular avatar + name bar row
/// - Two text placeholder bars
/// - Large image placeholder
/// - Action row (3× circle + small bar)
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 49,
            spreadRadius: -22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: avatar circle + name bar ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const _ShimmerBox(width: 48, height: 48, borderRadius: 100),
                  const SizedBox(width: 8),
                  const _ShimmerBox(width: 206, height: 12, borderRadius: 16),
                ],
              ),
              // Follow + more placeholder (opacity 0 → invisible but keeps space)
            ],
          ),
          const SizedBox(height: 16),
          // ── Text bars ────────────────────────────────────────────────────
          const _ShimmerBox(
            width: double.infinity,
            height: 12,
            borderRadius: 16,
          ),
          const SizedBox(height: 8),
          const _ShimmerBox(width: 345, height: 12, borderRadius: 16),
          const SizedBox(height: 16),
          // ── Image placeholder ─────────────────────────────────────────────
          const _ShimmerBox(
            width: double.infinity,
            height: 328,
            borderRadius: 16,
          ),
          const SizedBox(height: 16),
          // ── Action bar: 3× (circle + small bar) ──────────────────────────
          const Divider(color: Color(0xFFDEDEDE), thickness: 1, height: 1),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              3,
              (i) => [
                const _ShimmerBox(width: 24, height: 24, borderRadius: 100),
                const SizedBox(width: 8),
                const _ShimmerBox(width: 30, height: 8, borderRadius: 16),
                if (i < 2) const SizedBox(width: 24),
              ],
            ).expand((e) => e).toList(),
          ),
        ],
      ),
    );
  }
}
