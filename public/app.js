const API = '/api/scripts';

async function loadScripts() {
  const grid = document.getElementById('scripts-grid');
  if (!grid) return;

  try {
    const res = await fetch(API);
    const scripts = await res.json();

    if (scripts.length === 0) {
      grid.innerHTML = `
        <div class="empty-state">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/>
          </svg>
          <p>No scripts yet. <a href="admin.html">Upload one!</a></p>
        </div>`;
      return;
    }

    grid.innerHTML = scripts.map(s => `
      <div class="script-card" onclick="selectScript('${s.slug}')">
        <div class="script-card-header">
          <h3>${escapeHtml(s.name)}</h3>
          <span class="load-badge">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            ${(s.loadCount || 0).toLocaleString()} loads
          </span>
        </div>
        <p>${escapeHtml(s.description || 'No description')}</p>
        <div class="script-card-footer">
          <span class="script-date">${timeAgo(s.created)}</span>
          <div class="script-actions">
            <button class="btn-sm btn-copy-loadstring" onclick="event.stopPropagation(); copyScriptLoadstring('${s.slug}')">Copy Loadstring</button>
            <button class="btn-sm btn-load" onclick="event.stopPropagation(); copyScriptLoadstring('${s.slug}')">Load</button>
          </div>
        </div>
      </div>
    `).join('');

    if (scripts.length > 0) {
      document.getElementById('example-slug').textContent = scripts[0].slug;
    }
  } catch (e) {
    grid.innerHTML = '<div class="loading-state"><p>Failed to load scripts</p></div>';
  }
}

function selectScript(slug) {
  copyScriptLoadstring(slug);
}

function copyScriptLoadstring(slug) {
  const text = `loadstring(game:HttpGet("4realium.xyz/script/${slug}"))()`;
  navigator.clipboard.writeText(text).then(() => showToast('Loadstring copied!'));
}

function copyLoadstring() {
  const slug = document.getElementById('example-slug').textContent;
  const text = `loadstring(game:HttpGet("4realium.xyz/script/${slug}"))()`;
  navigator.clipboard.writeText(text).then(() => showToast('Loadstring copied!'));
}

function showToast(msg) {
  const toast = document.getElementById('toast');
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
