import { Hono } from 'hono';
import { cors } from 'hono/cors';

import authRoutes from './routes/auth.routes.js';
import aboutRoutes from './routes/about.routes.js';
import projectsRoutes from './routes/projects.routes.js';
import skillsRoutes from './routes/skills.routes.js';
import experienceRoutes from './routes/experience.routes.js';
import contactRoutes from './routes/contact.routes.js';
import servicesRoutes from './routes/services.routes.js';
import educationRoutes from './routes/education.routes.js';

const app = new Hono();

// CORS: always allow localhost (any port, http/https) for local dev, plus whatever
// extra origins are configured in ALLOWED_ORIGINS (comma-separated, e.g. the real
// Cloudflare Pages domain in production).
const LOCALHOST_RE = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

app.use('/api/*', async (c, next) => {
  const extraOrigins = (c.env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);

  const corsMiddleware = cors({
    origin: (origin) => {
      if (!origin) return origin;
      if (LOCALHOST_RE.test(origin)) return origin;
      if (extraOrigins.includes(origin)) return origin;
      return null;
    },
    allowHeaders: ['Content-Type', 'Authorization'],
    allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  });

  return corsMiddleware(c, next);
});

// Rotas, montadas em /api/*
app.route('/api/auth', authRoutes);
app.route('/api/about', aboutRoutes);
app.route('/api/projects', projectsRoutes);
app.route('/api/skills', skillsRoutes);
app.route('/api/experience', experienceRoutes);
app.route('/api/contact', contactRoutes);
app.route('/api/services', servicesRoutes);
app.route('/api/education', educationRoutes);

// Health check
app.get('/api/health', (c) => c.json({ status: 'ok', message: 'API Portfolio rodando' }));

// 404 — mesmo shape do middleware antigo
app.notFound((c) => c.json({ error: 'Rota não encontrada' }, 404));

// Error handler — mesmo shape do error.middleware.js antigo
app.onError((err, c) => {
  console.error(err.stack || err);
  const status = err.status && Number.isInteger(err.status) ? err.status : 500;
  return c.json({ error: err.message || 'Erro interno do servidor' }, status);
});

export default app;
