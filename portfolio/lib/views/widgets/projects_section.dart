import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../models/project_model.dart';
import '../../stores/projects_store.dart';
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
      color: AppColors.surface,
      padding: AppSpacing.sectionPadding,
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
                return _buildFallback();
              }

              final all = _store.items;
              final categories = [
                'Todos',
                ...all.map((p) => p.category).toSet()
              ];
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
                              duration: AppDurations.fast,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? AppColors.primaryGradient
                                    : null,
                                color:
                                    selected ? null : Colors.transparent,
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
                  const SizedBox(height: 36),
                  ...filtered.asMap().entries.map(
                        (e) =>
                            _ProjectCard(project: e.value, index: e.key),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Projetos indisponíveis no momento.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
  bool _hovered = false;

  static const List<List<Color>> _gradients = [
    [Color(0xFF915EFF), Color(0xFF6366F1)],
    [Color(0xFF00D4AA), Color(0xFF06B6D4)],
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[widget.index % _gradients.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _hovered
                  ? colors[0].withValues(alpha: 0.5)
                  : AppColors.cardBorder,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color accent bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors[0].withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            widget.project.category,
                            style: TextStyle(
                              color: colors[0],
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
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.project.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.project.technologies.map((tech) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.cardBorder),
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
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Icon(icon, color: AppColors.textMuted, size: 16),
        ),
      ),
    );
  }
}
