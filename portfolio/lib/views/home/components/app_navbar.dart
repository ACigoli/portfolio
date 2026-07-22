import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Floating "fluid island" nav — a pill-shaped, glass-blurred bar detached
/// from the top edge (never edge-to-edge/sticky-flat). Keeps the original
/// scrollspy mechanism: listens to [scrollController], compares each
/// [sectionKeys] entry's on-screen position to find the active section.
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
        curve: AppMotion.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Sobre', 'Serviços', 'Skills', 'Projetos', 'Experiência', 'Contato'];
    final isWide = MediaQuery.of(context).size.width > 700;

    return Padding(
      padding: const EdgeInsets.only(top: 18, left: 16, right: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.hairline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    GestureDetector(
                      onTap: () => widget.scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 600),
                        curve: AppMotion.easeInOut,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            'Alex.',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                        ),
                      ),
                    ),
                    if (isWide)
                      Row(
                        children: List.generate(labels.length, (i) {
                          final isActive = _activeIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: TextButton(
                              onPressed: () => _scrollTo(widget.sectionKeys[i]),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    isActive ? AppColors.primary : AppColors.textMuted,
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
                                      fontWeight:
                                          isActive ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedContainer(
                                    duration: AppMotion.fast,
                                    curve: AppMotion.easeOut,
                                    height: 2,
                                    width: isActive ? 20 : 0,
                                    decoration: BoxDecoration(
                                      gradient: isActive ? AppColors.primaryGradient : null,
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
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.text),
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          side: BorderSide(color: AppColors.hairline),
                        ),
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
          ),
        ),
      ),
    );
  }
}
