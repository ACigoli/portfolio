import '../models/skill_model.dart';

class SkillRepository {
  static const List<SkillModel> _skills = [
    // Mobile
    SkillModel(name: 'Flutter', level: 0.95, category: 'Mobile'),
    SkillModel(name: 'Dart', level: 0.92, category: 'Mobile'),
    SkillModel(name: 'Android', level: 0.75, category: 'Mobile'),
    SkillModel(name: 'iOS', level: 0.70, category: 'Mobile'),
    // Backend
    SkillModel(name: 'Firebase', level: 0.88, category: 'Backend'),
    SkillModel(name: 'REST APIs', level: 0.85, category: 'Backend'),
    SkillModel(name: 'Node.js', level: 0.65, category: 'Backend'),
    SkillModel(name: 'SQL', level: 0.72, category: 'Backend'),
    // Ferramentas
    SkillModel(name: 'Git', level: 0.90, category: 'Ferramentas'),
    SkillModel(name: 'Figma', level: 0.78, category: 'Ferramentas'),
    SkillModel(name: 'CI/CD', level: 0.68, category: 'Ferramentas'),
    SkillModel(name: 'Docker', level: 0.60, category: 'Ferramentas'),
  ];

  List<SkillModel> getAll() => _skills;

  List<SkillModel> getByCategory(String category) =>
      _skills.where((s) => s.category == category).toList();

  List<String> getCategories() =>
      _skills.map((s) => s.category).toSet().toList();
}
