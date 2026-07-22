# Portfolio API

API REST do portfólio, em [Hono](https://hono.dev/) + [D1](https://developers.cloudflare.com/d1/) rodando em Cloudflare Workers.

## Desenvolvimento local

```bash
npm install
cp .dev.vars.example .dev.vars   # edite JWT_SECRET com um valor local
npx wrangler d1 migrations apply portfolio-db --local
npx wrangler dev
```

A API sobe em `http://localhost:8787`, com todas as rotas montadas em `/api/*` (ex.: `http://localhost:8787/api/health`).

## Banco de dados (D1)

1. Criar o banco real na sua conta Cloudflare (não incluso neste repo/execução automatizada):
   ```bash
   npx wrangler d1 create portfolio-db
   ```
   Copie o `database_id` retornado para `wrangler.jsonc`.

2. Aplicar as migrations:
   ```bash
   npx wrangler d1 migrations apply portfolio-db --local   # ambiente local
   npx wrangler d1 migrations apply portfolio-db --remote  # banco de produção
   ```

`migrations/0001_init.sql` cria as 7 tabelas (about, projects, skills, experience, messages, services, education, admins). `migrations/0002_seed.sql` popula dados públicos de exemplo (about/projects/skills/services/experience) — **não contém a conta de admin**, de propósito, para não commitar segredos.

## Seed do admin (manual, sem segredos no git)

1. Gere o hash bcrypt da senha localmente (nunca comitado):
   ```bash
   node scripts/hash-password.mjs "sua_senha_segura"
   ```
2. Copie o hash impresso e rode contra o banco remoto:
   ```bash
   npx wrangler d1 execute portfolio-db --remote --command="INSERT INTO admins (email, password) VALUES ('admin@seudominio.com', '<hash_gerado>')"
   ```
   Troque `admin@seudominio.com` pelo email real do admin.

## Secrets / variáveis

- `JWT_SECRET` — segredo usado para assinar/verificar os tokens (`hono/jwt`).
  - Local: definido em `.dev.vars` (veja `.dev.vars.example`).
  - Produção: `npx wrangler secret put JWT_SECRET`.
- `ALLOWED_ORIGINS` — lista de origens extras permitidas por CORS (além de `localhost`/`127.0.0.1`, sempre liberados), separadas por vírgula. Definida em `wrangler.jsonc` (`vars.ALLOWED_ORIGINS`) — troque o placeholder pelo domínio real do Cloudflare Pages antes do deploy.

## Deploy

```bash
npx wrangler deploy
```

## Estrutura

```
api/
  wrangler.jsonc              # binding D1 "DB", vars, compatibility_date
  migrations/                 # schema + seed público (D1)
  src/
    index.js                  # app Hono, monta rotas em /api/*, cors/onError/notFound
    routes/                   # roteamento + handlers por recurso (sem controllers/ separado)
    middleware/auth.middleware.js
  scripts/hash-password.mjs   # gera hash bcrypt para seed manual do admin
  .dev.vars.example           # JWT_SECRET de exemplo p/ wrangler dev
```

## Rotas

| Recurso     | GET (lista) | GET /:id | POST | PUT/PATCH | DELETE |
|-------------|:-----------:|:--------:|:----:|:---------:|:------:|
| `/api/about`      | público | — | — | protegido (`PUT`) | — |
| `/api/projects`   | público | público | protegido | protegido | protegido |
| `/api/skills`     | público | — | protegido | protegido | protegido |
| `/api/experience` | público | — | protegido | protegido | protegido |
| `/api/services`   | público | — | protegido | protegido | protegido |
| `/api/education`  | público | — | protegido | protegido | protegido |
| `/api/contact`    | protegido | — | público | protegido (`PATCH /:id/read`) | protegido |
| `/api/auth/login` | — | — | público | — | — |

Rotas protegidas exigem header `Authorization: Bearer <token>` obtido em `POST /api/auth/login`.
