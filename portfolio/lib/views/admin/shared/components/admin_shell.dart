import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/api_service.dart';
import '../../../../shared/widgets/animated_background.dart';
import 'admin_sidebar.dart';

/// Admin app chrome (ex `AdminLayout`): fixed sidebar above 800px, [Drawer]
/// below it, shared [AnimatedBackground] instead of the old bespoke
/// blob+dot-grid, and exactly ONE scroll view for the page content — screens
/// must not wrap their own body in another `SingleChildScrollView`.
class AdminShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AdminShell({super.key, required this.child, required this.currentRoute});

  Future<void> _logout(BuildContext context) async {
    await ApiService.clearToken();
    if (context.mounted) context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isWide
          ? null
          : Drawer(
              backgroundColor: AppColors.surface,
              child: AdminSidebar(currentRoute: currentRoute, onLogout: () => _logout(context)),
            ),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: AppColors.surface,
              title: const Text('Admin', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
              iconTheme: const IconThemeData(color: AppColors.text),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
      body: isWide
          ? Row(
              children: [
                AdminSidebar(currentRoute: currentRoute, onLogout: () => _logout(context)),
                Expanded(child: _buildContent()),
              ],
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        const Positioned.fill(child: AnimatedBackground(orbCount: 3)),
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      ],
    );
  }
}
