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

if gameScript.key then
    local keyCode = game:HttpGet(gameScript.key)
    if not keyCode or keyCode == "" then
        kick("Key system script is empty or failed to fetch")
        return
    end

    local keyLoadSuccess, keyLoadErr = pcall(function()
        loadstring(keyCode)()
    end)
    if not keyLoadSuccess then
        kick("Key system load error: " .. tostring(keyLoadErr))
        return
    end

    task.wait(2)

    if not getgenv().SCRIPT_KEY then
        local keyGui = Instance.new("ScreenGui")
        keyGui.Name = "4realium_Key"
        keyGui.ResetOnSpawn = false
        keyGui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 200)
        frame.Position = UDim2.new(0.5, -175, 0.5, -100)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Parent = keyGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundTransparency = 1
        title.Text = "4realium Key System"
        title.TextColor3 = Color3.fromRGB(233, 30, 140)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.Parent = frame

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.8, 0, 0, 36)
        input.Position = UDim2.new(0.1, 0, 0, 55)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        input.BorderSizePixel = 0
        input.PlaceholderText = "Paste your key here..."
        input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        input.TextColor3 = Color3.new(1, 1, 1)
        input.TextSize = 14
        input.Font = Enum.Font.Gotham
        input.ClearTextOnFocus = false
        input.Parent = frame

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 8)
        inputCorner.Parent = input

        local submitBtn = Instance.new("TextButton")
        submitBtn.Size = UDim2.new(0.8, 0, 0, 36)
        submitBtn.Position = UDim2.new(0.1, 0, 0, 100)
        submitBtn.BackgroundColor3 = Color3.fromRGB(233, 30, 140)
        submitBtn.Text = "Submit Key"
        submitBtn.TextColor3 = Color3.new(1, 1, 1)
        submitBtn.TextSize = 14
        submitBtn.Font = Enum.Font.GothamBold
        submitBtn.Parent = frame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = submitBtn

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 24)
        status.Position = UDim2.new(0, 0, 0, 145)
        status.BackgroundTransparency = 1
        status.Text = "Get key from our Discord"
        status.TextColor3 = Color3.fromRGB(120, 120, 120)
        status.TextSize = 12
        status.Font = Enum.Font.Gotham
        status.Parent = frame

        local keyVerified = false

        submitBtn.MouseButton1Click:Connect(function()
            local keyValue = input.Text
            if keyValue and #keyValue > 4 then
                getgenv().SCRIPT_KEY = keyValue
                keyVerified = true
                keyGui:Destroy()
            else
                status.Text = "Invalid key - try again"
                status.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end)

        local waited = 0
        while not keyVerified and waited < 300 do
            task.wait(1)
            waited = waited + 1
        end

        if not keyVerified then
            kick("Key timeout - no key entered")
            return
        end
    end
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
