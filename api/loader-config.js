import supabase from './_lib.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  const { data, error } = await supabase
    .from('scripts')
    .select('slug, game_id')
    .not('game_id', 'eq', '');

  if (error) return res.status(500).json({ error: error.message });

  const games = {};
  (data || []).forEach(s => {
    const ids = s.game_id.split(',').map(id => id.trim()).filter(Boolean);
    ids.forEach(id => { games[id] = s.slug; });
  });

  res.setHeader('Cache-Control', 'public, max-age=300');
  return res.json(games);
}
