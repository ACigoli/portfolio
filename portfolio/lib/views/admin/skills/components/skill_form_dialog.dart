import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../shared/components/admin_form_dialog.dart';
import '../../shared/components/admin_form_field.dart';
import '../store/admin_skills_store.dart';

class SkillFormDialog extends StatefulWidget {
  final AdminSkillsStore store;
  final Map<String, dynamic>? skill;

  const SkillFormDialog({super.key, required this.store, this.skill});

  @override
  State<SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<SkillFormDialog> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  double _level = 80;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.skill;
    if (s != null) {
      _nameCtrl.text = s['name'] ?? '';
      _categoryCtrl.text = s['category'] ?? '';
      _level = (s['level'] as int? ?? 80).toDouble();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'level': _level.toInt(),
      };
      if (widget.skill != null) {
        await widget.store.update(widget.skill!['id'] as int, data);
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
      title: widget.skill == null ? 'Nova Skill' : 'Editar Skill',
      loading: _loading,
      onSave: _save,
      children: [
        AdminFormField(label: 'Nome', controller: _nameCtrl),
        AdminFormField(label: 'Categoria', controller: _categoryCtrl, hint: 'Mobile, Backend, Ferramentas'),
        StatefulBuilder(
          builder: (context, setStateInner) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nível: ${_level.toInt()}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.cardBorder,
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  value: _level,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) {
                    setStateInner(() => _level = v);
                    setState(() => _level = v);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
