import supabase from '../_lib.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  const { slug } = req.query;

  const { data: script, error } = await supabase
    .from('scripts')
    .select('*')
    .eq('slug', slug)
    .single();

  if (error || !script) {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(404).send('-- Script not found');
  }

  await supabase
    .from('scripts')
    .update({ load_count: (script.load_count || 0) + 1 })
    .eq('id', script.id);

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Cache-Control', 'public, max-age=300');
  const output = script.key_code ? script.key_code + '\n\n' + script.code : script.code;
  return res.send(output);
}
