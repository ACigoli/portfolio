import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Shared decorative backdrop (gradient wash + soft orbs + hairline top line).
/// Extracted so home and admin no longer each re-implement a slightly
/// different version of the same background. Place as the first child of a
/// [Stack] behind scrollable content; sizes itself to the parent.
///
/// [orbCount] lets call sites trim decoration further on short screens
/// (e.g. admin forms) without duplicating the widget.
class AnimatedBackground extends StatelessWidget {
  final int orbCount;
  final bool showTopLine;

  const AnimatedBackground({
    super.key,
    this.orbCount = 3,
    this.showTopLine = true,
  });

  static const _orbs = [
    _Orb(top: -140, left: -120, size: 480, color: AppColors.primary, opacity: 0.14),
    _Orb(top: 260, right: -120, size: 380, color: AppColors.secondary, opacity: 0.10),
    _Orb(top: 720, left: -100, size: 340, color: AppColors.primary, opacity: 0.08),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B1130),
                    AppColors.background,
                    Color(0xFF07040F),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          for (final orb in _orbs.take(orbCount)) orb,
          if (showTopLine)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.6),
                      AppColors.secondary.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final double opacity;

  const _Orb({
    this.top,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
