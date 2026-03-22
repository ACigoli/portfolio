import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../stores/dashboard_store.dart';
import 'admin_layout.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  late final DashboardStore _store;

  @override
  void initState() {
    super.initState();
    _store = DashboardStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/dashboard',
      child: Observer(
        builder: (_) {
          if (_store.loading.value) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF915EFF)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard',
                    style: TextStyle(
                        color: Color(0xFFF3F4F6),
                        fontSize: 28,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Visão geral do portfolio',
                    style:
                        TextStyle(color: Color(0xFF8892A4), fontSize: 14)),
                const SizedBox(height: 36),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                        label: 'Projetos',
                        value: _store.projectsCount.value,
                        icon: Icons.folder_rounded,
                        color: const Color(0xFF915EFF),
                        route: '/admin/projects'),
                    _StatCard(
                        label: 'Skills',
                        value: _store.skillsCount.value,
                        icon: Icons.bar_chart_rounded,
                        color: const Color(0xFF00D4AA),
                        route: '/admin/skills'),
                    _StatCard(
                        label: 'Experiências',
                        value: _store.experienceCount.value,
                        icon: Icons.work_rounded,
                        color: const Color(0xFF4A9EFF),
                        route: '/admin/experience'),
                    _StatCard(
                        label: 'Mensagens novas',
                        value: _store.newMessagesCount.value,
                        icon: Icons.mail_rounded,
                        color: const Color(0xFFFF6B6B),
                        route: '/admin/messages'),
                  ],
                ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1224),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E2D4A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ações rápidas',
                          style: TextStyle(
                              color: Color(0xFFF3F4F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickAction(
                              label: 'Novo Projeto',
                              icon: Icons.add_rounded,
                              onTap: () => context.go('/admin/projects')),
                          _QuickAction(
                              label: 'Nova Skill',
                              icon: Icons.add_rounded,
                              onTap: () => context.go('/admin/skills')),
                          _QuickAction(
                              label: 'Ver Mensagens',
                              icon: Icons.mail_rounded,
                              onTap: () => context.go('/admin/messages')),
                          _QuickAction(
                              label: 'Editar Perfil',
                              icon: Icons.person_rounded,
                              onTap: () => context.go('/admin/about')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String route;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1224),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E2D4A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 16),
              Text('$value',
                  style: TextStyle(
                      color: color,
                      fontSize: 32,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF8892A4), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151D35),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E2D4A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF915EFF), size: 16),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFFF3F4F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
