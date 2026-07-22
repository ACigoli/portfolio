import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/api_service.dart';
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
  bool _uploading = false;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _images = List<String>.from(p?['images'] as List? ?? []);
    if (p != null) {
      _titleCtrl.text = p['title'] ?? '';
      _descCtrl.text = p['description'] ?? '';
      _categoryCtrl.text = p['category'] ?? '';
      _techCtrl.text = (p['technologies'] as List? ?? []).join(', ');
      _githubCtrl.text = p['github_url'] ?? '';
      _liveCtrl.text = p['live_url'] ?? '';
    }
  }

  Future<void> _pickAndUploadImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _uploading = true);
    try {
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;
        final ext = (file.extension ?? 'jpg').toLowerCase();
        final contentType = switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          _ => 'image/jpeg',
        };
        final url = await ApiService.uploadImage(bytes, file.name, contentType);
        if (mounted) setState(() => _images.add(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar imagem: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removeImage(String url) {
    setState(() => _images.remove(url));
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
        'images': _images,
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
        _ImageGalleryField(
          images: _images,
          uploading: _uploading,
          onAdd: _pickAndUploadImages,
          onRemove: _removeImage,
        ),
      ],
    );
  }
}

/// Screenshot gallery picker — useful for private/closed-source projects
/// that can't link a live demo or repository. Uploads go straight to R2 via
/// [ApiService.uploadImage]; only the resulting URLs are kept in form state.
class _ImageGalleryField extends StatelessWidget {
  final List<String> images;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _ImageGalleryField({
    required this.images,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Screenshots',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final url in images) _ImageThumb(url: url, onRemove: () => onRemove(url)),
            _AddImageTile(uploading: uploading, onTap: uploading ? null : onAdd),
          ],
        ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  const _ImageThumb({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(border: Border.all(color: AppColors.hairline)),
            child: Image.network(url, fit: BoxFit.cover),
          ),
          Positioned(
            top: 3,
            right: 3,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final bool uploading;
  final VoidCallback? onTap;
  const _AddImageTile({required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.hairline),
            color: AppColors.surface,
          ),
          child: uploading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted, size: 22),
        ),
      ),
    );
  }
}
