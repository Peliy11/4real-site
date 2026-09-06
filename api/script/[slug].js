import { kv } from '@vercel/kv';

export default async function handler(req, res) {
  const { slug } = req.query;
  const id = await kv.get(`slug:${slug}`);

  if (!id) {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(404).send('-- Script not found');
  }

  const script = await kv.get(`script:${id}`);
  if (!script) {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(404).send('-- Script not found');
  }

  script.loadCount = (script.loadCount || 0) + 1;
  await kv.set(`script:${id}`, script);

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Cache-Control', 'public, max-age=300');
  return res.send(script.code);
}
