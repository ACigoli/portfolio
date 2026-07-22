import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/pill_button.dart';
import '../shared/components/admin_shell.dart';
import '../shared/components/admin_stat_card.dart';
import 'store/dashboard_store.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final DashboardStore _store;

  @override
  void initState() {
    super.initState();
    _store = DashboardStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/dashboard',
      child: Observer(
        builder: (_) {
          if (_store.loading.value) {
            return const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              const Text('Visão geral do portfolio', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 36),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AdminStatCard(
                    label: 'Projetos',
                    value: _store.projectsCount.value,
                    icon: Icons.folder_rounded,
                    color: AppColors.primary,
                    onTap: () => context.go('/admin/projects'),
                  ),
                  AdminStatCard(
                    label: 'Skills',
                    value: _store.skillsCount.value,
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.go('/admin/skills'),
                  ),
                  AdminStatCard(
                    label: 'Experiências',
                    value: _store.experienceCount.value,
                    icon: Icons.work_rounded,
                    color: AppColors.primaryLight,
                    onTap: () => context.go('/admin/experience'),
                  ),
                  AdminStatCard(
                    label: 'Mensagens novas',
                    value: _store.newMessagesCount.value,
                    icon: Icons.mail_rounded,
                    color: AppColors.danger,
                    onTap: () => context.go('/admin/messages'),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ações rápidas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        PillButton(
                          label: 'Novo Projeto',
                          icon: Icons.add_rounded,
                          variant: PillButtonVariant.outline,
                          dense: true,
                          onTap: () => context.go('/admin/projects'),
                        ),
                        PillButton(
                          label: 'Nova Skill',
                          icon: Icons.add_rounded,
                          variant: PillButtonVariant.outline,
                          dense: true,
                          onTap: () => context.go('/admin/skills'),
                        ),
                        PillButton(
                          label: 'Ver Mensagens',
                          icon: Icons.mail_rounded,
                          variant: PillButtonVariant.outline,
                          dense: true,
                          onTap: () => context.go('/admin/messages'),
                        ),
                        PillButton(
                          label: 'Editar Perfil',
                          icon: Icons.person_rounded,
                          variant: PillButtonVariant.outline,
                          dense: true,
                          onTap: () => context.go('/admin/about'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
