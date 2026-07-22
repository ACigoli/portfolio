import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const about = new Hono();

about.get('/', async (c) => {
  const row = await c.env.DB.prepare('SELECT * FROM about WHERE id = 1').first();
  if (!row) return c.json({ error: 'Informações não encontradas' }, 404);
  return c.json({ ...row, available: Boolean(row.available) });
});

about.put('/', authMiddleware, async (c) => {
  const existing = await c.env.DB.prepare('SELECT * FROM about WHERE id = 1').first();
  if (!existing) return c.json({ error: 'Informações não encontradas' }, 404);

  const body = await c.req.json().catch(() => ({}));
  const {
    name, role, bio, location, email,
    avatar_url, cv_url, github_url, linkedin_url, instagram_url, available,
  } = body;

  await c.env.DB.prepare(`
    UPDATE about SET name = ?, role = ?, bio = ?, location = ?, email = ?,
    avatar_url = ?, cv_url = ?, github_url = ?, linkedin_url = ?, instagram_url = ?, available = ?
    WHERE id = 1
  `).bind(
    name ?? existing.name, role ?? existing.role, bio ?? existing.bio,
    location ?? existing.location, email ?? existing.email,
    avatar_url ?? existing.avatar_url, cv_url ?? existing.cv_url,
    github_url ?? existing.github_url, linkedin_url ?? existing.linkedin_url,
    instagram_url ?? existing.instagram_url,
    available !== undefined ? (available ? 1 : 0) : existing.available
  ).run();

  const updated = await c.env.DB.prepare('SELECT * FROM about WHERE id = 1').first();
  return c.json({ ...updated, available: Boolean(updated.available) });
});

export default about;
