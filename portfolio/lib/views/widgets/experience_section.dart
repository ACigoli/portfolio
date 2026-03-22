import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../core/constants/app_constants.dart';
import '../../models/experience_model.dart';
import '../../stores/experience_store.dart';
import 'section_header.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  late final ExperienceStore _store;

  @override
  void initState() {
    super.initState();
    _store = ExperienceStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: AppSpacing.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            tag: '05. experiência',
            title: 'Trajetória',
            subtitle: 'Meu percurso profissional até aqui.',
          ),
          const SizedBox(height: 52),
          Observer(
            builder: (_) {
              if (_store.loading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (_store.items.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Text(
                      'Experiências indisponíveis no momento.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                );
              }

              final experiences = _store.items;
              return Column(
                children: experiences.asMap().entries.map((entry) {
                  return _TimelineItem(
                    experience: entry.value,
                    isLast: entry.key == experiences.length - 1,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ExperienceModel experience;
  final bool isLast;

  const _TimelineItem({required this.experience, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Connector line drawn behind everything
        if (!isLast)
          Positioned(
            left: 6,
            top: 18,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.cardBorder,
                  ],
                ),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                gradient: experience.isCurrent
                    ? AppColors.primaryGradient
                    : null,
                color: experience.isCurrent ? null : AppColors.cardBorder,
                shape: BoxShape.circle,
                boxShadow: experience.isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 40),
                child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: experience.isCurrent
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.cardBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: experience.isCurrent
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        experience.period,
                        style: TextStyle(
                          color: experience.isCurrent
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      experience.role,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      experience.company,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      experience.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    if (experience.technologies.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: experience.technologies
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (experience.achievements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...experience.achievements.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.secondary,
                                  size: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  a,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ],
    );
  }
}
