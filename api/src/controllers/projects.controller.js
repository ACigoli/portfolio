const { getDb } = require('../database/connection');

function parseProject(project) {
  return {
    ...project,
    technologies: JSON.parse(project.technologies),
    featured: Boolean(project.featured),
  };
}

function getAll(req, res) {
  const db = getDb();
  const projects = db.prepare('SELECT * FROM projects ORDER BY order_index ASC').all();
  res.json(projects.map(parseProject));
}

function getById(req, res) {
  const db = getDb();
  const project = db.prepare('SELECT * FROM projects WHERE id = ?').get(req.params.id);
  if (!project) return res.status(404).json({ error: 'Projeto não encontrado' });
  res.json(parseProject(project));
}

function create(req, res) {
  const { title, description, category, technologies, github_url, live_url, image_url, featured, order_index } = req.body;
  if (!title || !description || !category || !technologies) {
    return res.status(400).json({ error: 'Campos obrigatórios: title, description, category, technologies' });
  }
  const db = getDb();
  const result = db.prepare(`
    INSERT INTO projects (title, description, category, technologies, github_url, live_url, image_url, featured, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(title, description, category, JSON.stringify(technologies), github_url || null, live_url || null, image_url || null, featured ? 1 : 0, order_index || 0);
  const project = db.prepare('SELECT * FROM projects WHERE id = ?').get(result.lastInsertRowid);
  res.status(201).json(parseProject(project));
}

function update(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM projects WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Projeto não encontrado' });

  const { title, description, category, technologies, github_url, live_url, image_url, featured, order_index } = req.body;
  db.prepare(`
    UPDATE projects SET title = ?, description = ?, category = ?, technologies = ?,
    github_url = ?, live_url = ?, image_url = ?, featured = ?, order_index = ?
    WHERE id = ?
  `).run(
    title ?? existing.title,
    description ?? existing.description,
    category ?? existing.category,
    technologies ? JSON.stringify(technologies) : existing.technologies,
    github_url ?? existing.github_url,
    live_url ?? existing.live_url,
    image_url ?? existing.image_url,
    featured !== undefined ? (featured ? 1 : 0) : existing.featured,
    order_index ?? existing.order_index,
    req.params.id
  );
  res.json(parseProject(db.prepare('SELECT * FROM projects WHERE id = ?').get(req.params.id)));
}

function remove(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT id FROM projects WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Projeto não encontrado' });
  db.prepare('DELETE FROM projects WHERE id = ?').run(req.params.id);
  res.json({ message: 'Projeto deletado com sucesso' });
}

module.exports = { getAll, getById, create, update, remove };
