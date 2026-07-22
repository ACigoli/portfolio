import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/animated_background.dart';
import 'components/app_navbar.dart';
import 'components/hero_section.dart';
import 'components/about_section.dart';
import 'components/skills_section.dart';
import 'components/projects_section.dart';
import 'components/experience_section.dart';
import 'components/contact_section.dart';
import 'components/services_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      floatingActionButton: AnimatedOpacity(
        opacity: _showFab ? 1.0 : 0.0,
        duration: AppMotion.fast,
        child: IgnorePointer(
          ignoring: !_showFab,
          child: FloatingActionButton.small(
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 600),
              curve: AppMotion.easeInOut,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Fundo animado compartilhado ─────────────────────────
          const Positioned.fill(child: AnimatedBackground()),
          // ── Véu no topo — ancora visualmente a nav flutuante ao fundo,
          // em vez de deixá-la "sozinha" sobre a área mais clara do hero.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.7),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
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
                      Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(milliseconds: 600),
                        curve: AppMotion.easeInOut,
                      );
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
          // ── Nav flutuante ("fluid island") ──────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppNavBar(
              scrollController: _scrollController,
              sectionKeys: _sectionKeys,
            ),
          ),
        ],
      ),
    );
  }
}
