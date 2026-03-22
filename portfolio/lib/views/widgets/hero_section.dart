import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../stores/about_store.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback? onProjectsTap;
  const HeroSection({super.key, this.onProjectsTap});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  final _aboutStore = AboutStore();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final String _fullText = 'Criando Soluções Digitais Escaláveis com Flutter';
  String _typedText = '';
  int _charIndex = 0;
  bool _showCursor = true;
  Timer? _typingTimer;
  Timer? _cursorTimer;

  final List<String> _titles = ['Full-stack', 'Front End'];
  int _titleIndex = 0;
  Timer? _titleTimer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();

    _aboutStore.load();
    Future.delayed(const Duration(milliseconds: 700), _startTyping);

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });

    _titleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _titleIndex = (_titleIndex + 1) % 2);
    });
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < _fullText.length) {
        setState(() => _typedText = _fullText.substring(0, ++_charIndex));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _titleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 640;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height),
      decoration: BoxDecoration(
        color: Colors.transparent,
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.4),
          radius: 1.4,
          colors: [
            AppColors.primary.withValues(alpha: 0.11),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Glow orbs
          Positioned(
            top: -50,
            right: -50,
            child: _GlowOrb(
              size: 300,
              color: AppColors.primary.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: _GlowOrb(
              size: 220,
              color: AppColors.secondary.withValues(alpha: 0.06),
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.fromLTRB(28, isWide ? 80 : 96, 28, 48),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 55,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                  ),
                                  child: _buildLeft(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 45,
                              child: Center(child: _DevIllustration()),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: _buildLeft(),
                            ),
                            const SizedBox(height: 52),
                            Center(child: _DevIllustration()),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF22C55E).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: Color(0xFF22C55E).withValues(alpha: 0.40),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
              SizedBox(width: 8),
              Text(
                'Disponível para novos projetos',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Title
        const Text(
          'Desenvolvedor',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 44,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.5,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: ShaderMask(
            key: ValueKey(_titleIndex),
            shaderCallback: (bounds) => AppColors.heroGradient.createShader(bounds),
            child: Text(
              _titles[_titleIndex],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        // Typing subtitle
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                _typedText,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _showCursor ? 1.0 : 0.0,
              duration: Duration.zero,
              child: Container(
                width: 2,
                height: 17,
                margin: const EdgeInsets.only(left: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Description
        const Text(
          'Crio interfaces modernas, rápidas e acessíveis, focadas em mobilidade digital, desempenho e experiências que realmente resolvem problemas.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 26),
        // Tech chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _TechChip(label: 'Flutter'),
            _TechChip(label: 'Dart'),
            _TechChip(label: 'Firebase'),
            _TechChip(label: 'REST API'),
          ],
        ),
        const SizedBox(height: 28),
        // CTA buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _GradientButton(
              label: 'Projetos',
              icon: Icons.open_in_new_rounded,
              onTap: widget.onProjectsTap ?? () {},
            ),
            _OutlineButton(
              label: 'Baixar CV',
              icon: Icons.download_rounded,
              onTap: () {
                final cvUrl = _aboutStore.data.value?['cv_url'] as String?;
                if (cvUrl != null && cvUrl.isNotEmpty) {
                  launchUrl(Uri.parse(cvUrl), mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Social icons
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _SocialIcon(
              icon: Icons.code_rounded,
              tooltip: 'GitHub',
              onTap: () => launchUrl(
                Uri.parse('https://github.com/ACigoli'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(width: 10),
            _SocialIcon(
              icon: Icons.business_center_rounded,
              tooltip: 'LinkedIn',
              onTap: () => launchUrl(
                Uri.parse('https://www.linkedin.com/in/alexsandro-cigoli-2b64b8224/'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(width: 10),
            _SocialIcon(
              icon: Icons.camera_alt_outlined,
              tooltip: 'Instagram',
              onTap: () => launchUrl(
                Uri.parse('https://www.instagram.com/alekisgg/'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Phone Mockup Illustration ────────────────────────────────────────────────

class _DevIllustration extends StatefulWidget {
  const _DevIllustration();

  @override
  State<_DevIllustration> createState() => _DevIllustrationState();
}

class _DevIllustrationState extends State<_DevIllustration>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _fillCtrl;
  late AnimationController _fadeCtrl;
  int _screen = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..value = 1.0;

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _fadeCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _screen = (_screen + 1) % 2);
        _fillCtrl
          ..reset()
          ..forward();
        _fadeCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _fillCtrl.dispose();
    _fadeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floatAnim = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    return SizedBox(
      width: 340,
      height: 420,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Glow blob behind phone
          Container(
            width: 180,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 70,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          // Phone
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, floatAnim.value),
              child: child,
            ),
            child: _PhoneFrame(
              screen: _screen,
              fillCtrl: _fillCtrl,
              fadeCtrl: _fadeCtrl,
            ),
          ),
          // Floating badges
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Positioned(
              top: 30 + floatAnim.value * 0.6,
              right: 0,
              child: child!,
            ),
            child: const _FloatingBadge(
              label: 'Flutter',
              icon: Icons.widgets_rounded,
              color: AppColors.primary,
            ),
          ),
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Positioned(
              top: 82 - floatAnim.value,
              left: 0,
              child: child!,
            ),
            child: const _FloatingBadge(
              label: 'Node.js',
              icon: Icons.palette_rounded,
              color: Color(0xFF4A9EFF),
            ),
          ),
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Positioned(
              bottom: 82 + floatAnim.value * 0.5,
              right: 4,
              child: child!,
            ),
            child: const _FloatingBadge(
              label: 'Dart',
              icon: Icons.code_rounded,
              color: AppColors.secondary,
            ),
          ),
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, child) => Positioned(
              bottom: 42 - floatAnim.value * 0.7,
              left: 12,
              child: child!,
            ),
            child: const _FloatingBadge(
              label: 'Firebase',
              icon: Icons.local_fire_department_rounded,
              color: Color(0xFFFF9A3C),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Phone Frame ──────────────────────────────────────────────────────────────

class _PhoneFrame extends StatelessWidget {
  final int screen;
  final AnimationController fillCtrl;
  final AnimationController fadeCtrl;

  const _PhoneFrame({
    required this.screen,
    required this.fillCtrl,
    required this.fadeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      height: 348,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        color: const Color(0xFF13131F),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37),
        child: Column(
          children: [
            _buildStatusBar(),
            _buildAppBar(),
            Expanded(
              child: FadeTransition(
                opacity: fadeCtrl,
                child: Container(
                  color: const Color(0xFF0E0E1C),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: screen == 0
                      ? _SkillsScreen(fillCtrl: fillCtrl)
                      : _ProjectsScreen(fillCtrl: fillCtrl),
                ),
              ),
            ),
            _buildBottomNav(),
            Container(
              height: 20,
              color: const Color(0xFF13131F),
              alignment: Alignment.center,
              child: Container(
                width: 52,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 32,
      color: const Color(0xFF13131F),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 16,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Positioned(
            left: 14,
            top: 10,
            child: Text(
              '9:41',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Positioned(
            right: 14,
            top: 10,
            child: Icon(Icons.battery_full_rounded, color: Colors.white54, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 42,
      color: const Color(0xFF13131F),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            screen == 0 ? Icons.bar_chart_rounded : Icons.folder_open_rounded,
            color: AppColors.primary,
            size: 15,
          ),
          const SizedBox(width: 7),
          Text(
            screen == 0 ? 'Skills' : 'Projects',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIcon(Icons.home_rounded, screen == 0),
          _NavIcon(Icons.folder_rounded, screen == 1),
          _NavIcon(Icons.person_rounded, false),
        ],
      ),
    );
  }
}

// ─── App Screens ──────────────────────────────────────────────────────────────

class _SkillData {
  final String name;
  final double value;
  final Color color;
  const _SkillData(this.name, this.value, this.color);
}

class _SkillsScreen extends StatelessWidget {
  final AnimationController fillCtrl;
  const _SkillsScreen({required this.fillCtrl});

  static const _skills = [
    _SkillData('Flutter',  0.92, Color(0xFF8B5CF6)),
    _SkillData('Dart',     0.88, Color(0xFF22D3EE)),
    _SkillData('Firebase', 0.75, Color(0xFFFF9A3C)),
    _SkillData('REST API', 0.80, Color(0xFF22C55E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPETÊNCIAS',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 8,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._skills.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: fillCtrl,
                    builder: (_, __) {
                      final v = (CurvedAnimation(
                        parent: fillCtrl,
                        curve: Curves.easeOut,
                      ).value * s.value * 100).toInt();
                      return Text(
                        '$v%',
                        style: TextStyle(
                          color: s.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: fillCtrl,
                    builder: (_, __) {
                      final fill = CurvedAnimation(
                        parent: fillCtrl,
                        curve: Curves.easeOut,
                      ).value;
                      return FractionallySizedBox(
                        widthFactor: s.value * fill,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [s.color, s.color.withValues(alpha: 0.5)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: s.color.withValues(alpha: 0.5),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _ProjectData {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  const _ProjectData(this.title, this.subtitle, this.icon, this.color);
}

class _ProjectsScreen extends StatelessWidget {
  final AnimationController fillCtrl;
  const _ProjectsScreen({required this.fillCtrl});

  static const _projects = [
    _ProjectData('Flutter App',  'Mobile · Dart',   Icons.phone_android_rounded, Color(0xFF8B5CF6)),
    _ProjectData('Web Portal',   'Web · Flutter',   Icons.web_rounded,            Color(0xFF22D3EE)),
    _ProjectData('Firebase API', 'Backend · Node',  Icons.cloud_rounded,          Color(0xFFFF9A3C)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENTES',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 8,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(_projects.length, (i) {
          final p = _projects[i];
          final start = i * 0.22;
          final end = (start + 0.6).clamp(0.0, 1.0);
          return AnimatedBuilder(
            animation: fillCtrl,
            builder: (_, __) {
              final t = CurvedAnimation(
                parent: fillCtrl,
                curve: Interval(start, end, curve: Curves.easeOut),
              ).value;
              return Transform.translate(
                offset: Offset(18 * (1 - t), 0),
                child: Opacity(
                  opacity: t,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: p.color.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(p.icon, color: p.color, size: 15),
                        ),
                        const SizedBox(width: 9),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              p.subtitle,
                              style: TextStyle(
                                color: p.color.withValues(alpha: 0.8),
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white24,
                          size: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _NavIcon(this.icon, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? AppColors.primary : Colors.white30,
          size: 18,
        ),
        if (active)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

// ─── Floating Badge ───────────────────────────────────────────────────────────

class _FloatingBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _FloatingBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _hovered
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              widget.icon,
              color: _hovered ? AppColors.primary : AppColors.textMuted,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
