class ExperienceModel {
  final String company;
  final String role;
  final String period;
  final String description;
  final List<String> achievements;
  final List<String> technologies;
  final bool isCurrent;

  const ExperienceModel({
    required this.company,
    required this.role,
    required this.period,
    required this.description,
    required this.achievements,
    this.technologies = const [],
    this.isCurrent = false,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> j) {
    final isCurrent = j['current'] == 1 || j['current'] == true;
    final startDate = j['start_date'] as String? ?? '';
    final endDate = j['end_date'] as String?;
    final period =
        isCurrent ? '$startDate → Atual' : '$startDate → ${endDate ?? ''}';

    return ExperienceModel(
      company: j['company'] as String,
      role: j['role'] as String,
      period: period,
      description: j['description'] as String,
      achievements: (j['achievements'] as String? ?? '')
          .split('|')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList(),
      technologies: (j['technologies'] as List<dynamic>? ?? [])
          .map((t) => t.toString())
          .toList(),
      isCurrent: isCurrent,
    );
  }
}
