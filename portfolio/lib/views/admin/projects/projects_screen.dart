import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/pill_button.dart';
import '../shared/components/admin_confirm_dialog.dart';
import '../shared/components/admin_empty_state.dart';
import '../shared/components/admin_shell.dart';
import 'components/project_form_dialog.dart';
import 'components/project_tile.dart';
import 'store/admin_projects_store.dart';

class ProjectsAdminScreen extends StatefulWidget {
  const ProjectsAdminScreen({super.key});

  @override
  State<ProjectsAdminScreen> createState() => _ProjectsAdminScreenState();
}

class _ProjectsAdminScreenState extends State<ProjectsAdminScreen> {
  late final AdminProjectsStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminProjectsStore();
    _store.load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showAdminConfirmDialog(context, title: 'Deletar projeto?');
    if (!confirm) return;
    await _store.delete(id);
  }

  void _openForm([Map<String, dynamic>? project]) {
    showDialog(
      context: context,
      builder: (_) => ProjectFormDialog(store: _store, project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/projects',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Projetos', style: Theme.of(context).textTheme.displaySmall),
                  PillButton(label: 'Adicionar', icon: Icons.add_rounded, dense: true, onTap: () => _openForm()),
                ],
              ),
              const SizedBox(height: 28),
              if (_store.projects.isEmpty)
                AdminEmptyState(
                  message: 'Nenhum projeto cadastrado',
                  addLabel: 'Adicionar',
                  onAdd: () => _openForm(),
                )
              else
                ..._store.projects.map((p) {
                  final raw = {
                    'id': int.tryParse(p.id) ?? 0,
                    'title': p.title,
                    'description': p.description,
                    'category': p.category,
                    'technologies': p.technologies,
                    'github_url': p.githubUrl,
                    'live_url': p.liveUrl,
                  };
                  return ProjectTile(
                    project: raw,
                    onEdit: () => _openForm(raw),
                    onDelete: () => _delete(int.tryParse(p.id) ?? 0),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
