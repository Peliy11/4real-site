import { kv } from '@vercel/kv';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const { id } = req.query;
  const script = await kv.get(`script:${id}`);
  if (!script) return res.status(404).json({ error: 'Not found' });

  if (req.method === 'GET') {
    return res.json(script);
  }

  if (req.method === 'PUT') {
    const { name, description, code } = req.body;
    if (name) {
      await kv.del(`slug:${script.slug}`);
      script.name = name;
      script.slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
      await kv.set(`slug:${script.slug}`, id);
    }
    if (description !== undefined) script.description = description;
    if (code) script.code = code;
    await kv.set(`script:${id}`, script);
    return res.json({ success: true });
  }

  if (req.method === 'DELETE') {
    await kv.del(`script:${id}`);
    await kv.del(`slug:${script.slug}`);
    return res.json({ success: true });
  }

  res.status(405).end();
}
