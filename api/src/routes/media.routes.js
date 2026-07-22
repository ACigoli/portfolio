import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth.middleware.js';

const media = new Hono();

const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);
const MAX_BYTES = 8 * 1024 * 1024; // 8MB

// Upload de imagem (protegido) — usado pelo painel admin. Recebe
// multipart/form-data com um campo "file", devolve a URL pública servida
// pela própria API (via GET /api/media/:key).
media.post('/upload', authMiddleware, async (c) => {
  const body = await c.req.parseBody().catch(() => ({}));
  const file = body.file;

  if (!file || typeof file === 'string') {
    return c.json({ error: 'Arquivo obrigatório (campo "file")' }, 400);
  }
  if (!ALLOWED_TYPES.has(file.type)) {
    return c.json({ error: 'Tipo de arquivo não suportado (use JPEG, PNG, WebP ou GIF)' }, 400);
  }
  if (file.size > MAX_BYTES) {
    return c.json({ error: 'Arquivo muito grande (máximo 8MB)' }, 400);
  }

  const ext = file.name?.includes('.') ? file.name.split('.').pop() : 'jpg';
  const key = `${crypto.randomUUID()}.${ext}`;

  await c.env.MEDIA.put(key, await file.arrayBuffer(), {
    httpMetadata: { contentType: file.type },
  });

  const url = `${new URL(c.req.url).origin}/api/media/${key}`;
  return c.json({ url, key }, 201);
});

// Serve o objeto do R2 (público, com cache agressivo — a key é um UUID,
// então o conteúdo de uma key nunca muda).
media.get('/:key', async (c) => {
  const key = c.req.param('key');
  const object = await c.env.MEDIA.get(key);
  if (!object) return c.json({ error: 'Arquivo não encontrado' }, 404);

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream',
      'Cache-Control': 'public, max-age=31536000, immutable',
      ETag: object.httpEtag,
    },
  });
});

// Remove um objeto (protegido) — usado quando o admin apaga uma imagem do
// projeto sem apagar o projeto inteiro.
media.delete('/:key', authMiddleware, async (c) => {
  const key = c.req.param('key');
  await c.env.MEDIA.delete(key);
  return c.json({ message: 'Arquivo removido com sucesso' });
});

export default media;
