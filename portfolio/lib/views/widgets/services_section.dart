import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../core/constants/app_constants.dart';
import '../../models/service_model.dart';
import '../../stores/services_store.dart';
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
      color: Colors.transparent,
      padding: AppSpacing.sectionPadding,
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
                    _ServiceCard(service: services[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  Color _parseHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final startColor = _parseHex(widget.service.gradientStart);
    final endColor = _parseHex(widget.service.gradientEnd);
    final gradient = LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final icon = _iconMap[widget.service.iconName] ?? Icons.code_rounded;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _hovered
                ? startColor.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: startColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
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
                  Text(
                    widget.service.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.service.description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  if (widget.service.features.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.service.features
                          .map((f) =>
                              _FeatureChip(label: f, color: startColor))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
