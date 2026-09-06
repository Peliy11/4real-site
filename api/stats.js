import supabase from './_lib.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  const { count: totalScripts } = await supabase
    .from('scripts')
    .select('*', { count: 'exact', head: true });

  const { data } = await supabase
    .from('scripts')
    .select('load_count');

  let totalLoads = 0;
  if (data) data.forEach(s => totalLoads += (s.load_count || 0));

  res.setHeader('Cache-Control', 'public, max-age=60');
  return res.json({ totalScripts: totalScripts || 0, totalLoads });
}
