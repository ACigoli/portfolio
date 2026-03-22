const { getDb } = require('../database/connection');

function getAbout(req, res) {
  const db = getDb();
  const about = db.prepare('SELECT * FROM about WHERE id = 1').get();
  if (!about) return res.status(404).json({ error: 'Informações não encontradas' });
  res.json({ ...about, available: Boolean(about.available) });
}

function updateAbout(req, res) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM about WHERE id = 1').get();
  if (!existing) return res.status(404).json({ error: 'Informações não encontradas' });

  const { name, role, bio, location, email, avatar_url, cv_url, github_url, linkedin_url, instagram_url, available } = req.body;
  db.prepare(`
    UPDATE about SET name = ?, role = ?, bio = ?, location = ?, email = ?,
    avatar_url = ?, cv_url = ?, github_url = ?, linkedin_url = ?, instagram_url = ?, available = ?
    WHERE id = 1
  `).run(
    name ?? existing.name, role ?? existing.role, bio ?? existing.bio,
    location ?? existing.location, email ?? existing.email,
    avatar_url ?? existing.avatar_url, cv_url ?? existing.cv_url,
    github_url ?? existing.github_url, linkedin_url ?? existing.linkedin_url,
    instagram_url ?? existing.instagram_url,
    available !== undefined ? (available ? 1 : 0) : existing.available
  );
  const updated = db.prepare('SELECT * FROM about WHERE id = 1').get();
  res.json({ ...updated, available: Boolean(updated.available) });
}

module.exports = { getAbout, updateAbout };
