import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../shared/components/admin_icon_button.dart';

class MessageTile extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const MessageTile({
    super.key,
    required this.message,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unread = message['read'] == 0 || message['read'] == false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        tint: unread ? AppColors.primary.withValues(alpha: 0.06) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                Expanded(
                  child: Text(
                    message['name'] ?? '',
                    style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  (message['created_at'] as String?)?.substring(0, 10) ?? '',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(width: 12),
                if (unread)
                  AdminIconButton(
                    icon: Icons.mark_email_read_rounded,
                    color: AppColors.secondary,
                    onTap: onMarkRead,
                  ),
                const SizedBox(width: 4),
                AdminIconButton(icon: Icons.delete_rounded, color: AppColors.danger, onTap: onDelete),
              ],
            ),
            const SizedBox(height: 4),
            Text(message['email'] ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Text(
              message['message'] ?? '',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
