import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/pill_button.dart';

/// Shared "no items yet" placeholder for every admin list view.
class AdminEmptyState extends StatelessWidget {
  final String message;
  final String? addLabel;
  final VoidCallback? onAdd;

  const AdminEmptyState({
    super.key,
    required this.message,
    this.addLabel,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, color: AppColors.hairlineStrong, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 20),
              PillButton(
                label: addLabel ?? 'Adicionar',
                icon: Icons.add_rounded,
                dense: true,
                onTap: onAdd,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
