import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../services/api_service.dart';
import '../../stores/admin_projects_store.dart';
import 'admin_layout.dart';

class ProjectsAdminView extends StatefulWidget {
  const ProjectsAdminView({super.key});
  @override
  State<ProjectsAdminView> createState() => _ProjectsAdminViewState();
}

class _ProjectsAdminViewState extends State<ProjectsAdminView> {
  late final AdminProjectsStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminProjectsStore();
    _store.load();
  }

  Future<void> _delete(int id) async {
    final confirm = await _confirmDialog('Deletar projeto?');
    if (!confirm) return;
    await _store.delete(id);
  }

  Future<bool> _confirmDialog(String msg) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF0D1224),
            title: Text(msg,
                style: const TextStyle(color: Color(0xFFF3F4F6))),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Color(0xFF8892A4)))),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirmar',
                      style: TextStyle(color: Color(0xFFFF6B6B)))),
            ],
          ),
        ) ??
        false;
  }

  void _openForm([Map<String, dynamic>? project]) {
    showDialog(
      context: context,
      builder: (_) =>
          _ProjectFormDialog(project: project, onSaved: _store.load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/projects',
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
                    const Text('Projetos',
                        style: TextStyle(
                            color: Color(0xFFF3F4F6),
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    _AddButton(onTap: () => _openForm()),
                  ],
                ),
                const SizedBox(height: 28),
                if (_store.projects.isEmpty)
                  _EmptyState(
                      label: 'Nenhum projeto cadastrado',
                      onAdd: () => _openForm())
                else
                  ..._store.projects.map((p) {
                    final raw = {
                      'id': int.tryParse(p.id) ?? 0,
                      'title': p.title,
                      'description': p.description,
                      'category': p.category,
                      'technologies': p.technologies,
                      'github_url': p.githubUrl,
                      'live_url': p.liveUrl,
                    };
                    return _ProjectTile(
                      project: raw,
                      onEdit: () => _openForm(raw),
                      onDelete: () => _delete(int.tryParse(p.id) ?? 0),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onEdit, onDelete;
  const _ProjectTile(
      {required this.project,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final techs = project['technologies'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1224),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(project['title'] ?? '',
                        style: const TextStyle(
                            color: Color(0xFFF3F4F6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF915EFF)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(project['category'] ?? '',
                          style: const TextStyle(
                              color: Color(0xFF915EFF), fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(project['description'] ?? '',
                    style: const TextStyle(
                        color: Color(0xFF8892A4), fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: techs
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151D35),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFF1E2D4A)),
                            ),
                            child: Text('$t',
                                style: const TextStyle(
                                    color: Color(0xFF8892A4), fontSize: 11)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _IconBtn(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF4A9EFF),
                  onTap: onEdit),
              const SizedBox(width: 8),
              _IconBtn(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFFF6B6B),
                  onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectFormDialog extends StatefulWidget {
  final Map<String, dynamic>? project;
  final VoidCallback onSaved;
  const _ProjectFormDialog({this.project, required this.onSaved});

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
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
        await ApiService.updateProject(widget.project!['id'], data);
      } else {
        await ApiService.createProject(data);
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
      title: widget.project == null ? 'Novo Projeto' : 'Editar Projeto',
      loading: _loading,
      onSave: _save,
      children: [
        _FormField(label: 'Título', ctrl: _titleCtrl),
        _FormField(label: 'Descrição', ctrl: _descCtrl, maxLines: 3),
        _FormField(
            label: 'Categoria',
            ctrl: _categoryCtrl,
            hint: 'Ex: Mobile, Backend, Web'),
        _FormField(
            label: 'Tecnologias',
            ctrl: _techCtrl,
            hint: 'Flutter, Dart, Firebase'),
        _FormField(label: 'GitHub URL', ctrl: _githubCtrl),
        _FormField(label: 'Live URL', ctrl: _liveCtrl),
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
