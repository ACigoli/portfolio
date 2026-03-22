import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../stores/contact_store.dart';
import 'section_header.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  late final ContactStore _store;
  bool _submitted = false;

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _msgCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _store = ContactStore();
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
    _msgCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    if (!_canSubmit) return;

    final success = await _store.submit(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _msgCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _nameCtrl.clear();
      _emailCtrl.clear();
      _msgCtrl.clear();
      setState(() => _submitted = false);
      _store.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mensagem enviada com sucesso!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao enviar. Tente novamente.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: AppSpacing.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            tag: '06. contato',
            title: 'Vamos conversar?',
            subtitle:
                'Estou aberto a novos projetos e oportunidades. Entre em contato!',
          ),
          const SizedBox(height: 52),
          // Contact info cards
          Row(
            children: [
              Expanded(
                child: _ContactInfoCard(
                  icon: Icons.mail_rounded,
                  label: 'E-mail',
                  value: 'contato.alekisgg@gmail.com',
                  gradient: AppColors.primaryGradient,
                  url:
                      'https://mail.google.com/mail/?view=cm&to=contato.alekisgg@gmail.com',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactInfoCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Instagram',
                  value: '@alekisgg',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1306C), Color(0xFFF77737)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  url: 'https://www.instagram.com/alekisgg/',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Form
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enviar mensagem',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _TextField(
                  controller: _nameCtrl,
                  label: 'Seu nome',
                  icon: Icons.person_outline_rounded,
                  errorText: _submitted && _nameCtrl.text.trim().isEmpty
                      ? 'Informe seu nome'
                      : null,
                ),
                const SizedBox(height: 18),
                _TextField(
                  controller: _emailCtrl,
                  label: 'Seu e-mail',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _submitted && _emailCtrl.text.trim().isEmpty
                      ? 'Informe seu e-mail'
                      : null,
                ),
                const SizedBox(height: 18),
                _TextField(
                  controller: _msgCtrl,
                  label: 'Sua mensagem',
                  icon: Icons.chat_bubble_outline_rounded,
                  maxLines: 4,
                  errorText: _submitted && _msgCtrl.text.trim().isEmpty
                      ? 'Escreva sua mensagem'
                      : null,
                ),
                const SizedBox(height: 28),
                Observer(
                  builder: (_) {
                    final sending = _store.sending.value;
                    return SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: sending ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient:
                                _canSubmit ? AppColors.primaryGradient : null,
                            color: _canSubmit ? null : AppColors.cardBorder,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            boxShadow: _canSubmit
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (sending)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              else
                                Icon(Icons.send_rounded,
                                    color: _canSubmit
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    size: 18),
                              const SizedBox(width: 8),
                              Text(
                                sending ? 'Enviando...' : 'Enviar Mensagem',
                                style: TextStyle(
                                  color: _canSubmit
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Footer
          const Center(
            child: Text(
              'Feito com Flutter  •  © 2025 Alex Developer',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;
  final String url;

  const _ContactInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? errorText;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon,
            color: hasError ? Colors.redAccent : AppColors.textMuted, size: 18),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        filled: true,
        fillColor: hasError
            ? Colors.redAccent.withValues(alpha: 0.05)
            : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: hasError
                ? Colors.redAccent.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: hasError ? Colors.redAccent : AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
