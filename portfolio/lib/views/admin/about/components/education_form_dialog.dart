import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/education_model.dart';
import '../../shared/components/admin_form_dialog.dart';
import '../../shared/components/admin_form_field.dart';
import '../store/admin_about_store.dart';

class EducationFormDialog extends StatefulWidget {
  final AdminAboutStore store;
  final EducationModel? item;

  const EducationFormDialog({super.key, required this.store, this.item});

  @override
  State<EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends State<EducationFormDialog> {
  final _institutionCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _current = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.item;
    if (e != null) {
      _institutionCtrl.text = e.institution;
      _degreeCtrl.text = e.degree;
      _fieldCtrl.text = e.field;
      _startCtrl.text = e.startYear;
      _endCtrl.text = e.endYear ?? '';
      _descCtrl.text = e.description ?? '';
      _current = e.current;
    }
  }

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _degreeCtrl.dispose();
    _fieldCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final data = {
        'institution': _institutionCtrl.text.trim(),
        'degree': _degreeCtrl.text.trim(),
        'field': _fieldCtrl.text.trim(),
        'start_year': _startCtrl.text.trim(),
        'end_year': _current ? null : (_endCtrl.text.trim().isEmpty ? null : _endCtrl.text.trim()),
        'current': _current,
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      };
      if (widget.item != null) {
        await widget.store.updateEducation(widget.item!.id, data);
      } else {
        await widget.store.createEducation(data);
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
      title: widget.item == null ? 'Nova Formação' : 'Editar Formação',
      loading: _loading,
      onSave: _save,
      maxWidth: 480,
      maxHeight: 600,
      children: [
        AdminFormField(label: 'Instituição', controller: _institutionCtrl),
        AdminFormField(label: 'Grau (ex: Bacharelado)', controller: _degreeCtrl),
        AdminFormField(label: 'Área (ex: Ciência da Computação)', controller: _fieldCtrl),
        AdminFormField(label: 'Ano início', controller: _startCtrl, hint: '2019'),
        if (!_current) AdminFormField(label: 'Ano fim', controller: _endCtrl, hint: '2023'),
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
              const Text('Em andamento', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
        AdminFormField(
          label: 'Descrição (opcional)',
          controller: _descCtrl,
          maxLines: 2,
          hint: 'Competências, foco, etc.',
        ),
      ],
    );
  }
}
