import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/pill_button.dart';

/// Shared create/edit form surface for every admin CRUD dialog. Picks up
/// background/shape/border from the theme's `DialogThemeData` and relies on
/// the default `showDialog` scale+fade transition instead of a custom one.
class AdminFormDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool loading;
  final String saveLabel;
  final double maxWidth;
  final double maxHeight;

  const AdminFormDialog({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    this.loading = false,
    this.saveLabel = 'Salvar',
    this.maxWidth = 520,
    this.maxHeight = 640,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.hairline, height: 25),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children
                      .map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c))
                      .toList(),
                ),
              ),
            ),
            Divider(color: AppColors.hairline, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(
                    label: 'Cancelar',
                    variant: PillButtonVariant.ghost,
                    dense: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  PillButton(
                    label: saveLabel,
                    dense: true,
                    loading: loading,
                    onTap: loading ? null : onSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
