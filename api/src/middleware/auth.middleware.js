import { verify } from 'hono/jwt';

// Verifies a Bearer JWT and exposes the decoded payload as c.get('admin') for
// downstream handlers. Same 401 messages/behavior as the old Express middleware.
export async function authMiddleware(c, next) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Token não fornecido' }, 401);
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = await verify(token, c.env.JWT_SECRET || 'secret', 'HS256');
    c.set('admin', decoded);
    await next();
  } catch {
    return c.json({ error: 'Token inválido ou expirado' }, 401);
  }
}
