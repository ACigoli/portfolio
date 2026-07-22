import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/education_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/pill_button.dart';
import '../shared/components/admin_confirm_dialog.dart';
import '../shared/components/admin_empty_state.dart';
import '../shared/components/admin_form_field.dart';
import '../shared/components/admin_shell.dart';
import 'components/education_form_dialog.dart';
import 'components/education_tile.dart';
import 'store/admin_about_store.dart';

class AboutAdminScreen extends StatefulWidget {
  const AboutAdminScreen({super.key});

  @override
  State<AboutAdminScreen> createState() => _AboutAdminScreenState();
}

class _AboutAdminScreenState extends State<AboutAdminScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cvCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  bool _available = true;

  late final AdminAboutStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminAboutStore();
    _store.load().then((_) => _populateControllers());
  }

  void _populateControllers() {
    final data = _store.aboutData.value;
    _nameCtrl.text = data['name'] ?? '';
    _roleCtrl.text = data['role'] ?? '';
    _bioCtrl.text = data['bio'] ?? '';
    _locationCtrl.text = data['location'] ?? '';
    _emailCtrl.text = data['email'] ?? '';
    _cvCtrl.text = data['cv_url'] ?? '';
    _githubCtrl.text = data['github_url'] ?? '';
    _linkedinCtrl.text = data['linkedin_url'] ?? '';
    _instagramCtrl.text = data['instagram_url'] ?? '';
    if (mounted) {
      setState(() => _available = data['available'] == 1 || data['available'] == true);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    _cvCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _store.save({
      'name': _nameCtrl.text.trim(),
      'role': _roleCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'cv_url': _cvCtrl.text.trim(),
      'github_url': _githubCtrl.text.trim(),
      'linkedin_url': _linkedinCtrl.text.trim(),
      'instagram_url': _instagramCtrl.text.trim(),
      'available': _available,
    });
    if (mounted && _store.errorMessage.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_store.errorMessage.value!), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _deleteEducation(int id) async {
    final ok = await showAdminConfirmDialog(context, title: 'Deletar formação?');
    if (!ok) return;
    await _store.deleteEducation(id);
  }

  void _openEducationForm([EducationModel? item]) {
    showDialog(
      context: context,
      builder: (_) => EducationFormDialog(store: _store, item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/about',
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
              Text('Sobre mim', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 28),
              if (_store.successMessage.value != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Text(_store.successMessage.value!, style: const TextStyle(color: AppColors.success)),
                    ],
                  ),
                ),
              // ── Dados pessoais ──────────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminFormField(label: 'Nome', controller: _nameCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'Cargo', controller: _roleCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'Bio', controller: _bioCtrl, maxLines: 4),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'Localização', controller: _locationCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'E-mail', controller: _emailCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'Link do CV', controller: _cvCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'GitHub URL', controller: _githubCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'LinkedIn URL', controller: _linkedinCtrl),
                    const SizedBox(height: 16),
                    AdminFormField(label: 'Instagram URL', controller: _instagramCtrl),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Switch(
                          value: _available,
                          onChanged: (v) => setState(() => _available = v),
                        ),
                        const SizedBox(width: 8),
                        const Text('Disponível para projetos',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                        label: 'Salvar alterações',
                        loading: _store.saving.value,
                        onTap: _store.saving.value ? null : _save,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // ── Formação Acadêmica ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Formação Acadêmica', style: Theme.of(context).textTheme.headlineMedium),
                  PillButton(
                    label: 'Adicionar',
                    icon: Icons.add_rounded,
                    dense: true,
                    onTap: () => _openEducationForm(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_store.education.isEmpty)
                const AdminEmptyState(message: 'Nenhuma formação cadastrada')
              else
                ..._store.education.map((e) => EducationTile(
                      education: e,
                      onEdit: () => _openEducationForm(e),
                      onDelete: () => _deleteEducation(e.id),
                    )),
            ],
          );
        },
      ),
    );
  }
}
