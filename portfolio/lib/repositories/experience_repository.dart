import '../models/experience_model.dart';

class ExperienceRepository {
  static const List<ExperienceModel> _experiences = [
    ExperienceModel(
      company: 'TechCorp Solutions',
      role: 'Senior Flutter Developer',
      period: 'Jan 2023 — Presente',
      description:
          'Liderança técnica no desenvolvimento de aplicações mobile multiplataforma para mais de 500 mil usuários ativos.',
      achievements: [
        'Reduzi o tempo de carregamento em 40% com otimização de estado',
        'Implementei CI/CD reduzindo deploys de 2 dias para 2 horas',
        'Mentorei equipe de 4 desenvolvedores júnior',
      ],
      isCurrent: true,
    ),
    ExperienceModel(
      company: 'StartupX Digital',
      role: 'Flutter Developer',
      period: 'Mar 2021 — Dez 2022',
      description:
          'Desenvolvimento de MVP para startup de fintech, desde a concepção até o lançamento em produção.',
      achievements: [
        'Entreguei o app 3 semanas antes do prazo',
        'Alcancei 4.8 estrelas na App Store',
        'Integrei 3 gateways de pagamento distintos',
      ],
    ),
    ExperienceModel(
      company: 'Agência Creative Dev',
      role: 'Mobile Developer Jr.',
      period: 'Jun 2019 — Fev 2021',
      description:
          'Desenvolvimento de aplicativos para clientes de diferentes segmentos, focando em UI/UX e performance.',
      achievements: [
        'Desenvolvi 12+ aplicativos para clientes',
        'Aprendi Flutter em produção no lançamento do framework',
        'Implementei sistema de design reutilizável',
      ],
    ),
  ];

  List<ExperienceModel> getAll() => _experiences;
}
