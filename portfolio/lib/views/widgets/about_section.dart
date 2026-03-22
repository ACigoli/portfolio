import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../models/education_model.dart';
import '../../stores/about_store.dart';
import 'section_header.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  late final AboutStore _store;

  @override
  void initState() {
    super.initState();
    _store = AboutStore();
    _store.load();
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
            tag: '01. sobre mim',
            title: 'Quem sou eu',
            subtitle:
                'Desenvolvedor apaixonado por criar experiências digitais incríveis.',
          ),
          const SizedBox(height: 52),
          Observer(
            builder: (_) {
              if (_store.loading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final about = _store.data.value;
              if (about == null) return const SizedBox.shrink();

              final name = about['name'] as String? ?? '';
              final role = about['role'] as String? ?? '';
              final location = about['location'] as String? ?? '';
              final bio = about['bio'] as String? ?? '';
              final githubUrl = about['github_url'] as String?;
              final linkedinUrl = about['linkedin_url'] as String?;
              final email = about['email'] as String?;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/perfilimage.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              role,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.textMuted,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 44),
                  Text(
                    bio,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 44),
                  // Info chips (fixos)
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(icon: Icons.code_rounded, label: 'Clean Code'),
                      _InfoChip(
                          icon: Icons.palette_rounded, label: 'UI/UX Focus'),
                      _InfoChip(
                          icon: Icons.speed_rounded,
                          label: 'Alta Performance'),
                      _InfoChip(
                          icon: Icons.groups_rounded, label: 'Team Player'),
                    ],
                  ),
                  // Formação acadêmica
                  if (_store.education.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    const Text(
                      'Formação Acadêmica',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._store.education.map((e) => _EducationCard(education: e)),
                  ],
                  const SizedBox(height: 40),
                  // Social links
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (githubUrl != null && githubUrl.isNotEmpty)
                        _SocialButton(
                          icon: Icons.code,
                          label: 'GitHub',
                          url: githubUrl,
                        ),
                      if (linkedinUrl != null && linkedinUrl.isNotEmpty)
                        _SocialButton(
                          icon: Icons.business_center_rounded,
                          label: 'LinkedIn',
                          url: linkedinUrl,
                        ),
                      if (email != null && email.isNotEmpty)
                        _SocialButton(
                          icon: Icons.mail_rounded,
                          label: 'E-mail',
                          url:
                              'https://mail.google.com/mail/?view=cm&to=$email',
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final EducationModel education;
  const _EducationCard({required this.education});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: education.current
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education.degree,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  education.institution,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (education.description != null &&
                    education.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    education.description!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            education.period,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () => launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
