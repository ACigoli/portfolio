import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'views/home/home_view.dart';
import 'views/admin/login_view.dart';
import 'views/admin/dashboard_view.dart';
import 'views/admin/projects_admin_view.dart';
import 'views/admin/skills_admin_view.dart';
import 'views/admin/experience_admin_view.dart';
import 'views/admin/messages_view.dart';
import 'views/admin/about_admin_view.dart';
import 'views/admin/services_admin_view.dart';

Future<bool> _isAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('admin_token') != null;
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final isAdminRoute = state.matchedLocation.startsWith('/admin') && state.matchedLocation != '/admin';
    if (isAdminRoute && !await _isAuthenticated()) {
      return '/admin';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeView()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminLoginView()),
    GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardView()),
    GoRoute(path: '/admin/projects', builder: (_, __) => const ProjectsAdminView()),
    GoRoute(path: '/admin/skills', builder: (_, __) => const SkillsAdminView()),
    GoRoute(path: '/admin/experience', builder: (_, __) => const ExperienceAdminView()),
    GoRoute(path: '/admin/messages', builder: (_, __) => const MessagesView()),
    GoRoute(path: '/admin/about', builder: (_, __) => const AboutAdminView()),
    GoRoute(path: '/admin/services', builder: (_, __) => const ServicesAdminView()),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Alex Cigoli | Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
