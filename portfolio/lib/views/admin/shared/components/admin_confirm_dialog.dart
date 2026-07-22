import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/pill_button.dart';

/// Shared destructive-action confirmation dialog (delete project/skill/
/// experience/service/education). Uses the `danger` [PillButton] variant
/// instead of a bare red [TextButton].
Future<bool> showAdminConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Deletar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title, style: const TextStyle(color: AppColors.text, fontSize: 17)),
      content: message == null
          ? null
          : Text(message, style: const TextStyle(color: AppColors.textMuted)),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
      actions: [
        PillButton(
          label: 'Cancelar',
          variant: PillButtonVariant.ghost,
          dense: true,
          onTap: () => Navigator.pop(context, false),
        ),
        const SizedBox(width: 8),
        PillButton(
          label: confirmLabel,
          variant: PillButtonVariant.danger,
          dense: true,
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
  return result ?? false;
}
