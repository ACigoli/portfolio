import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/app_navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/services_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();

  final _aboutKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _experienceKey = GlobalKey();
  final _contactKey = GlobalKey();

  late final List<GlobalKey> _sectionKeys;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _sectionKeys = [
      _aboutKey,
      _servicesKey,
      _skillsKey,
      _projectsKey,
      _experienceKey,
      _contactKey,
    ];
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showFab) setState(() => _showFab = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppNavBar(
          scrollController: _scrollController,
          sectionKeys: _sectionKeys,
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showFab,
          child: FloatingActionButton.small(
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.keyboard_arrow_up_rounded,
                color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Fundo fixo ──────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1225),
                    AppColors.background,
                    Color(0xFF0A0F1E),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Blob roxo — topo esquerdo
          Positioned(
            top: -120,
            left: -120,
            child: _Blob(size: 500, color: AppColors.primary, opacity: 0.12),
          ),
          // Blob teal — centro direito
          Positioned(
            top: 300,
            right: -100,
            child: _Blob(size: 400, color: AppColors.secondary, opacity: 0.09),
          ),
          // Blob índigo — meio
          Positioned(
            top: 800,
            left: -60,
            child: _Blob(size: 320, color: const Color(0xFF6366F1), opacity: 0.07),
          ),
          // Blob roxo — inferior direito
          Positioned(
            top: 1400,
            right: -80,
            child: _Blob(size: 360, color: AppColors.primary, opacity: 0.08),
          ),
          // Blob teal — inferior esquerdo
          Positioned(
            top: 2000,
            left: -60,
            child: _Blob(size: 300, color: AppColors.secondary, opacity: 0.07),
          ),
          // Grid de pontos
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),
          // Linha decorativa no topo
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary,
                    AppColors.secondary,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Conteúdo scrollável ─────────────────────────────────
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                HeroSection(
                  onProjectsTap: () {
                    final ctx = _projectsKey.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(ctx,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut);
                    }
                  },
                ),
                AboutSection(key: _aboutKey),
                ServicesSection(key: _servicesKey),
                SkillsSection(key: _skillsKey),
                ProjectsSection(key: _projectsKey),
                ExperienceSection(key: _experienceKey),
                ContactSection(key: _contactKey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Blob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 32.0;
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
