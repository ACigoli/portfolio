import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const education = new Hono();

education.get('/', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM education ORDER BY order_index ASC').all();
  return c.json(results);
});

education.post('/', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { institution, degree, field, start_year, end_year, current, description, order_index } = body;
  if (!institution || !degree || !field || !start_year) {
    return c.json({ error: 'Campos obrigatórios: institution, degree, field, start_year' }, 400);
  }
  const result = await c.env.DB.prepare(`
    INSERT INTO education (institution, degree, field, start_year, end_year, current, description, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    institution, degree, field, start_year, end_year || null,
    current ? 1 : 0, description || null, order_index || 0
  ).run();

  const row = await c.env.DB.prepare('SELECT * FROM education WHERE id = ?').bind(result.meta.last_row_id).first();
  return c.json(row, 201);
});

education.put('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT * FROM education WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Formação não encontrada' }, 404);

  const body = await c.req.json().catch(() => ({}));
  const { institution, degree, field, start_year, end_year, current, description, order_index } = body;

  await c.env.DB.prepare(`
    UPDATE education SET institution = ?, degree = ?, field = ?, start_year = ?,
    end_year = ?, current = ?, description = ?, order_index = ? WHERE id = ?
  `).bind(
    institution ?? existing.institution,
    degree ?? existing.degree,
    field ?? existing.field,
    start_year ?? existing.start_year,
    end_year !== undefined ? (end_year || null) : existing.end_year,
    current !== undefined ? (current ? 1 : 0) : existing.current,
    description !== undefined ? description : existing.description,
    order_index ?? existing.order_index,
    id
  ).run();

  const updated = await c.env.DB.prepare('SELECT * FROM education WHERE id = ?').bind(id).first();
  return c.json(updated);
});

education.delete('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM education WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Formação não encontrada' }, 404);
  await c.env.DB.prepare('DELETE FROM education WHERE id = ?').bind(id).run();
  return c.json({ message: 'Formação deletada com sucesso' });
});

export default education;
