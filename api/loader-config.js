import supabase from './_lib.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  const host = req.headers.host || '4realium.xyz';
  const protocol = req.headers['x-forwarded-proto'] || 'https';
  const baseUrl = `${protocol}://${host}`;

  const { data, error } = await supabase
    .from('scripts')
    .select('slug, game_id, key_code')
    .not('game_id', 'eq', '');

  if (error) return res.status(500).json({ error: error.message });

  const games = {};
  (data || []).forEach(s => {
    const ids = s.game_id.split(',').map(id => id.trim()).filter(Boolean);
    const entry = {
      url: `${baseUrl}/api/script/${s.slug}`
    };
    if (s.key_code && s.key_code.trim()) {
      entry.key = `${baseUrl}/api/key/${s.slug}`;
    }
    ids.forEach(id => { games[id] = entry; });
  });

  res.setHeader('Cache-Control', 'public, max-age=300');
  return res.json(games);
}
