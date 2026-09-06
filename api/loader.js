export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end();

  const host = req.headers.host || '4realium.xyz';
  const protocol = req.headers['x-forwarded-proto'] || 'https';
  const baseUrl = `${protocol}://${host}`;

  const lua = `-- 4realium Loader
-- Auto-detects game and runs the correct script

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local configUrl = "${baseUrl}/api/loader-config"
local fallbackScript = "${baseUrl}/script/main"

local function kick(msg)
    Players.LocalPlayer:Kick("4realium | " .. msg)
end

local success, config = pcall(function()
    return game:HttpGet(configUrl)
end)

if not success or not config then
    kick("Failed to load config")
    return
end

local ok, mappings = pcall(function()
    return HttpService:JSONDecode(config)
end)

if not ok or not mappings then
    kick("Failed to parse config")
    return
end

local placeId = tostring(game.PlaceId)
local scriptSlug = mappings[placeId]

if not scriptSlug then
    kick("Unsupported game: " .. placeId)
    return
end

local scriptUrl = "${baseUrl}/script/" .. scriptSlug
local scriptSuccess, scriptErr = pcall(function()
    loadstring(game:HttpGet(scriptUrl))()
end)

if not scriptSuccess then
    warn("Script failed to load: " .. tostring(scriptErr))
    kick("Script failed to load")
end`;

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Cache-Control', 'public, max-age=60');
  return res.send(lua);
}
