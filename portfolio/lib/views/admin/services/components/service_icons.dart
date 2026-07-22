import 'package:flutter/material.dart';

/// Icon choices offered in the service form dialog + used to render the
/// service tile's leading icon.
const List<Map<String, dynamic>> kServiceIcons = [
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

/// Ready-made gradient palettes offered in the service form dialog.
const List<Map<String, String>> kServiceGradientPalettes = [
  {'label': 'Violeta', 'start': '#8B6BFF', 'end': '#19D3A2'},
  {'label': 'Teal', 'start': '#19D3A2', 'end': '#06B6D4'},
  {'label': 'Rosa', 'start': '#E1306C', 'end': '#F77737'},
  {'label': 'Laranja', 'start': '#FF6B6B', 'end': '#FF8E53'},
  {'label': 'Índigo', 'start': '#6366F1', 'end': '#8B5CF6'},
  {'label': 'Verde', 'start': '#10B981', 'end': '#34D399'},
  {'label': 'Azul', 'start': '#3B82F6', 'end': '#60A5FA'},
  {'label': 'Amarelo', 'start': '#F59E0B', 'end': '#FBBF24'},
];

Color parseServiceHexColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
