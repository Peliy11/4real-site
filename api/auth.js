export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method === 'POST') {
    const auth = req.headers.authorization || '';
    const expected = 'Basic ' + btoa('1mN0tPg3d!');
    if (auth === expected) {
      return res.json({ success: true });
    }
    return res.status(401).json({ error: 'Unauthorized' });
  }

  res.status(405).end();
}
