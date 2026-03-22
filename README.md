# Alex Cigoli | Portfolio

Portfolio pessoal fullstack com painel administrativo, construído com **Flutter Web** (frontend) e **Node.js + Express** (backend).

## Visão Geral

- Frontend em Flutter Web com tema escuro e animações
- Backend REST API com autenticação JWT
- Banco de dados SQLite via `better-sqlite3`
- Painel admin protegido por login para gerenciar todo o conteúdo

## Estrutura do Projeto

```
potfolio_complete/
├── portfolio/   # Flutter Web (frontend)
└── api/         # Node.js + Express (backend)
```

## Tecnologias

### Frontend (`portfolio/`)
| Pacote | Uso |
|---|---|
| Flutter 3 / Dart | Framework principal |
| `go_router` | Navegação |
| `mobx` + `flutter_mobx` | Gerenciamento de estado |
| `http` | Comunicação com a API |
| `shared_preferences` | Persistência do token JWT |

### Backend (`api/`)
| Pacote | Uso |
|---|---|
| Node.js + Express | Servidor HTTP |
| `better-sqlite3` | Banco de dados SQLite |
| `jsonwebtoken` | Autenticação JWT |
| `bcryptjs` | Hash de senhas |
| `cors` | Controle de origens |
| `dotenv` | Variáveis de ambiente |
| `nodemon` | Hot-reload em desenvolvimento |

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
- Edição da seção "Sobre mim"

## Como Executar

### 1. Backend

```bash
cd api
npm install
```

Crie o arquivo `.env` na raiz de `api/`:

```env
PORT=3000
JWT_SECRET=sua_chave_secreta
ADMIN_EMAIL=admin@exemplo.com
ADMIN_PASSWORD=sua_senha
```

```bash
# desenvolvimento
npm run dev

# produção
npm start
```

A API ficará disponível em `http://localhost:3000`.

### 2. Frontend

```bash
cd portfolio
flutter pub get
flutter run -d chrome
```

> O frontend aponta para `http://localhost:3000/api` por padrão (configurado em `lib/services/api_service.dart`).

## Rotas da API

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/api/auth/login` | — | Login do admin |
| GET/PUT | `/api/about` | PUT requer token | Seção "Sobre" |
| GET | `/api/projects` | — | Lista projetos |
| POST/PUT/DELETE | `/api/projects/:id` | Sim | CRUD projetos |
| GET | `/api/skills` | — | Lista habilidades |
| POST/PUT/DELETE | `/api/skills/:id` | Sim | CRUD habilidades |
| GET | `/api/experience` | — | Lista experiências |
| POST/PUT/DELETE | `/api/experience/:id` | Sim | CRUD experiências |
| GET | `/api/services` | — | Lista serviços |
| POST/PUT/DELETE | `/api/services/:id` | Sim | CRUD serviços |
| POST | `/api/contact` | — | Envia mensagem |
| GET | `/api/contact` | Sim | Lista mensagens |
| PATCH | `/api/contact/:id/read` | Sim | Marca como lida |
| DELETE | `/api/contact/:id` | Sim | Remove mensagem |

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
