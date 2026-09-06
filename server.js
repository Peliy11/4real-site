const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

const DATA_DIR = path.join(__dirname, 'data');
const SCRIPTS_FILE = path.join(DATA_DIR, 'scripts.json');

if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
if (!fs.existsSync(SCRIPTS_FILE)) fs.writeFileSync(SCRIPTS_FILE, '[]', 'utf8');

function loadScripts() {
  return JSON.parse(fs.readFileSync(SCRIPTS_FILE, 'utf8'));
}

function saveScripts(scripts) {
  fs.writeFileSync(SCRIPTS_FILE, JSON.stringify(scripts, null, 2), 'utf8');
}

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

app.get('/api/scripts', (req, res) => {
  const scripts = loadScripts();
  res.json(scripts.map(s => ({ id: s.id, name: s.name, description: s.description, created: s.created, loadCount: s.loadCount || 0 })));
});

app.post('/api/scripts', (req, res) => {
  const { name, description, code } = req.body;
  if (!name || !code) return res.status(400).json({ error: 'Name and code required' });

  const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  const scripts = loadScripts();

  const existing = scripts.find(s => s.slug === slug);
  if (existing) return res.status(409).json({ error: 'Script name already exists' });

  const script = {
    id: crypto.randomUUID(),
    name,
    slug,
    description: description || '',
    code,
    created: new Date().toISOString(),
    loadCount: 0
  };

  scripts.push(script);
  saveScripts(scripts);
  res.json({ id: script.id, slug: script.slug, name: script.name });
});

app.delete('/api/scripts/:id', (req, res) => {
  let scripts = loadScripts();
  scripts = scripts.filter(s => s.id !== req.params.id);
  saveScripts(scripts);
  res.json({ success: true });
});

app.put('/api/scripts/:id', (req, res) => {
  const { name, description, code } = req.body;
  const scripts = loadScripts();
  const script = scripts.find(s => s.id === req.params.id);
  if (!script) return res.status(404).json({ error: 'Not found' });

  if (name) {
    script.name = name;
    script.slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  }
  if (description !== undefined) script.description = description;
  if (code) script.code = code;

  saveScripts(scripts);
  res.json({ success: true });
});

app.get('/api/scripts/:slug/raw', (req, res) => {
  const scripts = loadScripts();
  const script = scripts.find(s => s.slug === req.params.slug);
  if (!script) return res.status(404).send('-- Script not found');

  script.loadCount = (script.loadCount || 0) + 1;
  saveScripts(scripts);

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.send(script.code);
});

app.get('/script/:slug', (req, res) => {
  const scripts = loadScripts();
  const script = scripts.find(s => s.slug === req.params.slug);
  if (!script) return res.status(404).send('-- Script not found');

  script.loadCount = (script.loadCount || 0) + 1;
  saveScripts(scripts);

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.send(script.code);
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`4realium running on port ${PORT}`);
});
