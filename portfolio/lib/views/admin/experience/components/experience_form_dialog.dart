import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../shared/components/admin_form_dialog.dart';
import '../../shared/components/admin_form_field.dart';
import '../store/admin_experience_store.dart';

class ExperienceFormDialog extends StatefulWidget {
  final AdminExperienceStore store;
  final Map<String, dynamic>? item;

  const ExperienceFormDialog({super.key, required this.store, this.item});

  @override
  State<ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  bool _current = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.item;
    if (e != null) {
      _companyCtrl.text = e['company'] ?? '';
      _roleCtrl.text = e['role'] ?? '';
      _descCtrl.text = e['description'] ?? '';
      _startCtrl.text = e['start_date'] ?? '';
      _endCtrl.text = e['end_date'] ?? '';
      _techCtrl.text = (e['technologies'] as List? ?? []).join(', ');
      _current = e['current'] == 1 || e['current'] == true;
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _descCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _techCtrl.dispose();
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
        'company': _companyCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'start_date': _startCtrl.text.trim(),
        'end_date': _current ? null : _endCtrl.text.trim(),
        'current': _current,
        'technologies': techs,
      };
      if (widget.item != null) {
        await widget.store.update(widget.item!['id'] as int, data);
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
      title: widget.item == null ? 'Nova Experiência' : 'Editar Experiência',
      loading: _loading,
      onSave: _save,
      children: [
        AdminFormField(label: 'Empresa', controller: _companyCtrl),
        AdminFormField(label: 'Cargo', controller: _roleCtrl),
        AdminFormField(label: 'Descrição', controller: _descCtrl, maxLines: 3),
        AdminFormField(label: 'Data início', controller: _startCtrl, hint: '2022-01'),
        if (!_current) AdminFormField(label: 'Data fim', controller: _endCtrl, hint: '2023-12'),
        StatefulBuilder(
          builder: (context, setStateInner) => Row(
            children: [
              Checkbox(
                value: _current,
                onChanged: (v) {
                  setStateInner(() => _current = v ?? false);
                  setState(() => _current = v ?? false);
                },
              ),
              const Text('Emprego atual', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
        AdminFormField(label: 'Tecnologias', controller: _techCtrl, hint: 'Flutter, Dart, Firebase'),
      ],
    );
  }
}
