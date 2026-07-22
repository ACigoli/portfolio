import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/education_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../shared/components/admin_icon_button.dart';

class EducationTile extends StatelessWidget {
  final EducationModel education;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EducationTile({super.key, required this.education, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    education.degree,
                    style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(education.institution, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(education.period, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  if (education.description != null && education.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      education.description!,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                AdminIconButton(icon: Icons.edit_rounded, color: AppColors.primaryLight, onTap: onEdit),
                const SizedBox(width: 8),
                AdminIconButton(icon: Icons.delete_rounded, color: AppColors.danger, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
