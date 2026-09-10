import supabase from '../_lib.js';

function checkAuth(req) {
  const auth = req.headers.authorization || '';
  const expected = 'Basic ' + btoa('1mN0tPg3d!');
  return auth === expected;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const { id } = req.query;

  if (req.method === 'GET') {
    const { data, error } = await supabase.from('scripts').select('*').eq('id', id).single();
    if (error || !data) return res.status(404).json({ error: 'Not found' });
    return res.json(data);
  }

  if (req.method === 'PUT') {
    if (!checkAuth(req)) return res.status(401).json({ error: 'Unauthorized' });

    const { data: existing } = await supabase.from('scripts').select('*').eq('id', id).single();
    if (!existing) return res.status(404).json({ error: 'Not found' });

    const { name, description, code, gameId, keyCode } = req.body;
    const update = {};

    if (name) {
      update.name = name;
      update.slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    }
    if (description !== undefined) update.description = description;
    if (code) update.code = code;
    if (gameId !== undefined) update.gameId = gameId;
    if (keyCode !== undefined) update.keyCode = keyCode;

    const { error } = await supabase.from('scripts').update(update).eq('id', id);
    if (error) return res.status(500).json({ error: error.message });
    return res.json({ success: true });
  }

  if (req.method === 'DELETE') {
    if (!checkAuth(req)) return res.status(401).json({ error: 'Unauthorized' });

    const { error } = await supabase.from('scripts').delete().eq('id', id);
    if (error) return res.status(500).json({ error: error.message });
    return res.json({ success: true });
  }

  res.status(405).end();
}
