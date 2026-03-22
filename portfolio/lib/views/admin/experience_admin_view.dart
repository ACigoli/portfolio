import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../services/api_service.dart';
import '../../stores/admin_experience_store.dart';
import 'admin_layout.dart';

class ExperienceAdminView extends StatefulWidget {
  const ExperienceAdminView({super.key});
  @override
  State<ExperienceAdminView> createState() => _ExperienceAdminViewState();
}

class _ExperienceAdminViewState extends State<ExperienceAdminView> {
  late final AdminExperienceStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminExperienceStore();
    _store.load();
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF0D1224),
            title: const Text('Deletar experiência?',
                style: TextStyle(color: Color(0xFFF3F4F6))),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Color(0xFF8892A4)))),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Deletar',
                      style: TextStyle(color: Color(0xFFFF6B6B)))),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await _store.delete(id);
  }

  void _openForm([Map<String, dynamic>? item]) {
    showDialog(
        context: context,
        builder: (_) =>
            _ExperienceFormDialog(item: item, onSaved: _store.load));
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/experience',
      child: Observer(
        builder: (_) {
          if (_store.loading.value) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF915EFF)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Experiência',
                        style: TextStyle(
                            color: Color(0xFFF3F4F6),
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    _AddButton(onTap: () => _openForm()),
                  ],
                ),
                const SizedBox(height: 28),
                if (_store.items.isEmpty)
                  _EmptyState(
                      label: 'Nenhuma experiência cadastrada',
                      onAdd: () => _openForm())
                else
                  ..._store.items.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1224),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFF1E2D4A)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e['role'] ?? '',
                                      style: const TextStyle(
                                          color: Color(0xFFF3F4F6),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(e['company'] ?? '',
                                      style: const TextStyle(
                                          color: Color(0xFF915EFF),
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${e['start_date']} → ${e['current'] == 1 ? 'Atual' : (e['end_date'] ?? '')}',
                                      style: const TextStyle(
                                          color: Color(0xFF8892A4),
                                          fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text(e['description'] ?? '',
                                      style: const TextStyle(
                                          color: Color(0xFF8892A4),
                                          fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _IconBtn(
                                    icon: Icons.edit_rounded,
                                    color: const Color(0xFF4A9EFF),
                                    onTap: () => _openForm(
                                        Map<String, dynamic>.from(e))),
                                const SizedBox(width: 8),
                                _IconBtn(
                                    icon: Icons.delete_rounded,
                                    color: const Color(0xFFFF6B6B),
                                    onTap: () =>
                                        _delete(e['id'] as int)),
                              ],
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExperienceFormDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final VoidCallback onSaved;
  const _ExperienceFormDialog({this.item, required this.onSaved});
  @override
  State<_ExperienceFormDialog> createState() =>
      _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<_ExperienceFormDialog> {
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  bool _current = false, _loading = false;

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
      _techCtrl.text =
          (e['technologies'] as List? ?? []).join(', ');
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
        await ApiService.updateExperience(widget.item!['id'], data);
      } else {
        await ApiService.createExperience(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$e'),
            backgroundColor: const Color(0xFFFF6B6B)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialog(
      title:
          widget.item == null ? 'Nova Experiência' : 'Editar Experiência',
      loading: _loading,
      onSave: _save,
      children: [
        _FormField(label: 'Empresa', ctrl: _companyCtrl),
        _FormField(label: 'Cargo', ctrl: _roleCtrl),
        _FormField(label: 'Descrição', ctrl: _descCtrl, maxLines: 3),
        _FormField(
            label: 'Data início', ctrl: _startCtrl, hint: '2022-01'),
        if (!_current)
          _FormField(
              label: 'Data fim', ctrl: _endCtrl, hint: '2023-12'),
        Row(
          children: [
            Checkbox(
              value: _current,
              onChanged: (v) =>
                  setState(() => _current = v ?? false),
              activeColor: const Color(0xFF915EFF),
            ),
            const Text('Emprego atual',
                style:
                    TextStyle(color: Color(0xFF8892A4), fontSize: 13)),
          ],
        ),
        _FormField(
            label: 'Tecnologias',
            ctrl: _techCtrl,
            hint: 'Flutter, Dart, Firebase'),
      ],
    );
  }
}

// ─── Shared admin helpers ────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF915EFF), Color(0xFF00D4AA)]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('Adicionar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final int maxLines;
  final String? hint;
  const _FormField(
      {required this.label,
      required this.ctrl,
      this.maxLines = 1,
      this.hint});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8892A4),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFFF3F4F6), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFF4A5568), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF050816),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF915EFF), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _FormDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final bool loading;
  const _FormDialog(
      {required this.title,
      required this.children,
      required this.onSave,
      this.loading = false});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1224),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E2D4A))),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFFF3F4F6),
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF8892A4)),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E2D4A)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children
                      .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: c))
                      .toList(),
                ),
              ),
            ),
            const Divider(color: Color(0xFF1E2D4A)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Color(0xFF8892A4)))),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: loading ? null : onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF915EFF), Color(0xFF00D4AA)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Salvar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  final VoidCallback onAdd;
  const _EmptyState({required this.label, required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded,
                color: Color(0xFF1E2D4A), size: 64),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF8892A4), fontSize: 16)),
            const SizedBox(height: 20),
            _AddButton(onTap: onAdd),
          ],
        ),
      ),
    );
  }
}
