import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/service_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../store/services_store.dart';
import 'section_header.dart';

// Mapa de ícones disponíveis (sincronizado com o admin)
const Map<String, IconData> _iconMap = {
  'phone_android': Icons.phone_android_rounded,
  'api': Icons.api_rounded,
  'web': Icons.web_rounded,
  'code': Icons.code_rounded,
  'design_services': Icons.design_services_rounded,
  'cloud': Icons.cloud_rounded,
  'security': Icons.security_rounded,
  'speed': Icons.speed_rounded,
  'devices': Icons.devices_rounded,
  'brush': Icons.brush_rounded,
  'storage': Icons.storage_rounded,
  'integration_instructions': Icons.integration_instructions_rounded,
};

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  late final ServicesStore _store;

  @override
  void initState() {
    super.initState();
    _store = ServicesStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.sectionPadding,
      child: ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              tag: '02. serviços',
              title: 'O que eu faço',
              subtitle: 'Soluções completas do mobile ao backend.',
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

                if (_store.items.isEmpty) {
                  return const SizedBox.shrink();
                }

                final services = _store.items;
                return Column(
                  children: [
                    for (int i = 0; i < services.length; i++) ...[
                      if (i > 0) const SizedBox(height: 24),
                      ScrollReveal(
                        delay: Duration(
                            milliseconds: (i * AppMotion.stagger * 1000).round()),
                        child: _ServiceCard(service: services[i]),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  Color _parseHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final startColor = _parseHex(service.gradientStart);
    final endColor = _parseHex(service.gradientEnd);
    final gradient = LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final icon = _iconMap[service.iconName] ?? Icons.code_rounded;

    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
                if (service.features.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: service.features
                        .map((f) => _FeatureChip(label: f, color: startColor))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final Color color;

  const _FeatureChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
