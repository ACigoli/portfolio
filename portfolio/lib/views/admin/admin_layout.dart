import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({super.key, required this.child, required this.currentRoute});

  static const _navItems = [
    _NavItem('Dashboard', Icons.dashboard_rounded, '/admin/dashboard'),
    _NavItem('Projetos', Icons.folder_rounded, '/admin/projects'),
    _NavItem('Skills', Icons.bar_chart_rounded, '/admin/skills'),
    _NavItem('Experiência', Icons.work_rounded, '/admin/experience'),
    _NavItem('Mensagens', Icons.mail_rounded, '/admin/messages'),
    _NavItem('Serviços', Icons.build_rounded, '/admin/services'),
    _NavItem('Sobre mim', Icons.person_rounded, '/admin/about'),
  ];

  Future<void> _logout(BuildContext context) async {
    await ApiService.clearToken();
    if (context.mounted) context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      drawer: isWide ? null : _buildDrawer(context),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0D1224),
              title: const Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF8892A4)),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
      body: isWide
          ? Row(
              children: [
                _buildSidebar(context),
                Expanded(child: _buildContent(child)),
              ],
            )
          : _buildContent(child),
    );
  }

  Widget _buildContent(Widget child) {
    return Stack(
      children: [
        // Gradiente base
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1225),
                  Color(0xFF080D1A),
                  Color(0xFF0A0F1E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Blob roxo superior direito
        Positioned(
          top: -60,
          right: -60,
          child: _Blob(size: 400, color: const Color(0xFF915EFF), opacity: 0.12),
        ),
        // Blob teal inferior esquerdo
        Positioned(
          bottom: -40,
          left: -40,
          child: _Blob(size: 340, color: const Color(0xFF00D4AA), opacity: 0.09),
        ),
        // Blob índigo centro
        Positioned(
          top: 180,
          right: 80,
          child: _Blob(size: 220, color: const Color(0xFF6366F1), opacity: 0.07),
        ),
        // Blob roxo inferior direito
        Positioned(
          bottom: 100,
          right: -30,
          child: _Blob(size: 200, color: const Color(0xFF915EFF), opacity: 0.06),
        ),
        // Grid de pontos
        Positioned.fill(child: _DotGrid()),
        // Linha decorativa superior
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFF915EFF),
                  Color(0xFF00D4AA),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Conteúdo
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF0D1224),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFF915EFF), Color(0xFF00D4AA)],
                  ).createShader(b),
                  child: const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ),
                const Text('Portfolio Panel', style: TextStyle(color: Color(0xFF8892A4), fontSize: 12)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E2D4A), height: 1),
          const SizedBox(height: 12),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _navItems.map((item) {
                final active = currentRoute == item.route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => context.go(item.route),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF915EFF).withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: active ? Border.all(color: const Color(0xFF915EFF).withValues(alpha: 0.3)) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: active ? const Color(0xFF915EFF) : const Color(0xFF8892A4), size: 18),
                            const SizedBox(width: 12),
                            Text(item.label, style: TextStyle(
                              color: active ? const Color(0xFFF3F4F6) : const Color(0xFF8892A4),
                              fontSize: 14,
                              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Color(0xFF1E2D4A), height: 1),
          // Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _logout(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Color(0xFF8892A4), size: 18),
                      SizedBox(width: 12),
                      Text('Sair', style: TextStyle(color: Color(0xFF8892A4), fontSize: 14)),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D1224),
      child: _buildSidebar(context),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
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

class _DotGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 28.0;
        final cols = (constraints.maxWidth / spacing).ceil();
        final rows = (constraints.maxHeight / spacing).ceil();
        return CustomPaint(
          painter: _DotGridPainter(cols: cols, rows: rows, spacing: spacing),
        );
      },
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final int cols;
  final int rows;
  final double spacing;

  _DotGridPainter({required this.cols, required this.rows, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF915EFF).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacing, r * spacing),
          1.2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
