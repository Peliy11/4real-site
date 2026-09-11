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

  const baseUrl = 'https://www.4realium.xyz';

  const lua = `-- 4realium | Auto Script Loader
-- Detects your game and runs the correct script

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local placeId = tostring(game.PlaceId)

local function kick(msg)
    Players.LocalPlayer:Kick("4realium | " .. tostring(msg))
end

local config = nil
local success, result = pcall(function()
    return HttpService:JSONDecode(game:HttpGet("${baseUrl}/api/loader-config"))
end)

if success then
    config = result
end

if not config then
    kick("Failed to load config from server")
    return
end

local gameScript = config[placeId]
if not gameScript then
    kick("Unsupported game: " .. placeId .. ". This game is not in 4realium.")
    return
end

local rawScript = game:HttpGet(gameScript.url)
if not rawScript or rawScript == "" then
    kick("Script is empty or failed to fetch from server")
    return
end

if rawScript:find("Access Denied") or rawScript:find("<!DOCTYPE") then
    kick("Script endpoint returned HTML instead of Lua code")
    return
end

if rawScript:find("-- Script not found") then
    kick("Script not found on server for this game")
    return
end

local scriptSuccess, scriptErr = pcall(function()
    loadstring(rawScript)()
end)

if not scriptSuccess then
    warn("[4realium] Script error: " .. tostring(scriptErr))
    kick("Script error: " .. tostring(scriptErr))
end`;

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Cache-Control', 'public, max-age=30');
  return res.send(lua);
}
