import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/service_model.dart';
import '../../../shared/widgets/pill_button.dart';
import '../shared/components/admin_confirm_dialog.dart';
import '../shared/components/admin_empty_state.dart';
import '../shared/components/admin_shell.dart';
import 'components/service_form_dialog.dart';
import 'components/service_tile.dart';
import 'store/admin_services_store.dart';

class ServicesAdminScreen extends StatefulWidget {
  const ServicesAdminScreen({super.key});

  @override
  State<ServicesAdminScreen> createState() => _ServicesAdminScreenState();
}

class _ServicesAdminScreenState extends State<ServicesAdminScreen> {
  late final AdminServicesStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminServicesStore();
    _store.load();
  }

  Future<void> _delete(String title, int id) async {
    final confirm = await showAdminConfirmDialog(
      context,
      title: 'Confirmar exclusão',
      message: 'Deletar "$title"?',
    );
    if (!confirm) return;
    await _store.delete(id);
  }

  void _openForm({ServiceModel? service}) {
    showDialog(
      context: context,
      builder: (_) => ServiceFormDialog(store: _store, service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/services',
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
              Text('Serviços', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 4),
              const Text('Gerencie os serviços exibidos no portfólio.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${_store.services.length} serviço${_store.services.length != 1 ? 's' : ''}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                  PillButton(
                    label: 'Novo Serviço',
                    icon: Icons.add_rounded,
                    dense: true,
                    onTap: () => _openForm(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_store.services.isEmpty)
                const AdminEmptyState(message: 'Nenhum serviço cadastrado.')
              else
                ..._store.services.map((s) => ServiceTile(
                      service: s,
                      onEdit: () => _openForm(service: s),
                      onDelete: () => _delete(s.title, s.id),
                    )),
            ],
          );
        },
      ),
    );
  }
}
