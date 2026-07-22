class ProjectModel {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final String? githubUrl;
  final String? liveUrl;
  final String category;

  /// Screenshots gallery — useful for private/closed-source projects that
  /// can't link a live demo or repository.
  final List<String> images;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    this.githubUrl,
    this.liveUrl,
    required this.category,
    this.images = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> j) => ProjectModel(
        id: j['id'].toString(),
        title: j['title'] as String,
        description: j['description'] as String,
        technologies: (j['technologies'] as List<dynamic>)
            .map((t) => t.toString())
            .toList(),
        githubUrl: j['github_url'] as String?,
        liveUrl: j['live_url'] as String?,
        category: j['category'] as String,
        images: (j['images'] as List<dynamic>? ?? [])
            .map((t) => t.toString())
            .toList(),
      );
}
