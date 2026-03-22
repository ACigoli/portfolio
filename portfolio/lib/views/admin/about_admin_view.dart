import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../../models/education_model.dart';
import '../../services/api_service.dart';
import 'admin_layout.dart';

class AboutAdminView extends StatefulWidget {
  const AboutAdminView({super.key});
  @override
  State<AboutAdminView> createState() => _AboutAdminViewState();
}

class _AboutAdminViewState extends State<AboutAdminView> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cvCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  bool _available = true, _loading = true, _saving = false;
  String? _success;

  final _education = ObservableList<EducationModel>.of([]);

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    _nameCtrl.dispose(); _roleCtrl.dispose(); _bioCtrl.dispose();
    _locationCtrl.dispose(); _emailCtrl.dispose(); _cvCtrl.dispose();
    _githubCtrl.dispose(); _linkedinCtrl.dispose(); _instagramCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.getAbout(),
        ApiService.getEducation(),
      ]);
      final data = results[0] as Map<String, dynamic>;
      _nameCtrl.text = data['name'] ?? '';
      _roleCtrl.text = data['role'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _locationCtrl.text = data['location'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _cvCtrl.text = data['cv_url'] ?? '';
      _githubCtrl.text = data['github_url'] ?? '';
      _linkedinCtrl.text = data['linkedin_url'] ?? '';
      _instagramCtrl.text = data['instagram_url'] ?? '';
      _available = data['available'] == 1 || data['available'] == true;
      runInAction(() {
        _education
          ..clear()
          ..addAll((results[1] as List<dynamic>)
              .map((j) => EducationModel.fromJson(j as Map<String, dynamic>)));
      });
      setState(() => _loading = false);
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _success = null; });
    try {
      await ApiService.updateAbout({
        'name': _nameCtrl.text.trim(), 'role': _roleCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(), 'location': _locationCtrl.text.trim(),
        'email': _emailCtrl.text.trim(), 'cv_url': _cvCtrl.text.trim(),
        'github_url': _githubCtrl.text.trim(), 'linkedin_url': _linkedinCtrl.text.trim(),
        'instagram_url': _instagramCtrl.text.trim(), 'available': _available,
      });
      setState(() => _success = 'Salvo com sucesso!');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: const Color(0xFFFF6B6B)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteEducation(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1224),
        title: const Text('Deletar formação?', style: TextStyle(color: Color(0xFFF3F4F6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8892A4)))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deletar', style: TextStyle(color: Color(0xFFFF6B6B)))),
        ],
      ),
    ) ?? false;
    if (!ok) return;
    await ApiService.deleteEducation(id);
    final list = await ApiService.getEducation();
    runInAction(() {
      _education
        ..clear()
        ..addAll(list.map((j) => EducationModel.fromJson(j as Map<String, dynamic>)));
    });
  }

  void _openEducationForm([EducationModel? item]) {
    showDialog(
      context: context,
      builder: (_) => _EducationFormDialog(
        item: item,
        onSaved: () async {
          final list = await ApiService.getEducation();
          runInAction(() {
            _education
              ..clear()
              ..addAll(list.map((j) => EducationModel.fromJson(j as Map<String, dynamic>)));
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/about',
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF915EFF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sobre mim', style: TextStyle(color: Color(0xFFF3F4F6), fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 28),
                  if (_success != null) Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00D4AA).withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00D4AA), size: 18),
                      const SizedBox(width: 8),
                      Text(_success!, style: const TextStyle(color: Color(0xFF00D4AA))),
                    ]),
                  ),
                  // ── Dados pessoais ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1224),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormField(label: 'Nome', ctrl: _nameCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'Cargo', ctrl: _roleCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'Bio', ctrl: _bioCtrl, maxLines: 4),
                        const SizedBox(height: 16),
                        _FormField(label: 'Localização', ctrl: _locationCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'E-mail', ctrl: _emailCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'Link do CV', ctrl: _cvCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'GitHub URL', ctrl: _githubCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'LinkedIn URL', ctrl: _linkedinCtrl),
                        const SizedBox(height: 16),
                        _FormField(label: 'Instagram URL', ctrl: _instagramCtrl),
                        const SizedBox(height: 16),
                        Row(children: [
                          Switch(value: _available, onChanged: (v) => setState(() => _available = v), activeThumbColor: const Color(0xFF00D4AA)),
                          const SizedBox(width: 8),
                          const Text('Disponível para projetos', style: TextStyle(color: Color(0xFF8892A4), fontSize: 14)),
                        ]),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _saving ? null : _save,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF915EFF), Color(0xFF00D4AA)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: _saving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Salvar alterações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ),
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
                      const Text('Formação Acadêmica', style: TextStyle(color: Color(0xFFF3F4F6), fontSize: 20, fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: () => _openEducationForm(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF915EFF), Color(0xFF00D4AA)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Adicionar', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Observer(
                    builder: (_) {
                      if (_education.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1224),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E2D4A)),
                          ),
                          child: const Center(
                            child: Text('Nenhuma formação cadastrada', style: TextStyle(color: Color(0xFF8892A4))),
                          ),
                        );
                      }
                      return Column(
                        children: _education.map((e) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1224),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E2D4A)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.degree, style: const TextStyle(color: Color(0xFFF3F4F6), fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(e.institution, style: const TextStyle(color: Color(0xFF915EFF), fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(e.period, style: const TextStyle(color: Color(0xFF8892A4), fontSize: 12)),
                                    if (e.description != null && e.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(e.description!, style: const TextStyle(color: Color(0xFF8892A4), fontSize: 12, fontStyle: FontStyle.italic)),
                                    ],
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _IconBtn(icon: Icons.edit_rounded, color: const Color(0xFF4A9EFF), onTap: () => _openEducationForm(e)),
                                  const SizedBox(width: 8),
                                  _IconBtn(icon: Icons.delete_rounded, color: const Color(0xFFFF6B6B), onTap: () => _deleteEducation(e.id)),
                                ],
                              ),
                            ],
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Education Form Dialog ─────────────────────────────────────────────────────

