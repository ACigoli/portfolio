import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../shared/components/admin_form_dialog.dart';
import '../../shared/components/admin_form_field.dart';
import '../store/admin_projects_store.dart';

/// Create/edit dialog for a project. Goes through [AdminProjectsStore]
/// instead of calling `ApiService` directly, so the list always reflects the
/// latest state after save.
class ProjectFormDialog extends StatefulWidget {
  final AdminProjectsStore store;
  final Map<String, dynamic>? project;

  const ProjectFormDialog({super.key, required this.store, this.project});

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _liveCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    if (p != null) {
      _titleCtrl.text = p['title'] ?? '';
      _descCtrl.text = p['description'] ?? '';
      _categoryCtrl.text = p['category'] ?? '';
      _techCtrl.text = (p['technologies'] as List? ?? []).join(', ');
      _githubCtrl.text = p['github_url'] ?? '';
      _liveCtrl.text = p['live_url'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _techCtrl.dispose();
    _githubCtrl.dispose();
    _liveCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final techs = _techCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'technologies': techs,
        'github_url': _githubCtrl.text.trim(),
        'live_url': _liveCtrl.text.trim(),
      };
      if (widget.project != null) {
        await widget.store.update(widget.project!['id'] as int, data);
      } else {
        await widget.store.create(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormDialog(
      title: widget.project == null ? 'Novo Projeto' : 'Editar Projeto',
      loading: _loading,
      onSave: _save,
      children: [
        AdminFormField(label: 'Título', controller: _titleCtrl),
        AdminFormField(label: 'Descrição', controller: _descCtrl, maxLines: 3),
        AdminFormField(label: 'Categoria', controller: _categoryCtrl, hint: 'Ex: Mobile, Backend, Web'),
        AdminFormField(label: 'Tecnologias', controller: _techCtrl, hint: 'Flutter, Dart, Firebase'),
        AdminFormField(label: 'GitHub URL', controller: _githubCtrl),
        AdminFormField(label: 'Live URL', controller: _liveCtrl),
      ],
    );
  }
}
