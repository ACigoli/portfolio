# Alex Cigoli | Portfolio

Portfolio pessoal fullstack com painel administrativo, construído com **Flutter Web** (frontend) e **JavaScript** (backend, agora em **Hono + D1** rodando em **Cloudflare Workers**) — hospedado no **Cloudflare** (Pages + Workers).

## Visão Geral

- Frontend em Flutter Web, tema escuro premium (paleta violeta/verde-água consolidada, tipografia Space Grotesk + Plus Jakarta Sans, cards "double-bezel", nav em pílula flutuante, motion com curvas custom e scroll-reveal).
- Backend serverless em Hono + D1 (SQLite gerenciado pela Cloudflare), autenticação JWT.
- Painel admin protegido por login para gerenciar todo o conteúdo.
- Arquitetura organizada por **view**: cada tela vive isolada com sua própria `screen`, `components/` e `store/`.

## Estrutura do Projeto

```
potfolio_complete/
├── portfolio/   # Flutter Web (frontend) — ver portfolio/lib abaixo
└── api/         # Hono + D1 (backend, Cloudflare Workers) — ver api/README.md
```

### Frontend (`portfolio/lib/`)

```
lib/
  main.dart                    # GoRouter + usePathUrlStrategy()
  core/
    theme/app_theme.dart       # ThemeData (Space Grotesk / Plus Jakarta Sans via google_fonts)
    constants/app_constants.dart  # AppColors, AppSpacing, AppRadius, AppMotion
    config/env.dart            # Env.apiBaseUrl (via --dart-define)
  models/                      # ProjectModel, SkillModel, ExperienceModel, ServiceModel, EducationModel
  services/api_service.dart    # cliente HTTP da API
  shared/widgets/               # AnimatedBackground, GlassCard, PillButton, ScrollReveal
  views/
    home/
      home_screen.dart
      components/               # app_navbar, section_header, hero/about/skills/projects/experience/services/contact
      store/                     # about, projects, skills, experience, services, contact
    admin/
      shared/components/         # admin_shell, admin_sidebar, admin_form_dialog, admin_stat_card, ...
      login/       {login_screen.dart, store/auth_store.dart}
      dashboard/   {dashboard_screen.dart, store/dashboard_store.dart}
      projects/    {projects_screen.dart, components/, store/}
      skills/  experience/  services/  messages/   # mesmo padrão {screen, components/, store/}
      about/       {about_screen.dart, components/education_form_dialog.dart, store/admin_about_store.dart}
```

Cada view é autocontida: a `screen` monta a tela, `components/` guarda os widgets usados só ali, e `store/` guarda o estado (MobX, sem singleton global — cada `screen` cria sua própria store).

### Backend (`api/`)

Ver [`api/README.md`](api/README.md) para detalhes completos (rotas, migrations, seed do admin, deploy). Resumo:

| Pacote | Uso |
|---|---|
| [Hono](https://hono.dev/) | Framework HTTP nativo de Workers |
| [D1](https://developers.cloudflare.com/d1/) | Banco SQLite gerenciado pela Cloudflare |
| `hono/jwt` | Autenticação JWT (Web Crypto, sem dependência de Node) |
| `bcryptjs` | Hash de senha (JS puro) |

## Tecnologias (frontend)

| Pacote | Uso |
|---|---|
| Flutter 3 / Dart | Framework principal |
| `go_router` | Navegação |
| `mobx` + `flutter_mobx` | Gerenciamento de estado |
| `http` | Comunicação com a API |
| `shared_preferences` | Persistência do token JWT |
| `google_fonts` | Tipografia (Space Grotesk / Plus Jakarta Sans) |
| `visibility_detector` | Scroll-reveal (entrada de seções ao rolar a página) |

## Como Executar

### 1. Backend (API)

```bash
cd api
npm install
cp .dev.vars.example .dev.vars   # edite JWT_SECRET
npx wrangler d1 migrations apply portfolio-db --local
npx wrangler dev
```

A API sobe em `http://localhost:8787`, rotas em `/api/*`. Veja [`api/README.md`](api/README.md) para criar o banco D1 real, aplicar migrations em produção e semear o admin.

### 2. Frontend (Flutter)

```bash
cd portfolio
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8787/api
```

> A URL da API é configurável em build-time via `--dart-define=API_BASE_URL=...` (ver `lib/core/config/env.dart`). Sem essa flag, aponta para `http://localhost:8787/api` (padrão do `wrangler dev`).

## Deploy (Cloudflare)

**API (Workers):**
```bash
cd api
npx wrangler d1 create portfolio-db        # uma vez — copie o database_id para wrangler.jsonc
npx wrangler d1 migrations apply portfolio-db --remote
npx wrangler secret put JWT_SECRET
npx wrangler deploy
```

**Frontend (Pages):**
```bash
cd portfolio
flutter build web --dart-define=API_BASE_URL=https://<seu-worker>.workers.dev/api
npx wrangler pages deploy build/web
```

`portfolio/web/_redirects` já garante o fallback de SPA (`/* /index.html 200`) para as rotas do `go_router` funcionarem em navegação direta (ex.: `/admin/dashboard`).

## Funcionalidades

**Seções públicas:**
- Hero / Apresentação
- Sobre mim
- Habilidades (Skills)
- Experiência profissional
- Projetos
- Serviços
- Formulário de contato

**Painel admin (`/admin`):**
- Dashboard com estatísticas
- CRUD de Projetos, Habilidades, Experiências, Serviços
- Gerenciamento de mensagens recebidas
- Edição da seção "Sobre mim" (incluindo formação acadêmica)

## Rotas do Frontend

| Rota | Descrição |
|---|---|
| `/` | Página pública do portfolio |
| `/admin` | Login do painel admin |
| `/admin/dashboard` | Dashboard |
| `/admin/projects` | Gerenciar projetos |
| `/admin/skills` | Gerenciar habilidades |
| `/admin/experience` | Gerenciar experiências |
| `/admin/services` | Gerenciar serviços |
| `/admin/about` | Editar seção "Sobre" |
| `/admin/messages` | Visualizar mensagens |

Rotas da API: ver a tabela em [`api/README.md`](api/README.md).
