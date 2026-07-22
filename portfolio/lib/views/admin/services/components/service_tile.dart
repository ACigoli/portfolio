import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/service_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../shared/components/admin_icon_button.dart';
import 'service_icons.dart';

class ServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceTile({super.key, required this.service, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final startColor = parseServiceHexColor(service.gradientStart);
    final endColor = parseServiceHexColor(service.gradientEnd);
    final iconData = kServiceIcons
        .firstWhere((e) => e['name'] == service.iconName, orElse: () => kServiceIcons.first)['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(iconData, color: Colors.white, size: 22),
          ),
          title: Text(service.title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              if (service.features.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '${service.features.length} feature${service.features.length != 1 ? 's' : ''}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminIconButton(icon: Icons.edit_rounded, color: AppColors.primaryLight, onTap: onEdit),
              const SizedBox(width: 8),
              AdminIconButton(icon: Icons.delete_rounded, color: AppColors.danger, onTap: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
