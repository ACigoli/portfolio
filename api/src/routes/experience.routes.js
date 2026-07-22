import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const experience = new Hono();

function parseExp(exp) {
  return { ...exp, technologies: JSON.parse(exp.technologies), current: Boolean(exp.current) };
}

experience.get('/', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM experience ORDER BY order_index ASC').all();
  return c.json(results.map(parseExp));
});

experience.post('/', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { company, role, description, start_date, end_date, current, technologies, order_index } = body;
  if (!company || !role || !description || !start_date || !technologies) {
    return c.json({ error: 'Campos obrigatórios: company, role, description, start_date, technologies' }, 400);
  }
  const result = await c.env.DB.prepare(`
    INSERT INTO experience (company, role, description, start_date, end_date, current, technologies, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    company, role, description, start_date, end_date || null,
    current ? 1 : 0, JSON.stringify(technologies), order_index || 0
  ).run();

  const exp = await c.env.DB.prepare('SELECT * FROM experience WHERE id = ?').bind(result.meta.last_row_id).first();
  return c.json(parseExp(exp), 201);
});

experience.put('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT * FROM experience WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Experiência não encontrada' }, 404);

  const body = await c.req.json().catch(() => ({}));
  const { company, role, description, start_date, end_date, current, technologies, order_index } = body;

  await c.env.DB.prepare(`
    UPDATE experience SET company = ?, role = ?, description = ?, start_date = ?,
    end_date = ?, current = ?, technologies = ?, order_index = ? WHERE id = ?
  `).bind(
    company ?? existing.company, role ?? existing.role, description ?? existing.description,
    start_date ?? existing.start_date, end_date ?? existing.end_date,
    current !== undefined ? (current ? 1 : 0) : existing.current,
    technologies ? JSON.stringify(technologies) : existing.technologies,
    order_index ?? existing.order_index, id
  ).run();

  const updated = await c.env.DB.prepare('SELECT * FROM experience WHERE id = ?').bind(id).first();
  return c.json(parseExp(updated));
});

experience.delete('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM experience WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Experiência não encontrada' }, 404);
  await c.env.DB.prepare('DELETE FROM experience WHERE id = ?').bind(id).run();
  return c.json({ message: 'Experiência deletada com sucesso' });
});

export default experience;
