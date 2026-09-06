import supabase from './_lib.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method === 'GET') {
    const { data, error } = await supabase
      .from('scripts')
      .select('id, name, slug, description, created, load_count, game_id, key_code')
      .order('created', { ascending: false });

    if (error) return res.status(500).json({ error: error.message });

    const scripts = (data || []).map(s => ({
      id: s.id,
      name: s.name,
      slug: s.slug,
      description: s.description,
      created: s.created,
      loadCount: s.load_count || 0,
      gameId: s.game_id || '',
      keyCode: s.key_code || ''
    }));

    return res.json(scripts);
  }

  if (req.method === 'POST') {
    if (!checkAuth(req)) return res.status(401).json({ error: 'Unauthorized' });

    const { name, description, code, gameId, keyCode } = req.body;
    if (!name || !code) return res.status(400).json({ error: 'Name and code required' });

    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

    const { data: existing } = await supabase
      .from('scripts')
      .select('id')
      .eq('slug', slug)
      .single();

    if (existing) return res.status(409).json({ error: 'Script name already exists' });

    const { data, error } = await supabase
      .from('scripts')
      .insert({ name, slug, description: description || '', code, key_code: keyCode || '', game_id: gameId || '', load_count: 0 })
      .select('id, slug, name')
      .single();

    if (error) return res.status(500).json({ error: error.message });
    return res.json(data);
  }

  res.status(405).end();
}

function checkAuth(req) {
  const auth = req.headers.authorization || '';
  const expected = 'Basic ' + btoa(process.env.ADMIN_PASSWORD || '');
  return auth === expected;
}
