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
            if (widget.project.images.isNotEmpty)
              _ProjectCover(
                images: widget.project.images,
                accent: accent,
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

/// Cover image for a project card — the first screenshot, tappable to open
/// the full gallery. Shown only for projects that have at least one image
/// (e.g. private/closed-source projects standing in for a live demo).
class _ProjectCover extends StatefulWidget {
  final List<String> images;
  final Color accent;
  const _ProjectCover({required this.images, required this.accent});

  @override
  State<_ProjectCover> createState() => _ProjectCoverState();
}

class _ProjectCoverState extends State<_ProjectCover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _openGallery(context, widget.images),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.images.first, fit: BoxFit.cover),
              AnimatedOpacity(
                opacity: _hovered ? 1 : 0,
                duration: AppMotion.fast,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        widget.images.length > 1 ? 'Ver ${widget.images.length} fotos' : 'Ver imagem',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openGallery(BuildContext context, List<String> images) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (_) => _GalleryLightbox(images: images),
  );
}

class _GalleryLightbox extends StatefulWidget {
  final List<String> images;
  const _GalleryLightbox({required this.images});

  @override
  State<_GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<_GalleryLightbox> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => InteractiveViewer(
                  child: Image.network(widget.images[i], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (widget.images.length > 1) ...[
            Positioned(
              left: 4,
              child: _LightboxArrow(
                icon: Icons.chevron_left_rounded,
                onTap: _page > 0
                    ? () => _controller.previousPage(
                        duration: AppMotion.medium, curve: AppMotion.easeOut)
                    : null,
              ),
            ),
            Positioned(
              right: 4,
              child: _LightboxArrow(
                icon: Icons.chevron_right_rounded,
                onTap: _page < widget.images.length - 1
                    ? () => _controller.nextPage(
                        duration: AppMotion.medium, curve: AppMotion.easeOut)
                    : null,
              ),
            ),
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.images.length, (i) {
                  return AnimatedContainer(
                    duration: AppMotion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.primary : Colors.white38,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LightboxArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _LightboxArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: onTap == null ? Colors.white24 : Colors.white, size: 32),
      onPressed: onTap,
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
