class EducationModel {
  final int id;
  final String institution;
  final String degree;
  final String field;
  final String startYear;
  final String? endYear;
  final bool current;
  final String? description;

  const EducationModel({
    required this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startYear,
    this.endYear,
    this.current = false,
    this.description,
  });

  String get period =>
      current ? '$startYear → Atual' : '$startYear → ${endYear ?? ''}';

  factory EducationModel.fromJson(Map<String, dynamic> j) => EducationModel(
        id: j['id'] as int,
        institution: j['institution'] as String,
        degree: j['degree'] as String,
        field: j['field'] as String,
        startYear: j['start_year'] as String,
        endYear: j['end_year'] as String?,
        current: j['current'] == 1 || j['current'] == true,
        description: j['description'] as String?,
      );
}
