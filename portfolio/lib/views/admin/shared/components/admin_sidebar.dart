import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class AdminNavItem {
  final String label;
  final IconData icon;
  final String route;
  const AdminNavItem(this.label, this.icon, this.route);
}

const kAdminNavItems = [
  AdminNavItem('Dashboard', Icons.dashboard_rounded, '/admin/dashboard'),
  AdminNavItem('Projetos', Icons.folder_rounded, '/admin/projects'),
  AdminNavItem('Skills', Icons.bar_chart_rounded, '/admin/skills'),
  AdminNavItem('Experiência', Icons.work_rounded, '/admin/experience'),
  AdminNavItem('Mensagens', Icons.mail_rounded, '/admin/messages'),
  AdminNavItem('Serviços', Icons.build_rounded, '/admin/services'),
  AdminNavItem('Sobre mim', Icons.person_rounded, '/admin/about'),
];

/// Sidebar/drawer content shared by [AdminShell] for both the fixed-rail
/// (desktop) and [Drawer] (mobile) presentations.
class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.hairline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                  child: const Text(
                    'Admin',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                const Text('Portfolio Panel', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: kAdminNavItems.map((item) {
                final active = currentRoute == item.route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _NavTile(
                    item: item,
                    active: active,
                    onTap: () => context.go(item.route),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(color: AppColors.hairline, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _NavTile(
              item: const AdminNavItem('Sair', Icons.logout_rounded, ''),
              active: false,
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final AdminNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavTile({required this.item, required this.active, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final bg = active
        ? AppColors.primary.withValues(alpha: 0.15)
        : (_hovered ? Colors.white.withValues(alpha: 0.05) : Colors.transparent);
    final iconColor = active ? AppColors.primary : AppColors.textMuted;
    final textColor = active
        ? AppColors.text
        : (_hovered ? AppColors.text : AppColors.textMuted);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: active ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, color: iconColor, size: 18),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
