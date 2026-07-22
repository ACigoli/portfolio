import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../shared/components/admin_icon_button.dart';

class ExperienceTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExperienceTile({super.key, required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['role'] ?? '',
                    style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(item['company'] ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '${item['start_date']} → ${item['current'] == 1 ? 'Atual' : (item['end_date'] ?? '')}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] ?? '',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
