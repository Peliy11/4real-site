import { kv } from '@vercel/kv';
import { randomUUID } from 'crypto';

function checkAuth(req) {
  const auth = req.headers.authorization || '';
  const expected = 'Basic ' + btoa(process.env.ADMIN_PASSWORD || '');
  return auth === expected;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method === 'GET') {
    const keys = await kv.keys('script:*');
    const scripts = [];
    for (const key of keys) {
      const s = await kv.get(key);
      if (s) scripts.push({ id: s.id, name: s.name, slug: s.slug, description: s.description, created: s.created, loadCount: s.loadCount || 0 });
    }
    scripts.sort((a, b) => new Date(b.created) - new Date(a.created));
    return res.json(scripts);
  }

  if (req.method === 'POST') {
    if (!checkAuth(req)) return res.status(401).json({ error: 'Unauthorized' });

    const { name, description, code } = req.body;
    if (!name || !code) return res.status(400).json({ error: 'Name and code required' });

    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    const existing = await kv.get(`slug:${slug}`);
    if (existing) return res.status(409).json({ error: 'Script name already exists' });

    const id = randomUUID();
    const script = { id, name, slug, description: description || '', code, created: new Date().toISOString(), loadCount: 0 };

    await kv.set(`script:${id}`, script);
    await kv.set(`slug:${slug}`, id);

    return res.json({ id, slug, name });
  }

  res.status(405).end();
}
