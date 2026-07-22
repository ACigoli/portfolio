import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// "Double-bezel" nested container: an outer shell (subtle tint + hairline
/// ring + large radius) wrapping an inner core (solid surface + top glass
/// highlight + smaller, concentric radius). Used for every card-like surface
/// (project/service/skill/experience cards, admin panels, dialogs) so the
/// whole app shares one physical-feeling container instead of flat cards.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double outerRadius;
  final Color? tint;
  final bool blur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.outerRadius = AppRadius.shellOuter,
    this.tint,
    this.blur = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final innerRadius = outerRadius - AppRadius.shellPadding;

    Widget core = ClipRRect(
      borderRadius: BorderRadius.circular(innerRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint ?? AppColors.card,
          borderRadius: BorderRadius.circular(innerRadius),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Stack(
          children: [
            // Top glass highlight — fakes an inset light source.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.innerHighlight, Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    if (blur) {
      core = ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: core,
        ),
      );
    }

    final shell = Container(
      padding: const EdgeInsets.all(AppRadius.shellPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: AppColors.hairline),
      ),
      child: core,
    );

    if (onTap == null) return shell;

    return _Pressable(onTap: onTap!, child: shell);
  }
}

/// Subtle press feedback (scale 0.97, 140ms ease-out) for tappable cards.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? AppMotion.pressScale : 1.0,
          duration: AppMotion.press,
          curve: AppMotion.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
