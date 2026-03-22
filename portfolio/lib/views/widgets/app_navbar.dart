import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppNavBar extends StatefulWidget {
  final ScrollController scrollController;
  final List<GlobalKey> sectionKeys;

  const AppNavBar({
    super.key,
    required this.scrollController,
    required this.sectionKeys,
  });

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  bool _scrolled = false;
  int _activeIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = widget.scrollController.offset > 50;
    if (isScrolled != _scrolled) setState(() => _scrolled = isScrolled);

    int newActive = -1;
    for (int i = widget.sectionKeys.length - 1; i >= 0; i--) {
      final ctx = widget.sectionKeys[i].currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = box.localToGlobal(Offset.zero);
          if (pos.dy <= 120) {
            newActive = i;
            break;
          }
        }
      }
    }
    if (newActive != _activeIndex) setState(() => _activeIndex = newActive);
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Sobre', 'Serviços', 'Skills', 'Projetos', 'Experiência', 'Contato'];

    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: _scrolled
            ? AppColors.surface.withValues(alpha: 0.95)
            : Colors.transparent,
        border: _scrolled
            ? const Border(
                bottom: BorderSide(color: AppColors.cardBorder),
              )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              GestureDetector(
                onTap: () => widget.scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Alex.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Nav items (desktop/tablet)
              if (MediaQuery.of(context).size.width > 600)
                Row(
                  children: List.generate(labels.length, (i) {
                    final isActive = _activeIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextButton(
                        onPressed: () => _scrollTo(widget.sectionKeys[i]),
                        style: TextButton.styleFrom(
                          foregroundColor: isActive
                              ? AppColors.primary
                              : AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedContainer(
                              duration: AppDurations.fast,
                              height: 2,
                              width: isActive ? 20 : 0,
                              decoration: BoxDecoration(
                                gradient: isActive
                                    ? AppColors.primaryGradient
                                    : null,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )
              else
                // Hamburger mobile
                PopupMenuButton<int>(
                  icon: const Icon(Icons.menu, color: AppColors.text),
                  color: AppColors.surface,
                  onSelected: (i) => _scrollTo(widget.sectionKeys[i]),
                  itemBuilder: (_) => List.generate(
                    labels.length,
                    (i) => PopupMenuItem(
                      value: i,
                      child: Text(labels[i],
                          style: const TextStyle(color: AppColors.text)),
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
