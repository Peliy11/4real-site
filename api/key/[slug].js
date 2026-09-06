import supabase from '../_lib.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  const { slug } = req.query;

  const { data: script, error } = await supabase
    .from('scripts')
    .select('key_code')
    .eq('slug', slug)
    .single();

  if (error || !script || !script.key_code) {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(404).send('-- Key system not found');
  }

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Cache-Control', 'public, max-age=300');
  return res.send(script.key_code);
}
