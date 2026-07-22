import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Small square icon action (edit/delete/mark-read) used across every admin
/// list tile. Hover state fades the tint in over [AppMotion.fast] instead of
/// swapping instantly.
class AdminIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  const AdminIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  State<AdminIconButton> createState() => _AdminIconButtonState();
}

class _AdminIconButtonState extends State<AdminIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _hovered ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(widget.icon, color: widget.color, size: 16),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
