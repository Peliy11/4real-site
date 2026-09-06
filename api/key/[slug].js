import supabase from '../_lib.js';

function isRoblox(req) {
  const ua = (req.headers['user-agent'] || '').toLowerCase();
  return ua.includes('roblox');
}

const BLOCKED = `<!DOCTYPE html>
<html><head><title>Access Denied</title><style>
body{background:#09090B;color:#fff;font-family:system-ui;display:flex;align-items:center;justify-content:center;height:100vh;margin:0}
.box{text-align:center;max-width:500px;padding:40px}
h1{font-size:28px;margin-bottom:12px}
p{color:#a1a1aa;font-size:16px;line-height:1.6}
.icon{font-size:48px;margin-bottom:16px}
</style></head><body>
<div class="box">
<div class="icon">&#128683;</div>
<h1>Access Denied</h1>
<p>This link cannot be accessed from a browser. It can only be used through a loadstring in a Roblox executor.</p>
</div></body></html>`;

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  if (!isRoblox(req)) {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.status(403).send(BLOCKED);
  }

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
