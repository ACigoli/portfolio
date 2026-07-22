import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/pill_button.dart';
import '../shared/components/admin_confirm_dialog.dart';
import '../shared/components/admin_empty_state.dart';
import '../shared/components/admin_shell.dart';
import 'components/skill_form_dialog.dart';
import 'components/skill_tile.dart';
import 'store/admin_skills_store.dart';

class SkillsAdminScreen extends StatefulWidget {
  const SkillsAdminScreen({super.key});

  @override
  State<SkillsAdminScreen> createState() => _SkillsAdminScreenState();
}

class _SkillsAdminScreenState extends State<SkillsAdminScreen> {
  late final AdminSkillsStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminSkillsStore();
    _store.load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showAdminConfirmDialog(context, title: 'Deletar skill?');
    if (!confirm) return;
    await _store.delete(id);
  }

  void _openForm([Map<String, dynamic>? skill]) {
    showDialog(
      context: context,
      builder: (_) => SkillFormDialog(store: _store, skill: skill),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/skills',
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
                  Text('Skills', style: Theme.of(context).textTheme.displaySmall),
                  PillButton(label: 'Adicionar', icon: Icons.add_rounded, dense: true, onTap: () => _openForm()),
                ],
              ),
              const SizedBox(height: 28),
              if (_store.items.isEmpty)
                AdminEmptyState(
                  message: 'Nenhuma skill cadastrada',
                  addLabel: 'Adicionar',
                  onAdd: () => _openForm(),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _store.items
                      .map((s) => SkillTile(
                            skill: s,
                            onEdit: () => _openForm(Map<String, dynamic>.from(s)),
                            onDelete: () => _delete(s['id'] as int),
                          ))
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}
