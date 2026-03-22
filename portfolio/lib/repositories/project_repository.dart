import '../models/project_model.dart';

class ProjectRepository {
  static const List<ProjectModel> _projects = [
    ProjectModel(
      id: '1',
      title: 'E-Commerce App',
      description:
          'Aplicativo completo de e-commerce com autenticação, carrinho de compras, pagamento integrado e painel admin. Interface fluida com animações personalizadas.',
      technologies: ['Flutter', 'Firebase', 'Stripe', 'Provider'],
      githubUrl: 'https://github.com',
      liveUrl: 'https://playstore.com',
      category: 'Mobile',
    ),
    ProjectModel(
      id: '2',
      title: 'Task Manager Pro',
      description:
          'Gerenciador de tarefas com suporte a equipes, notificações em tempo real, gráficos de produtividade e sincronização offline.',
      technologies: ['Flutter', 'Dart', 'SQLite', 'REST API'],
      githubUrl: 'https://github.com',
      category: 'Mobile',
    ),
    ProjectModel(
      id: '3',
      title: 'Finance Dashboard',
      description:
          'Dashboard financeiro com gráficos interativos, controle de gastos, metas e relatórios mensais. Design clean e intuitivo.',
      technologies: ['Flutter', 'fl_chart', 'Hive', 'BLoC'],
      githubUrl: 'https://github.com',
      liveUrl: 'https://web.app',
      category: 'Web',
    ),
    ProjectModel(
      id: '4',
      title: 'Social Connect',
      description:
          'Rede social com feed em tempo real, stories, mensagens privadas, sistema de seguidores e algoritmo de recomendação.',
      technologies: ['Flutter', 'Firebase', 'WebRTC', 'Riverpod'],
      githubUrl: 'https://github.com',
      category: 'Mobile',
    ),
  ];

  List<ProjectModel> getAll() => _projects;

  List<ProjectModel> getByCategory(String category) =>
      _projects.where((p) => p.category == category).toList();
}
