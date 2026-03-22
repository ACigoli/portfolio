class SkillModel {
  final String name;
  final double level; // 0.0 to 1.0
  final String category;

  const SkillModel({
    required this.name,
    required this.level,
    required this.category,
  });

  factory SkillModel.fromJson(Map<String, dynamic> j) => SkillModel(
        name: j['name'] as String,
        level: (j['level'] as num) / 100.0,
        category: j['category'] as String,
      );
}
