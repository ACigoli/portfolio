import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const services = new Hono();

// NOTE: `features` is a pipe-delimited string (e.g. "A|B|C"), not a JSON array —
// preserved exactly as the old Express API stored/returned it.

services.get('/', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM services ORDER BY order_index ASC').all();
  return c.json(results);
});

services.post('/', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { title, description, icon_name, gradient_start, gradient_end, features, order_index } = body;
  if (!title || !description) {
    return c.json({ error: 'Campos obrigatórios: title, description' }, 400);
  }
  const result = await c.env.DB.prepare(`
    INSERT INTO services (title, description, icon_name, gradient_start, gradient_end, features, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).bind(
    title,
    description,
    icon_name || 'code',
    gradient_start || '#915EFF',
    gradient_end || '#6366F1',
    features || '',
    order_index || 0
  ).run();

  const service = await c.env.DB.prepare('SELECT * FROM services WHERE id = ?').bind(result.meta.last_row_id).first();
  return c.json(service, 201);
});

services.put('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT * FROM services WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Serviço não encontrado' }, 404);

  const body = await c.req.json().catch(() => ({}));
  const { title, description, icon_name, gradient_start, gradient_end, features, order_index } = body;

  await c.env.DB.prepare(`
    UPDATE services
    SET title = ?, description = ?, icon_name = ?, gradient_start = ?, gradient_end = ?, features = ?, order_index = ?
    WHERE id = ?
  `).bind(
    title ?? existing.title,
    description ?? existing.description,
    icon_name ?? existing.icon_name,
    gradient_start ?? existing.gradient_start,
    gradient_end ?? existing.gradient_end,
    features ?? existing.features,
    order_index ?? existing.order_index,
    id
  ).run();

  const updated = await c.env.DB.prepare('SELECT * FROM services WHERE id = ?').bind(id).first();
  return c.json(updated);
});

services.delete('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM services WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Serviço não encontrado' }, 404);
  await c.env.DB.prepare('DELETE FROM services WHERE id = ?').bind(id).run();
  return c.json({ message: 'Serviço deletado com sucesso' });
});

export default services;
