import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../services/api_service.dart';
import '../../stores/admin_skills_store.dart';
import 'admin_layout.dart';

class SkillsAdminView extends StatefulWidget {
  const SkillsAdminView({super.key});
  @override
  State<SkillsAdminView> createState() => _SkillsAdminViewState();
}

class _SkillsAdminViewState extends State<SkillsAdminView> {
  late final AdminSkillsStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminSkillsStore();
    _store.load();
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF0D1224),
            title: const Text('Deletar skill?',
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

  void _openForm([Map<String, dynamic>? skill]) {
    showDialog(
        context: context,
        builder: (_) =>
            _SkillFormDialog(skill: skill, onSaved: _store.load));
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/skills',
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
                    const Text('Skills',
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
                      label: 'Nenhuma skill cadastrada',
                      onAdd: () => _openForm())
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _store.items
                        .map((s) => _SkillTile(
                              skill: s,
                              onEdit: () =>
                                  _openForm(Map<String, dynamic>.from(s)),
                              onDelete: () => _delete(s['id'] as int),
                            ))
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final Map<String, dynamic> skill;
  final VoidCallback onEdit, onDelete;
  const _SkillTile(
      {required this.skill, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final level = skill['level'] as int? ?? 0;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1224),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(skill['name'] ?? '',
                      style: const TextStyle(
                          color: Color(0xFFF3F4F6),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBtn(
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF4A9EFF),
                      onTap: onEdit),
                  _IconBtn(
                      icon: Icons.delete_rounded,
                      color: const Color(0xFFFF6B6B),
                      onTap: onDelete),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(skill['category'] ?? '',
              style: const TextStyle(
                  color: Color(0xFF8892A4), fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level / 100,
              backgroundColor: const Color(0xFF1E2D4A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF915EFF)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text('$level%',
              style: const TextStyle(
                  color: Color(0xFF915EFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SkillFormDialog extends StatefulWidget {
  final Map<String, dynamic>? skill;
  final VoidCallback onSaved;
  const _SkillFormDialog({this.skill, required this.onSaved});
  @override
  State<_SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<_SkillFormDialog> {
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
        'level': _level.toInt()
      };
      if (widget.skill != null) {
        await ApiService.updateSkill(widget.skill!['id'], data);
      } else {
        await ApiService.createSkill(data);
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
      title: widget.skill == null ? 'Nova Skill' : 'Editar Skill',
      loading: _loading,
      onSave: _save,
      children: [
        _FormField(label: 'Nome', ctrl: _nameCtrl),
        _FormField(
            label: 'Categoria',
            ctrl: _categoryCtrl,
            hint: 'Mobile, Backend, Ferramentas'),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setStateInner) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nível: ${_level.toInt()}%',
                  style: const TextStyle(
                      color: Color(0xFF8892A4), fontSize: 13)),
              Slider(
                value: _level,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: const Color(0xFF915EFF),
                inactiveColor: const Color(0xFF1E2D4A),
                onChanged: (v) {
                  setStateInner(() => _level = v);
                  setState(() => _level = v);
                },
              ),
            ],
          ),
        ),
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
  final String? hint;
  const _FormField({required this.label, required this.ctrl, this.hint});
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
