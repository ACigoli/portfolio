import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class SectionHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.tag,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tag.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(title, style: textTheme.displaySmall),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Text(subtitle!, style: textTheme.bodyLarge),
        ],
        const SizedBox(height: 20),
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ],
    );
  }
}
