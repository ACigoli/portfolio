import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/service_model.dart';
import '../../shared/components/admin_form_dialog.dart';
import '../../shared/components/admin_form_field.dart';
import '../store/admin_services_store.dart';
import 'service_icons.dart';

class ServiceFormDialog extends StatefulWidget {
  final AdminServicesStore store;
  final ServiceModel? service;

  const ServiceFormDialog({super.key, required this.store, this.service});

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _featuresCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  String _iconName = 'code';
  String _gradientStart = '#8B6BFF';
  String _gradientEnd = '#19D3A2';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    if (s != null) {
      _titleCtrl.text = s.title;
      _descCtrl.text = s.description;
      _featuresCtrl.text = s.features.join('\n');
      _orderCtrl.text = s.orderIndex.toString();
      _iconName = s.iconName;
      _gradientStart = s.gradientStart;
      _gradientEnd = s.gradientEnd;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _featuresCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final features = _featuresCtrl.text
          .split('\n')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .join('|');

      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'icon_name': _iconName,
        'gradient_start': _gradientStart,
        'gradient_end': _gradientEnd,
        'features': features,
        'order_index': int.tryParse(_orderCtrl.text) ?? 0,
      };

      if (widget.service == null) {
        await widget.store.create(data);
      } else {
        await widget.store.update(widget.service!.id, data);
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
      title: widget.service == null ? 'Novo Serviço' : 'Editar Serviço',
      loading: _loading,
      onSave: _save,
      saveLabel: widget.service == null ? 'Criar' : 'Salvar',
      children: [
        AdminFormField(label: 'Título', controller: _titleCtrl),
        AdminFormField(label: 'Descrição', controller: _descCtrl, maxLines: 3),
        AdminFormField(
          label: 'Features (uma por linha)',
          controller: _featuresCtrl,
          maxLines: 5,
          hint: 'UI/UX moderna\nIntegração com Firebase\n...',
        ),
        StatefulBuilder(
          builder: (context, setStateInner) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ícone',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kServiceIcons.map((item) {
                  final selected = _iconName == item['name'];
                  return GestureDetector(
                    onTap: () {
                      setStateInner(() => _iconName = item['name'] as String);
                      setState(() => _iconName = item['name'] as String);
                    },
                    child: Tooltip(
                      message: item['label'] as String,
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        curve: AppMotion.easeOut,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: selected ? AppColors.primaryGradient : null,
                          color: selected ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: selected ? Colors.transparent : AppColors.cardBorder),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: selected ? Colors.white : AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Cor do gradiente',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kServiceGradientPalettes.map((p) {
                  final selected = _gradientStart == p['start'];
                  final c1 = parseServiceHexColor(p['start']!);
                  final c2 = parseServiceHexColor(p['end']!);
                  return GestureDetector(
                    onTap: () {
                      setStateInner(() {
                        _gradientStart = p['start']!;
                        _gradientEnd = p['end']!;
                      });
                      setState(() {
                        _gradientStart = p['start']!;
                        _gradientEnd = p['end']!;
                      });
                    },
                    child: Tooltip(
                      message: p['label']!,
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        curve: AppMotion.easeOut,
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [c1, c2]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: c1.withValues(alpha: 0.5), blurRadius: 8)]
                              : [],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [parseServiceHexColor(_gradientStart), parseServiceHexColor(_gradientEnd)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        AdminFormField(label: 'Ordem', controller: _orderCtrl, keyboardType: TextInputType.number),
      ],
    );
  }
}
