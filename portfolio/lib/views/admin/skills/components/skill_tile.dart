import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../shared/components/admin_icon_button.dart';

class SkillTile extends StatelessWidget {
  final Map<String, dynamic> skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SkillTile({super.key, required this.skill, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final level = skill['level'] as int? ?? 0;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    skill['name'] ?? '',
                    style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminIconButton(icon: Icons.edit_rounded, color: AppColors.primaryLight, onTap: onEdit),
                    AdminIconButton(icon: Icons.delete_rounded, color: AppColors.danger, onTap: onDelete),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(skill['category'] ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: level / 100,
                backgroundColor: AppColors.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$level%',
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
