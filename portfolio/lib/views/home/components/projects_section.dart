import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/project_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../store/projects_store.dart';
import 'section_header.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  late final ProjectsStore _store;

  @override
  void initState() {
    super.initState();
    _store = ProjectsStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.sectionPadding,
      child: ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              tag: '04. projetos',
              title: 'Meu Trabalho',
              subtitle: 'Alguns dos projetos que desenvolvi.',
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
                  return _buildFallback(context);
                }

                final all = _store.items;
                final categories = ['Todos', ...all.map((p) => p.category).toSet()];
                final filtered = _store.filtered;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final selected = cat == _store.filter.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => _store.setFilter(cat),
                              child: AnimatedContainer(
                                duration: AppMotion.fast,
                                curve: AppMotion.easeOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: selected ? AppColors.primaryGradient : null,
                                  color: selected ? null : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.transparent
                                        : AppColors.hairline,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected ? Colors.white : AppColors.textMuted,
                                    fontSize: 13,
                                    fontWeight:
                                        selected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 36),
                    ...filtered.asMap().entries.map(
                          (e) => ScrollReveal(
                            delay: Duration(
                                milliseconds:
                                    (e.key * AppMotion.stagger * 1000).round()),
                            child: _ProjectCard(project: e.value, index: e.key),
                          ),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(
              'Projetos indisponíveis no momento.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _store.load(),
              child: const Text('Tentar novamente',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final int index;

  const _ProjectCard({required this.project, required this.index});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  static const List<Color> _accents = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.primaryLight,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[widget.index % _accents.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.shellInner),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          widget.project.category,
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.project.githubUrl != null)
                            _IconLink(
                              icon: Icons.code_rounded,
                              onTap: () => launchUrl(
                                Uri.parse(widget.project.githubUrl!),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          if (widget.project.liveUrl != null) ...[
                            const SizedBox(width: 8),
                            _IconLink(
                              icon: Icons.open_in_new_rounded,
                              onTap: () => launchUrl(
                                Uri.parse(widget.project.liveUrl!),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(widget.project.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    widget.project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.project.technologies.map((tech) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Text(
                          tech,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconLink extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconLink({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Icon(icon, color: AppColors.textMuted, size: 16),
        ),
      ),
    );
  }
}
