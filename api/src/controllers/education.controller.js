const { getDb } = require('../database/connection');

function getAll(req, res) {
  const db = getDb();
  res.json(db.prepare('SELECT * FROM education ORDER BY order_index ASC').all());
}

function create(req, res) {
  const { institution, degree, field, start_year, end_year, current, description, order_index } = req.body;
  if (!institution || !degree || !field || !start_year) {
    return res.status(400).json({ error: 'Campos obrigatórios: institution, degree, field, start_year' });
  }
  const db = getDb();
  const result = db.prepare(`
    INSERT INTO education (institution, degree, field, start_year, end_year, current, description, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(institution, degree, field, start_year, end_year || null, current ? 1 : 0, description || null, order_index || 0);
  res.status(201).json(db.prepare('SELECT * FROM education WHERE id = ?').get(result.lastInsertRowid));
}

function update(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM education WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Formação não encontrada' });
  const { institution, degree, field, start_year, end_year, current, description, order_index } = req.body;
  db.prepare(`
    UPDATE education SET institution = ?, degree = ?, field = ?, start_year = ?,
    end_year = ?, current = ?, description = ?, order_index = ? WHERE id = ?
  `).run(
    institution ?? existing.institution,
    degree ?? existing.degree,
    field ?? existing.field,
    start_year ?? existing.start_year,
    end_year !== undefined ? (end_year || null) : existing.end_year,
    current !== undefined ? (current ? 1 : 0) : existing.current,
    description !== undefined ? description : existing.description,
    order_index ?? existing.order_index,
    req.params.id
  );
  res.json(db.prepare('SELECT * FROM education WHERE id = ?').get(req.params.id));
}

function remove(req, res) {
  const db = getDb();
  if (!db.prepare('SELECT id FROM education WHERE id = ?').get(req.params.id)) {
    return res.status(404).json({ error: 'Formação não encontrada' });
  }
  db.prepare('DELETE FROM education WHERE id = ?').run(req.params.id);
  res.json({ message: 'Formação deletada com sucesso' });
}

module.exports = { getAll, create, update, remove };
