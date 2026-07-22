import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const projects = new Hono();

function parseProject(project) {
  return {
    ...project,
    technologies: JSON.parse(project.technologies),
    images: JSON.parse(project.images || '[]'),
    featured: Boolean(project.featured),
  };
}

projects.get('/', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM projects ORDER BY order_index ASC').all();
  return c.json(results.map(parseProject));
});

projects.get('/:id', async (c) => {
  const id = c.req.param('id');
  const project = await c.env.DB.prepare('SELECT * FROM projects WHERE id = ?').bind(id).first();
  if (!project) return c.json({ error: 'Projeto não encontrado' }, 404);
  return c.json(parseProject(project));
});

projects.post('/', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { title, description, category, technologies, github_url, live_url, image_url, images, featured, order_index } = body;
  if (!title || !description || !category || !technologies) {
    return c.json({ error: 'Campos obrigatórios: title, description, category, technologies' }, 400);
  }
  const result = await c.env.DB.prepare(`
    INSERT INTO projects (title, description, category, technologies, github_url, live_url, image_url, images, featured, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    title, description, category, JSON.stringify(technologies),
    github_url || null, live_url || null, image_url || null, JSON.stringify(images || []),
    featured ? 1 : 0, order_index || 0
  ).run();

  const project = await c.env.DB.prepare('SELECT * FROM projects WHERE id = ?').bind(result.meta.last_row_id).first();
  return c.json(parseProject(project), 201);
});

projects.put('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT * FROM projects WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Projeto não encontrado' }, 404);

  const body = await c.req.json().catch(() => ({}));
  const { title, description, category, technologies, github_url, live_url, image_url, images, featured, order_index } = body;

  await c.env.DB.prepare(`
    UPDATE projects SET title = ?, description = ?, category = ?, technologies = ?,
    github_url = ?, live_url = ?, image_url = ?, images = ?, featured = ?, order_index = ?
    WHERE id = ?
  `).bind(
    title ?? existing.title,
    description ?? existing.description,
    category ?? existing.category,
    technologies ? JSON.stringify(technologies) : existing.technologies,
    github_url ?? existing.github_url,
    live_url ?? existing.live_url,
    image_url ?? existing.image_url,
    images ? JSON.stringify(images) : existing.images,
    featured !== undefined ? (featured ? 1 : 0) : existing.featured,
    order_index ?? existing.order_index,
    id
  ).run();

  const updated = await c.env.DB.prepare('SELECT * FROM projects WHERE id = ?').bind(id).first();
  return c.json(parseProject(updated));
});

projects.delete('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const existing = await c.env.DB.prepare('SELECT id FROM projects WHERE id = ?').bind(id).first();
  if (!existing) return c.json({ error: 'Projeto não encontrado' }, 404);
  await c.env.DB.prepare('DELETE FROM projects WHERE id = ?').bind(id).run();
  return c.json({ message: 'Projeto deletado com sucesso' });
});

export default projects;
