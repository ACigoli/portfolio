class ServiceModel {
  final int id;
  final String title;
  final String description;
  final String iconName;
  final String gradientStart;
  final String gradientEnd;
  final List<String> features;
  final int orderIndex;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.gradientStart,
    required this.gradientEnd,
    required this.features,
    required this.orderIndex,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        id: j['id'] as int,
        title: j['title'] as String,
        description: j['description'] as String,
        iconName: j['icon_name'] as String? ?? 'code',
        gradientStart: j['gradient_start'] as String? ?? '#915EFF',
        gradientEnd: j['gradient_end'] as String? ?? '#6366F1',
        features: (j['features'] as String? ?? '')
            .split('|')
            .map((f) => f.trim())
            .where((f) => f.isNotEmpty)
            .toList(),
        orderIndex: j['order_index'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'icon_name': iconName,
        'gradient_start': gradientStart,
        'gradient_end': gradientEnd,
        'features': features.join('|'),
        'order_index': orderIndex,
      };
}
