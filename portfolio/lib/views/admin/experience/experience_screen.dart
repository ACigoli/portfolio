import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/pill_button.dart';
import '../shared/components/admin_confirm_dialog.dart';
import '../shared/components/admin_empty_state.dart';
import '../shared/components/admin_shell.dart';
import 'components/experience_form_dialog.dart';
import 'components/experience_tile.dart';
import 'store/admin_experience_store.dart';

class ExperienceAdminScreen extends StatefulWidget {
  const ExperienceAdminScreen({super.key});

  @override
  State<ExperienceAdminScreen> createState() => _ExperienceAdminScreenState();
}

class _ExperienceAdminScreenState extends State<ExperienceAdminScreen> {
  late final AdminExperienceStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminExperienceStore();
    _store.load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showAdminConfirmDialog(context, title: 'Deletar experiência?');
    if (!confirm) return;
    await _store.delete(id);
  }

  void _openForm([Map<String, dynamic>? item]) {
    showDialog(
      context: context,
      builder: (_) => ExperienceFormDialog(store: _store, item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/experience',
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
                  Text('Experiência', style: Theme.of(context).textTheme.displaySmall),
                  PillButton(label: 'Adicionar', icon: Icons.add_rounded, dense: true, onTap: () => _openForm()),
                ],
              ),
              const SizedBox(height: 28),
              if (_store.items.isEmpty)
                AdminEmptyState(
                  message: 'Nenhuma experiência cadastrada',
                  addLabel: 'Adicionar',
                  onAdd: () => _openForm(),
                )
              else
                ..._store.items.map((e) => ExperienceTile(
                      item: e,
                      onEdit: () => _openForm(Map<String, dynamic>.from(e)),
                      onDelete: () => _delete(e['id'] as int),
                    )),
            ],
          );
        },
      ),
    );
  }
}
