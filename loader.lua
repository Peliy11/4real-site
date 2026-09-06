local Players = game:GetService("Players")

local keySuccess, keyErr = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Peliy11/4realium/refs/heads/main/key.lua"))()
end)

if not keySuccess then
    warn("Key system failed to load: " .. tostring(keyErr))
    Players.LocalPlayer:Kick("4realium | Key system failed to load")
    return
end

task.wait(1)

if not getgenv().SCRIPT_KEY then
    Players.LocalPlayer:Kick("4realium | Invalid key")
    return
end

local scripts = {
    [155615604] = "https://raw.githubusercontent.com/Peliy11/4realium/refs/heads/main/155615604.lua",
}

local scriptUrl = scripts[game.PlaceId]
if not scriptUrl then
    Players.LocalPlayer:Kick("4realium | Unsupported game: " .. tostring(game.PlaceId))
    return
end

local scriptSuccess, scriptErr = pcall(function()
    loadstring(game:HttpGet(scriptUrl))()
end)

if not scriptSuccess then
    warn("Script failed to load: " .. tostring(scriptErr))
    Players.LocalPlayer:Kick("4realium | Script failed to load")
end
