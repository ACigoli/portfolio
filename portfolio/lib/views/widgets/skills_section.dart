import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../core/constants/app_constants.dart';
import '../../models/skill_model.dart';
import '../../stores/skills_store.dart';
import 'section_header.dart';

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  late final SkillsStore _store;

  @override
  void initState() {
    super.initState();
    _store = SkillsStore();
    _store.load().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _store.selectCategory(_store.selectedCategory.value);
        }
      });
    });
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
            tag: '03. habilidades',
            title: 'Tech Stack',
            subtitle: 'Tecnologias que uso no dia a dia.',
          ),
          const SizedBox(height: 48),
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
                      'Skills indisponíveis no momento.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                );
              }

              final categories = _store.categories;
              if (_store.selectedCategory.value.isEmpty ||
                  !categories.contains(_store.selectedCategory.value)) {
                if (categories.isNotEmpty) {
                  _store.selectCategory(categories.first);
                }
              }
              final skills = _store.filtered;
              final animated = _store.animated.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final selected = cat == _store.selectedCategory.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => _store.selectCategory(cat),
                            child: AnimatedContainer(
                              duration: AppDurations.fast,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? AppColors.primaryGradient
                                    : null,
                                color: selected ? null : AppColors.card,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : AppColors.cardBorder,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...skills.map((skill) => _SkillBar(
                        skill: skill,
                        animated: animated,
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final SkillModel skill;
  final bool animated;

  const _SkillBar({required this.skill, required this.animated});

  @override
  Widget build(BuildContext context) {
    final percent = (skill.level * 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill.name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 7,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
              widthFactor: animated ? skill.level : 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
