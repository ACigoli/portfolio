import { Hono } from 'hono';
import bcrypt from 'bcryptjs';
import { sign } from 'hono/jwt';

const auth = new Hono();

const SEVEN_DAYS_SECONDS = 7 * 24 * 60 * 60;

auth.post('/login', async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { email, password } = body;

  if (!email || !password) {
    return c.json({ error: 'Email e senha são obrigatórios' }, 400);
  }

  const admin = await c.env.DB.prepare('SELECT * FROM admins WHERE email = ?').bind(email).first();

  if (!admin || !bcrypt.compareSync(password, admin.password)) {
    return c.json({ error: 'Credenciais inválidas' }, 401);
  }

  const payload = {
    id: admin.id,
    email: admin.email,
    exp: Math.floor(Date.now() / 1000) + SEVEN_DAYS_SECONDS,
  };
  const token = await sign(payload, c.env.JWT_SECRET || 'secret', 'HS256');

  return c.json({ token, email: admin.email });
});

export default auth;
