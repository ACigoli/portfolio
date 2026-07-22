import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'views/home/home_screen.dart';
import 'views/admin/login/login_screen.dart';
import 'views/admin/dashboard/dashboard_screen.dart';
import 'views/admin/projects/projects_screen.dart';
import 'views/admin/skills/skills_screen.dart';
import 'views/admin/experience/experience_screen.dart';
import 'views/admin/messages/messages_screen.dart';
import 'views/admin/about/about_screen.dart';
import 'views/admin/services/services_screen.dart';

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
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(path: '/admin/projects', builder: (_, __) => const ProjectsAdminScreen()),
    GoRoute(path: '/admin/skills', builder: (_, __) => const SkillsAdminScreen()),
    GoRoute(path: '/admin/experience', builder: (_, __) => const ExperienceAdminScreen()),
    GoRoute(path: '/admin/messages', builder: (_, __) => const MessagesAdminScreen()),
    GoRoute(path: '/admin/about', builder: (_, __) => const AboutAdminScreen()),
    GoRoute(path: '/admin/services', builder: (_, __) => const ServicesAdminScreen()),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
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
