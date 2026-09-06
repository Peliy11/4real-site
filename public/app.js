const API = '/api/scripts';

async function loadScripts() {
  const grid = document.getElementById('scripts-grid');
  if (!grid) return;

  try {
    const res = await fetch(API);
    const scripts = await res.json();

    let totalLoads = 0;
    scripts.forEach(s => totalLoads += (s.loadCount || 0));

    const statScripts = document.getElementById('stat-scripts');
    const statLoads = document.getElementById('stat-loads');
    if (statScripts) statScripts.textContent = scripts.length;
    if (statLoads) statLoads.textContent = totalLoads.toLocaleString();

    if (scripts.length === 0) {
      grid.innerHTML = '<div class="empty-state"><p>No scripts available yet.</p></div>';
      return;
    }

    grid.innerHTML = scripts.map(s => `
      <div class="script-card">
        <div class="script-card-top">
          <h3>${escapeHtml(s.name)}</h3>
          <span class="script-badge">${(s.loadCount || 0).toLocaleString()} loads</span>
        </div>
        <p>${escapeHtml(s.description || 'No description')}</p>
        ${s.gameId ? `<p style="font-size:12px;color:var(--text-dim);margin-top:-8px">Game ID: ${escapeHtml(s.gameId)}</p>` : ''}
        <div class="script-card-bottom">
          <span class="script-date">${timeAgo(s.created)}</span>
          <button class="script-btn">Copy Loadstring</button>
        </div>
      </div>
    `).join('');
  } catch (e) {
    grid.innerHTML = '<div class="empty-state"><p>Failed to load scripts.</p></div>';
  }
}

function copyLoadstring() {
  navigator.clipboard.writeText('loadstring(game:HttpGet("https://4realium.xyz/script"))()').then(() => showToast('Loadstring copied!'));
}

function copyLoadstringBottom() {
  navigator.clipboard.writeText('loadstring(game:HttpGet("https://4realium.xyz/script"))()').then(() => showToast('Loadstring copied!'));
}

function showToast(msg) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2500);
}

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

function timeAgo(dateStr) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 30) return `${days}d ago`;
  return new Date(dateStr).toLocaleDateString();
}

document.addEventListener('DOMContentLoaded', loadScripts);
