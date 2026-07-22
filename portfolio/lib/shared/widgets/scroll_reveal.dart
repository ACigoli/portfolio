import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/constants/app_constants.dart';

/// Fades + slides + blurs an element in the first time it becomes visible
/// while scrolling (never appears statically). Fires once per element via
/// [VisibilityDetector] — no `scroll` listeners, no continuous reflows.
/// Honors `MediaQuery.disableAnimations` (reduced motion): shows content
/// immediately with no movement.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const ScrollReveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  bool _triggered = false;
  final _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.reveal);
    _curve = CurvedAnimation(parent: _controller, curve: AppMotion.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reveal() {
    if (_triggered) return;
    _triggered = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
      return;
    }
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.12) _reveal();
      },
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final t = _curve.value;
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 28 * (1 - t)),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
