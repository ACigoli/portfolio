const { getDb } = require('../database/connection');

function parseExp(exp) {
  return { ...exp, technologies: JSON.parse(exp.technologies), current: Boolean(exp.current) };
}

function getAll(req, res) {
  const db = getDb();
  res.json(db.prepare('SELECT * FROM experience ORDER BY order_index ASC').all().map(parseExp));
}

function create(req, res) {
  const { company, role, description, start_date, end_date, current, technologies, order_index } = req.body;
  if (!company || !role || !description || !start_date || !technologies) {
    return res.status(400).json({ error: 'Campos obrigatórios: company, role, description, start_date, technologies' });
  }
  const db = getDb();
  const result = db.prepare(`
    INSERT INTO experience (company, role, description, start_date, end_date, current, technologies, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(company, role, description, start_date, end_date || null, current ? 1 : 0, JSON.stringify(technologies), order_index || 0);
  res.status(201).json(parseExp(db.prepare('SELECT * FROM experience WHERE id = ?').get(result.lastInsertRowid)));
}

function update(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM experience WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Experiência não encontrada' });
  const { company, role, description, start_date, end_date, current, technologies, order_index } = req.body;
  db.prepare(`
    UPDATE experience SET company = ?, role = ?, description = ?, start_date = ?,
    end_date = ?, current = ?, technologies = ?, order_index = ? WHERE id = ?
  `).run(
    company ?? existing.company, role ?? existing.role, description ?? existing.description,
    start_date ?? existing.start_date, end_date ?? existing.end_date,
    current !== undefined ? (current ? 1 : 0) : existing.current,
    technologies ? JSON.stringify(technologies) : existing.technologies,
    order_index ?? existing.order_index, req.params.id
  );
  res.json(parseExp(db.prepare('SELECT * FROM experience WHERE id = ?').get(req.params.id)));
}

function remove(req, res) {
  const db = getDb();
  if (!db.prepare('SELECT id FROM experience WHERE id = ?').get(req.params.id)) {
    return res.status(404).json({ error: 'Experiência não encontrada' });
  }
  db.prepare('DELETE FROM experience WHERE id = ?').run(req.params.id);
  res.json({ message: 'Experiência deletada com sucesso' });
}

module.exports = { getAll, create, update, remove };
