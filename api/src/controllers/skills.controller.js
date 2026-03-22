const { getDb } = require('../database/connection');

function getAll(req, res) {
  const db = getDb();
  const skills = db.prepare('SELECT * FROM skills ORDER BY order_index ASC').all();
  res.json(skills);
}

function create(req, res) {
  const { name, level, category, order_index } = req.body;
  if (!name || level === undefined || !category) {
    return res.status(400).json({ error: 'Campos obrigatórios: name, level, category' });
  }
  const db = getDb();
  const result = db.prepare('INSERT INTO skills (name, level, category, order_index) VALUES (?, ?, ?, ?)').run(name, level, category, order_index || 0);
  res.status(201).json(db.prepare('SELECT * FROM skills WHERE id = ?').get(result.lastInsertRowid));
}

function update(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM skills WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Skill não encontrada' });
  const { name, level, category, order_index } = req.body;
  db.prepare('UPDATE skills SET name = ?, level = ?, category = ?, order_index = ? WHERE id = ?').run(
    name ?? existing.name, level ?? existing.level, category ?? existing.category, order_index ?? existing.order_index, req.params.id
  );
  res.json(db.prepare('SELECT * FROM skills WHERE id = ?').get(req.params.id));
}

function remove(req, res) {
  const db = getDb();
  if (!db.prepare('SELECT id FROM skills WHERE id = ?').get(req.params.id)) {
    return res.status(404).json({ error: 'Skill não encontrada' });
  }
  db.prepare('DELETE FROM skills WHERE id = ?').run(req.params.id);
  res.json({ message: 'Skill deletada com sucesso' });
}

module.exports = { getAll, create, update, remove };
