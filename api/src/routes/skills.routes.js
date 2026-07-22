import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const skills = new Hono();

skills.get('/', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM skills ORDER BY order_index ASC').all();
  return c.json(results);
});

skills.post('/', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { name, level, category, order_index } = body;
  if (!name || level === undefined || !category) {
    return c.json({ error: 'Campos obrigatórios: name, level, category' }, 400);
  }
  const result = await c.env.DB.prepare(
    'INSERT INTO skills (name, level, category, order_index) VALUES (?, ?, ?, ?)'
  ).bind(name, level, category, order_index || 0).run();

  const skill = await c.env.DB.prepare('SELECT * FROM skills WHERE id = ?').bind(result.meta.last_row_id).first();
  return c.json(skill, 201);
});

skills.put('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT * FROM skills WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Skill não encontrada' }, 404);

  const body = await c.req.json().catch(() => ({}));
  const { name, level, category, order_index } = body;
  await c.env.DB.prepare(
    'UPDATE skills SET name = ?, level = ?, category = ?, order_index = ? WHERE id = ?'
  ).bind(
    name ?? existing.name, level ?? existing.level, category ?? existing.category,
    order_index ?? existing.order_index, id
  ).run();

  const updated = await c.env.DB.prepare('SELECT * FROM skills WHERE id = ?').bind(id).first();
  return c.json(updated);
});

skills.delete('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM skills WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Skill não encontrada' }, 404);
  await c.env.DB.prepare('DELETE FROM skills WHERE id = ?').bind(id).run();
  return c.json({ message: 'Skill deletada com sucesso' });
});

export default skills;