class _EducationFormDialog extends StatefulWidget {
  final EducationModel? item;
  final VoidCallback onSaved;
  const _EducationFormDialog({this.item, required this.onSaved});
  @override
  State<_EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends State<_EducationFormDialog> {
  final _institutionCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _current = false, _loading = false;

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
    _institutionCtrl.dispose(); _degreeCtrl.dispose(); _fieldCtrl.dispose();
    _startCtrl.dispose(); _endCtrl.dispose(); _descCtrl.dispose();
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
        await ApiService.updateEducation(widget.item!.id, data);
      } else {
        await ApiService.createEducation(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: const Color(0xFFFF6B6B)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1224),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E2D4A)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              child: Row(
                children: [
                  Text(widget.item == null ? 'Nova Formação' : 'Editar Formação',
                      style: const TextStyle(color: Color(0xFFF3F4F6), fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF8892A4)), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E2D4A)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormField(label: 'Instituição', ctrl: _institutionCtrl),
                    const SizedBox(height: 14),
                    _FormField(label: 'Grau (ex: Bacharelado)', ctrl: _degreeCtrl),
                    const SizedBox(height: 14),
                    _FormField(label: 'Área (ex: Ciência da Computação)', ctrl: _fieldCtrl),
                    const SizedBox(height: 14),
                    _FormField(label: 'Ano início', ctrl: _startCtrl, hint: '2019'),
                    const SizedBox(height: 14),
                    if (!_current) _FormField(label: 'Ano fim', ctrl: _endCtrl, hint: '2023'),
                    if (!_current) const SizedBox(height: 14),
                    Row(
                      children: [
                        Checkbox(
                          value: _current,
                          onChanged: (v) => setState(() => _current = v ?? false),
                          activeColor: const Color(0xFF915EFF),
                        ),
                        const Text('Em andamento', style: TextStyle(color: Color(0xFF8892A4), fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormField(label: 'Descrição (opcional)', ctrl: _descCtrl, maxLines: 2, hint: 'Competências, foco, etc.'),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0xFF1E2D4A)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8892A4)))),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _loading ? null : _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF915EFF), Color(0xFF00D4AA)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

// ── Shared helpers ────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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
  const _FormField({required this.label, required this.ctrl, this.maxLines = 1, this.hint});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8892A4), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFFF3F4F6), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF050816),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF915EFF), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
