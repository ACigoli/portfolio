import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

enum PillButtonVariant { primary, outline, ghost, danger }

/// Fully-rounded CTA. Trailing icon (if any) sits nested in its own circular
/// "button-in-button" wrapper rather than floating bare next to the label.
/// Presses scale to 0.97 over 140ms — every tappable control in the app
/// should feel this responsive, never an instant color swap.
class PillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final PillButtonVariant variant;
  final bool loading;
  final bool dense;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.variant = PillButtonVariant.primary,
    this.loading = false,
    this.dense = false,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onTap != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final fg = switch (widget.variant) {
      PillButtonVariant.primary => Colors.white,
      PillButtonVariant.outline => AppColors.text,
      PillButtonVariant.ghost => AppColors.textMuted,
      PillButtonVariant.danger => Colors.white,
    };

    final Decoration decoration = switch (widget.variant) {
      PillButtonVariant.primary => BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: _enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: _hovered ? 0.4 : 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
      PillButtonVariant.outline => BoxDecoration(
          color: _hovered ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.hairlineStrong, width: 1.4),
        ),
      PillButtonVariant.ghost => BoxDecoration(
          color: _hovered ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      PillButtonVariant.danger => BoxDecoration(
          color: AppColors.danger.withValues(alpha: _hovered ? 0.9 : 0.8),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
    };

    final iconBg = widget.variant == PillButtonVariant.primary ||
            widget.variant == PillButtonVariant.danger
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.primary.withValues(alpha: 0.12);

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _enabled ? widget.onTap : null,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? AppMotion.pressScale : 1.0,
          duration: AppMotion.press,
          curve: AppMotion.easeOut,
          child: AnimatedOpacity(
            opacity: _enabled ? 1 : 0.5,
            duration: AppMotion.fast,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: widget.dense ? 18 : 24,
                vertical: widget.dense ? 10 : 14,
              ),
              decoration: decoration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.loading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                    )
                  else
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: fg,
                        fontSize: widget.dense ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (widget.icon != null && !widget.loading) ...[
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: AppMotion.fast,
                      curve: AppMotion.easeOut,
                      width: widget.dense ? 22 : 26,
                      height: widget.dense ? 22 : 26,
                      transform: Matrix4.translationValues(
                        _hovered ? 2 : 0,
                        _hovered ? -1 : 0,
                        0,
                      ),
                      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                      child: Icon(widget.icon, size: widget.dense ? 12 : 14, color: fg),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
