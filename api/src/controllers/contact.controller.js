const { getDb } = require('../database/connection');

function sendMessage(req, res) {
  const { name, email, message } = req.body;
  if (!name || !email || !message) {
    return res.status(400).json({ error: 'Campos obrigatórios: name, email, message' });
  }
  const db = getDb();
  const result = db.prepare('INSERT INTO messages (name, email, message) VALUES (?, ?, ?)').run(name, email, message);
  res.status(201).json({ message: 'Mensagem enviada com sucesso', id: result.lastInsertRowid });
}

function getAll(req, res) {
  const db = getDb();
  const messages = db.prepare('SELECT * FROM messages ORDER BY created_at DESC').all();
  res.json(messages.map(m => ({ ...m, read: Boolean(m.read) })));
}

function markRead(req, res) {
  const db = getDb();
  if (!db.prepare('SELECT id FROM messages WHERE id = ?').get(req.params.id)) {
    return res.status(404).json({ error: 'Mensagem não encontrada' });
  }
  db.prepare('UPDATE messages SET read = 1 WHERE id = ?').run(req.params.id);
  res.json({ message: 'Mensagem marcada como lida' });
}

function remove(req, res) {
  const db = getDb();
  if (!db.prepare('SELECT id FROM messages WHERE id = ?').get(req.params.id)) {
    return res.status(404).json({ error: 'Mensagem não encontrada' });
  }
  db.prepare('DELETE FROM messages WHERE id = ?').run(req.params.id);
  res.json({ message: 'Mensagem deletada' });
}

module.exports = { sendMessage, getAll, markRead, remove };
