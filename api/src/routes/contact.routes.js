import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const contact = new Hono();

// POST is public (the site's contact form); GET/PATCH/DELETE are admin-only.

contact.post('/', async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { name, email, message } = body;
  if (!name || !email || !message) {
    return c.json({ error: 'Campos obrigatórios: name, email, message' }, 400);
  }
  const result = await c.env.DB.prepare(
    'INSERT INTO messages (name, email, message) VALUES (?, ?, ?)'
  ).bind(name, email, message).run();

  return c.json({ message: 'Mensagem enviada com sucesso', id: result.meta.last_row_id }, 201);
});

contact.get('/', authMiddleware, async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM messages ORDER BY created_at DESC').all();
  return c.json(results.map((m) => ({ ...m, read: Boolean(m.read) })));
});

contact.patch('/:id/read', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM messages WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Mensagem não encontrada' }, 404);
  await c.env.DB.prepare('UPDATE messages SET read = 1 WHERE id = ?').bind(id).run();
  return c.json({ message: 'Mensagem marcada como lida' });
});

contact.delete('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM messages WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Mensagem não encontrada' }, 404);
  await c.env.DB.prepare('DELETE FROM messages WHERE id = ?').bind(id).run();
  return c.json({ message: 'Mensagem deletada' });
});

export default contact;
