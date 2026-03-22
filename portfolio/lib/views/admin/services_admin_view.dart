import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../core/constants/app_constants.dart';
import '../../models/service_model.dart';
import '../../services/api_service.dart';
import '../../stores/admin_services_store.dart';
import 'admin_layout.dart';

// Ícones disponíveis para serviços
const List<Map<String, dynamic>> _availableIcons = [
  {'name': 'phone_android', 'icon': Icons.phone_android_rounded, 'label': 'App Mobile'},
  {'name': 'api', 'icon': Icons.api_rounded, 'label': 'API'},
  {'name': 'web', 'icon': Icons.web_rounded, 'label': 'Web'},
  {'name': 'code', 'icon': Icons.code_rounded, 'label': 'Código'},
  {'name': 'design_services', 'icon': Icons.design_services_rounded, 'label': 'Design'},
  {'name': 'cloud', 'icon': Icons.cloud_rounded, 'label': 'Cloud'},
  {'name': 'security', 'icon': Icons.security_rounded, 'label': 'Segurança'},
  {'name': 'speed', 'icon': Icons.speed_rounded, 'label': 'Performance'},
  {'name': 'devices', 'icon': Icons.devices_rounded, 'label': 'Devices'},
  {'name': 'brush', 'icon': Icons.brush_rounded, 'label': 'Design UI'},
  {'name': 'storage', 'icon': Icons.storage_rounded, 'label': 'Banco de Dados'},
  {'name': 'integration_instructions', 'icon': Icons.integration_instructions_rounded, 'label': 'Integração'},
];

class ServicesAdminView extends StatefulWidget {
  const ServicesAdminView({super.key});

  @override
  State<ServicesAdminView> createState() => _ServicesAdminViewState();
}

class _ServicesAdminViewState extends State<ServicesAdminView> {
  late final AdminServicesStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminServicesStore();
    _store.load();
  }

  Future<void> _delete(ServiceModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Confirmar exclusão',
            style: TextStyle(color: AppColors.text)),
        content: Text('Deletar "${s.title}"?',
            style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deletar',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true) return;
    await _store.delete(s.id);
  }

  void _openForm({ServiceModel? service}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ServiceFormDialog(service: service),
    );
    if (result == true) _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/services',
      child: Observer(
        builder: (_) {
          if (_store.loading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da página
              const Text(
                'Serviços',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gerencie os serviços exibidos no portfólio.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 32),
              // Barra de ações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${_store.services.length} serviço${_store.services.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                  _AddButton(onPressed: () => _openForm()),
                ],
              ),
              const SizedBox(height: 24),
              if (_store.services.isEmpty)
                const _EmptyState(
                    message: 'Nenhum serviço cadastrado.')
              else
                ...(_store.services.map((s) => _ServiceTile(
                      service: s,
                      onEdit: () => _openForm(service: s),
                      onDelete: () => _delete(s),
                    ))),
            ],
          );
        },
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _ServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceTile({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  Color _parseHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final startColor = _parseHex(service.gradientStart);
    final endColor = _parseHex(service.gradientEnd);
    final iconData = _availableIcons
            .firstWhere((e) => e['name'] == service.iconName,
                orElse: () => _availableIcons.first)['icon']
        as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(iconData, color: Colors.white, size: 22),
        ),
        title: Text(service.title,
            style: const TextStyle(
                color: AppColors.text, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
            if (service.features.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${service.features.length} feature${service.features.length != 1 ? 's' : ''}',
                style:
                    const TextStyle(color: AppColors.primary, fontSize: 11),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconBtn(
                icon: Icons.edit_rounded,
                color: AppColors.primary,
                onTap: onEdit),
            const SizedBox(width: 8),
            _IconBtn(
                icon: Icons.delete_rounded,
                color: Colors.redAccent,
                onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Form Dialog ───────────────────────────────────────────────────────────────

class _ServiceFormDialog extends StatefulWidget {
  final ServiceModel? service;

  const _ServiceFormDialog({this.service});

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _featuresCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  String _iconName = 'code';
  String _gradientStart = '#915EFF';
  String _gradientEnd = '#6366F1';
  bool _saving = false;

  // Paletas de gradiente prontas
  static const List<Map<String, String>> _palettes = [
    {'label': 'Roxo', 'start': '#915EFF', 'end': '#6366F1'},
    {'label': 'Teal', 'start': '#00D4AA', 'end': '#06B6D4'},
    {'label': 'Rosa', 'start': '#E1306C', 'end': '#F77737'},
    {'label': 'Laranja', 'start': '#FF6B6B', 'end': '#FF8E53'},
    {'label': 'Índigo', 'start': '#6366F1', 'end': '#8B5CF6'},
    {'label': 'Verde', 'start': '#10B981', 'end': '#34D399'},
    {'label': 'Azul', 'start': '#3B82F6', 'end': '#60A5FA'},
    {'label': 'Amarelo', 'start': '#F59E0B', 'end': '#FBBF24'},
  ];

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
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
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
        await ApiService.createService(data);
      } else {
        await ApiService.updateService(widget.service!.id, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  Color _parseHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'Editar Serviço' : 'Novo Serviço',
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              // Título
              _FormField(
                  controller: _titleCtrl,
                  label: 'Título',
                  icon: Icons.title_rounded),
              const SizedBox(height: 14),

              // Descrição
              _FormField(
                  controller: _descCtrl,
                  label: 'Descrição',
                  icon: Icons.description_rounded,
                  maxLines: 3),
              const SizedBox(height: 14),

              // Features (uma por linha)
              _FormField(
                controller: _featuresCtrl,
                label: 'Features (uma por linha)',
                icon: Icons.list_rounded,
                maxLines: 5,
                hint: 'UI/UX moderna\nIntegração com Firebase\n...',
              ),
              const SizedBox(height: 14),

              // Ícone
              const Text('Ícone',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((item) {
                  final selected = _iconName == item['name'];
                  return GestureDetector(
                    onTap: () => setState(
                        () => _iconName = item['name'] as String),
                    child: Tooltip(
                      message: item['label'] as String,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: selected
                              ? AppColors.primaryGradient
                              : null,
                          color: selected ? null : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: selected
                              ? Colors.white
                              : AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Gradiente
              const Text('Cor do gradiente',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _palettes.map((p) {
                  final selected = _gradientStart == p['start'];
                  final c1 = _parseHex(p['start']!);
                  final c2 = _parseHex(p['end']!);
                  return GestureDetector(
                    onTap: () => setState(() {
                      _gradientStart = p['start']!;
                      _gradientEnd = p['end']!;
                    }),
                    child: Tooltip(
                      message: p['label']!,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [c1, c2]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                      color: c1.withValues(alpha: 0.5),
                                      blurRadius: 8)
                                ]
                              : [],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Preview do gradiente selecionado
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _parseHex(_gradientStart),
                      _parseHex(_gradientEnd)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Ordem
              _FormField(
                controller: _orderCtrl,
                label: 'Ordem',
                icon: Icons.sort_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 28),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar',
                        style:
                            TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Novo Serviço'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? hint;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.textDisabled, fontSize: 12),
        labelStyle:
            const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.build_circle_outlined,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
