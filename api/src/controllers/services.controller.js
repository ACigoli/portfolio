const { getDb } = require('../database/connection');

function getAll(req, res) {
  const db = getDb();
  const services = db.prepare('SELECT * FROM services ORDER BY order_index ASC').all();
  res.json(services);
}

function create(req, res) {
  const { title, description, icon_name, gradient_start, gradient_end, features, order_index } = req.body;
  if (!title || !description) {
    return res.status(400).json({ error: 'Campos obrigatórios: title, description' });
  }
  const db = getDb();
  const result = db.prepare(`
    INSERT INTO services (title, description, icon_name, gradient_start, gradient_end, features, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    title,
    description,
    icon_name || 'code',
    gradient_start || '#915EFF',
    gradient_end || '#6366F1',
    features || '',
    order_index || 0
  );
  res.status(201).json(db.prepare('SELECT * FROM services WHERE id = ?').get(result.lastInsertRowid));
}

function update(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM services WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Serviço não encontrado' });
  const { title, description, icon_name, gradient_start, gradient_end, features, order_index } = req.body;
  db.prepare(`
    UPDATE services
    SET title = ?, description = ?, icon_name = ?, gradient_start = ?, gradient_end = ?, features = ?, order_index = ?
    WHERE id = ?
  `).run(
    title ?? existing.title,
    description ?? existing.description,
    icon_name ?? existing.icon_name,
    gradient_start ?? existing.gradient_start,
    gradient_end ?? existing.gradient_end,
    features ?? existing.features,
    order_index ?? existing.order_index,
    req.params.id
  );
  res.json(db.prepare('SELECT * FROM services WHERE id = ?').get(req.params.id));
}

function remove(req, res) {
  const db = getDb();
  if (!db.prepare('SELECT id FROM services WHERE id = ?').get(req.params.id)) {
    return res.status(404).json({ error: 'Serviço não encontrado' });
  }
  db.prepare('DELETE FROM services WHERE id = ?').run(req.params.id);
  res.json({ message: 'Serviço deletado com sucesso' });
}

module.exports = { getAll, create, update, remove };
