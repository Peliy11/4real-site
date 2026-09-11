-- 4realium | Original: Your Desire by Yuki | Obsidian port by Primesto.fx | Fixed & Expanded

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library     = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local CoreGui          = game:GetService("CoreGui")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local player   = Players.LocalPlayer
local Toggles  = Library.Toggles
local Options  = Library.Options

-- ESP Library
local ESPLibrary = nil
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
    end)
    if ok and lib then ESPLibrary = lib end
end

-- Unload
local UnloadHandlers = {}
local function RegisterUnload(fn)
    if type(fn) == "function" then table.insert(UnloadHandlers, fn) end
end
local function RunUnload()
    for _, fn in ipairs(UnloadHandlers) do pcall(fn) end
    Library:Unload()
end

-- Team Check
local teammateCache = {}
_G.RivalsCHT_TeamCheck = _G.RivalsCHT_TeamCheck or {}
do
    local teamApi = _G.RivalsCHT_TeamCheck
    teamApi.IsTeammate = function(pl)
        if not pl then return false end
        local entry = teammateCache[pl]
        if entry and entry.isTeam ~= nil then return entry.isTeam end
        local ok, isTeam = pcall(function()
            local lp = Players.LocalPlayer
            local localTeam = lp and lp:GetAttribute("TeamID")
            local teamId    = pl:GetAttribute("TeamID")
            if localTeam ~= nil and teamId ~= nil then
                local res = tostring(localTeam) == tostring(teamId)
                teammateCache[pl] = { isTeam = res }
                return res
            end
            if lp and lp.Team and pl.Team then
                local res = lp.Team == pl.Team
                teammateCache[pl] = { isTeam = res }
                return res
            end
            teammateCache[pl] = { isTeam = false }
            return false
        end)
        return ok and isTeam or false
    end
    teamApi.IsEnemy = function(pl)
        if not pl then return false end
        local ok, isTeam = pcall(teamApi.IsTeammate, pl)
        return ok and not isTeam or false
    end
    teamApi.Invalidate = function(pl)
        if pl then teammateCache[pl] = nil
        else for k in pairs(teammateCache) do teammateCache[k] = nil end end
    end
end

-- Weapon Defs
local WeaponDefs = {
    Assault_Rifle    = {"AKEY-47","AUG","Gingerbread AUG","Tommy Gun","AK-47","Boneclaw Rifle","Glorious Assault Rifle","Phoenix Rifle","10B Visits"},
    Shotgun          = {"Balloon Shotgun","Hyper Shotgun","Cactus Shotgun","Shotkey","Broomstick","Wrapped Shotgun","Glorious Shotgun"},
    Minigun          = {"Lasergun 3000","Pixel Minigun","Fighter Jet","Pumpkin Minigun","Wrapped Minigun"},
    RPG              = {"Nuke Launcher","Spaceship Launcher","Squid Launcher","Pencil Launcher"},
    Paintball_Gun    = {"Slime Gun","Boba Gun","Ketchup Gun"},
    Grenade_Launcher = {"Swashbuckler","Uranium Launcher","Gearnade Launcher"},
    Flamethrower     = {"Pixel Flamethrower","Lamethrower","Glitterthrower"},
    Bow              = {"Compound Bow","Raven Bow","Dream Bow","Key"},
    Crossbow         = {"Pixel Crossbow","Harpoon Crossbow","Violin Crossbow","Crossbone","Frostbite Crossbow"},
    Gunblade         = {"Hyper Gunblade","Crude Gunblade","Gunsaw","Elf's Gunblade","Boneblade","Glorious Gunblade"},
    Burst_Rifle      = {"Electro Burst","Aqua Burst","FAMAS","Spectral Burst","Pine Burst","Key Rifle"},
    Energy_Rifle     = {"Hacker Rifle","Hydro Rifle","Void Rifle","2025 Energy Rifle"},
    Distortion       = {"Plasma Distortion","Magma Distortion","Cyber Distortion"},
    Permafrost       = {"Ice Permafrost"},
    Subspace_Tripmine= {"Don't Press","Dev-In-The-Box","Spring","Trick Or Treat","DIY Tripmine","Glorious Subspace Tripmine"},
    Riot_Shield      = {"Door","Sled","Tombstone Shield","Energy Shield","Masterpiece","Glorious Riot Shield"},
    Knife            = {"Keyrambit","Keylisong","Karambit","Balisong","Candy Cane","Machete","Chancla","Glorious Knife","Armature Knife"},
    Spray            = {"Bottle Spray","Boneclaw Spray","Nail Gun","Lovely Spray","Pine Spray","Glorious Spray"},
}

-- Window
local Window = Library:CreateWindow({
    Title         = "4realium",
    Footer        = "Built By Peliy11",
    NotifySide    = "Right",
    ToggleKeybind = Enum.KeyCode.Insert,
    Animations    = { ToggleWindow = true, TabSwitch = true, Groupbox = true, Dropdown = true, KeyPicker = true },
})

do
    local rsConn
    rsConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if Toggles.RightShiftToggle and Toggles.RightShiftToggle.Value then
                Window:Toggle()
            end
        end
    end)
    RegisterUnload(function() if rsConn then rsConn:Disconnect() end end)
end

local Tabs = {
    Home     = Window:AddTab("Home",     "home"),
    Main     = Window:AddTab("Main",     "crosshair"),
    Visual   = Window:AddTab("Visual",   "eye"),
    Movement = Window:AddTab("Movement", "zap"),
    Spoof    = Window:AddTab("Spoof",    "shield"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- Groupboxes
local HomeInfo   = Tabs.Home:AddGroupbox({ Side = "Left",  Name = "Welcome" })
local HomeGame   = Tabs.Home:AddGroupbox({ Side = "Right", Name = "Game Info" })

local CombatMain = Tabs.Main:AddGroupbox({ Side = "Left",  Name = "Combat" })
local CombatCfg  = Tabs.Main:AddGroupbox({ Side = "Right", Name = "Config" })
local SilentGB   = Tabs.Main:AddGroupbox({ Side = "Left",  Name = "Silent Aim" })
local HitboxGB   = Tabs.Main:AddGroupbox({ Side = "Right", Name = "Hitbox" })

local EspGB      = Tabs.Visual:AddGroupbox({ Side = "Left",  Name = "ESP" })
local WorldGB    = Tabs.Visual:AddGroupbox({ Side = "Right", Name = "World" })
local ChamsGB    = Tabs.Visual:AddGroupbox({ Side = "Left",  Name = "Chams" })

local MoveGB     = Tabs.Movement:AddGroupbox({ Side = "Left",  Name = "Movement" })
local FlyGB      = Tabs.Movement:AddGroupbox({ Side = "Right", Name = "Fly" })
local JumpGB     = Tabs.Movement:AddGroupbox({ Side = "Left",  Name = "Jump" })
local PhysicsGB  = Tabs.Movement:AddGroupbox({ Side = "Right", Name = "Physics" })

local UnlockGB   = Tabs.Spoof:AddGroupbox({ Side = "Left",  Name = "Unlock All" })
local SpoofInfo  = Tabs.Spoof:AddGroupbox({ Side = "Right", Name = "Info" })

local SettLeft   = Tabs.Settings:AddGroupbox({ Side = "Left",  Name = "General" })
local SettRight  = Tabs.Settings:AddGroupbox({ Side = "Right", Name = "Developer" })
local SettUI     = Tabs.Settings:AddGroupbox({ Side = "Left",  Name = "UI Settings" })

local DiscordInvite = "https://discord.gg/nRrhFFnM5"
local function CopyDiscordInvite()
    if setclipboard then
        setclipboard(DiscordInvite)
        Notify("Discord invite copied to clipboard.")
    else
        Notify("Clipboard is unavailable on this executor.")
    end
end

local function OpenDiscordInvite()
    local opened = false
    pcall(function()
        if syn and syn.request then
            syn.request({ Url = DiscordInvite, Method = "GET" })
            opened = true
        end
    end)

    if opened then
        Notify("Opening Discord invite...")
        return
    end

    if setclipboard then
        setclipboard(DiscordInvite)
        Notify("Discord invite copied. Open it from your app/browser.")
    else
        Notify("Unable to open Discord invite on this executor.")
    end
end

-- Home Tab
HomeInfo:AddLabel("Welcome to 4realium")
HomeInfo:AddDivider()
HomeInfo:AddLabel("Discord: " .. DiscordInvite)
HomeInfo:AddButton("Copy Discord Invite", function()
    CopyDiscordInvite()
end)
HomeInfo:AddButton("Open Discord", function()
    OpenDiscordInvite()
end)
HomeInfo:AddLabel("UI: Obsidian  |  ESP: mstudio45")

HomeGame:AddLabel("Game: " .. tostring(game.Name))
HomeGame:AddLabel("Place ID: " .. tostring(game.PlaceId))
HomeGame:AddLabel("Players: " .. tostring(#Players:GetPlayers()) .. " / " .. (pcall(function() return game.MaxPlayers end) and tostring(game.MaxPlayers) or "?"))
HomeGame:AddDivider()
HomeGame:AddLabel("Press Insert or Right Shift to toggle UI")

-- Main Tab - Combat
CombatMain:AddToggle("Aimbot", { Text = "Aimbot", Default = false })
    :AddKeyPicker("AimbotKey", { Text = "Aimbot Key", Default = "V", Mode = "Toggle", SyncToggleState = true })
CombatMain:AddToggle("AimLockLabel", { Text = "Aim Lock", Default = false })
    :AddKeyPicker("AimLockKey", { Text = "Aim Lock", Default = "Q", Mode = "Hold" })
CombatMain:AddToggle("PersistentAimbot",   { Text = "Persistent Aimbot", Default = false })
CombatMain:AddToggle("UseAimbotSmoothing", { Text = "Smoothing",         Default = false })
CombatMain:AddSlider("AimbotSmoothing",    { Text = "Smooth Amount",     Default = 5, Min = 1, Max = 100, Rounding = 0 })
CombatMain:AddToggle("AimPrediction",      { Text = "Prediction",        Default = true })
CombatMain:AddSlider("PredictionStrength", { Text = "Prediction Strength", Default = 50, Min = 0, Max = 100, Rounding = 0 })
CombatMain:AddToggle("TargetBehindWalls",  { Text = "Through Walls",     Default = false })
CombatMain:AddDropdown("AimPart", { Text = "Aim Part", Values = {"Head","HumanoidRootPart","Torso","UpperTorso"}, Default = "Head" })

-- Main Tab - Config
CombatCfg:AddSlider("AimbotFOV",   { Text = "FOV Size",       Default = 150, Min = 1, Max = 800, Rounding = 0 })
CombatCfg:AddToggle("DrawFovCircle",{ Text = "Show FOV Circle",Default = true })
CombatCfg:AddToggle("TeamCheck",   { Text = "Team Check",     Default = true })
CombatCfg:AddToggle("AutoShoot",   { Text = "Auto-Shoot",     Default = false })
    :AddKeyPicker("AutoShootKey",  { Text = "Auto-Shoot Key", Default = "Y", Mode = "Toggle", SyncToggleState = false })
CombatCfg:AddToggle("SixthSense",  { Text = "Sixth Sense",    Default = false })
CombatCfg:AddToggle("TriggerBot",  { Text = "Trigger Bot",    Default = false })
    :AddKeyPicker("TriggerBotKey", { Text = "Trigger Bot Key", Default = "T", Mode = "Hold" })
CombatCfg:AddSlider("TriggerDelay",{ Text = "Trigger Delay (ms)", Default = 50, Min = 0, Max = 500, Rounding = 0 })

-- Silent Aim
SilentGB:AddToggle("SilentAim", { Text = "Silent Aim", Default = false })
SilentGB:AddLabel("Redirects bullets to nearest target")
SilentGB:AddLabel("without moving your camera.")
SilentGB:AddToggle("SilentTeamCheck", { Text = "Silent Team Check", Default = true })

-- Hitbox Expander
HitboxGB:AddToggle("HitboxExpander", { Text = "Hitbox Expander", Default = false })
HitboxGB:AddSlider("HitboxSize", { Text = "Hitbox Size", Default = 5, Min = 1, Max = 30, Rounding = 1 })
HitboxGB:AddLabel("Expands enemy hitboxes client-side.")

-- Visual Tab - ESP
EspGB:AddToggle("EspEnabled",  { Text = "Enable ESP",        Default = false })
EspGB:AddToggle("EspBoxes2D",  { Text = "2D Box",            Default = true })
EspGB:AddToggle("EspTracer",   { Text = "Tracer",            Default = true })
EspGB:AddToggle("EspSkeleton", { Text = "Skeleton",          Default = false })
EspGB:AddToggle("EspHighlight",{ Text = "Highlight",         Default = false })
EspGB:AddToggle("EspArrow",    { Text = "Off-screen Arrow",  Default = false })
EspGB:AddSlider("EspMaxDist",  { Text = "Max Distance",      Default = 1000, Min = 100, Max = 5000, Rounding = 0 })
EspGB:AddToggle("EspColorLabel",{ Text = "ESP Color",        Default = false })
    :AddColorPicker("EspColor", { Default = Color3.fromRGB(255, 80, 80), Title = "ESP Color" })

-- Visual Tab - World
WorldGB:AddToggle("ShowEnemyWeapons", { Text = "Show Enemy Weapons", Default = false })
WorldGB:AddToggle("HideSmoke",        { Text = "Hide Smoke",         Default = false })
WorldGB:AddToggle("HideFlashbang",    { Text = "Hide Flashbang",     Default = false })

-- Visual Tab - Chams
ChamsGB:AddToggle("PlayerChams", { Text = "Player Chams", Default = false })
ChamsGB:AddToggle("ChamsColorToggle_Label", { Text = "Chams Color", Default = false })
    :AddColorPicker("PlayerChamsColor", { Default = Color3.fromRGB(200, 80, 180), Title = "Chams Color" })

-- Movement Tab
MoveGB:AddToggle("SpeedEnabled", { Text = "Speed Hack", Default = false })
    :AddKeyPicker("SpeedKey", { Text = "Speed Key", Default = "None", Mode = "Toggle" })
MoveGB:AddSlider("WalkSpeed", { Text = "Walk Speed", Default = 32, Min = 16, Max = 300, Rounding = 0 })
MoveGB:AddToggle("NoClip",    { Text = "No Clip",    Default = false })
    :AddKeyPicker("NoClipKey", { Text = "NoClip Key", Default = "N", Mode = "Toggle" })
MoveGB:AddToggle("LowGravity",{ Text = "Low Gravity",Default = false })
MoveGB:AddSlider("GravityStrength", { Text = "Gravity", Default = 50, Min = 5, Max = 196, Rounding = 0 })

FlyGB:AddToggle("FlyEnabled", { Text = "Fly", Default = false })
    :AddKeyPicker("FlyKey",   { Text = "Fly Key", Default = "F", Mode = "Toggle" })
FlyGB:AddSlider("FlySpeed",   { Text = "Fly Speed", Default = 50, Min = 5, Max = 300, Rounding = 0 })
FlyGB:AddLabel("WASD + Space/Shift to move while flying")

JumpGB:AddToggle("InfiniteJump", { Text = "Infinite Jump",  Default = false })
JumpGB:AddSlider("JumpPower",    { Text = "Jump Power",     Default = 50, Min = 10, Max = 300, Rounding = 0 })
JumpGB:AddToggle("AutoJump",     { Text = "Auto Jump",      Default = false })

PhysicsGB:AddToggle("SuperJump", { Text = "Super Jump",    Default = false })
PhysicsGB:AddSlider("SuperJumpPower", { Text = "Super Jump Power", Default = 100, Min = 50, Max = 500, Rounding = 0 })

-- Spoof Tab
UnlockGB:AddToggle("UnlockSkins",  { Text = "Unlock Skins",  Default = false })
UnlockGB:AddToggle("UnlockWraps",  { Text = "Unlock Wraps",  Default = false })
UnlockGB:AddToggle("UnlockCharms", { Text = "Unlock Charms", Default = false })
UnlockGB:AddToggle("UnlockEmotes", { Text = "Unlock Emotes", Default = false })
UnlockGB:AddDivider()
UnlockGB:AddLabel("Toggle above, then click cosmetic to equip.")

SpoofInfo:AddLabel("How it works:")
SpoofInfo:AddLabel("Cosmetics are unlocked client-side.")
SpoofInfo:AddLabel("Click any skin/wrap in the menu to equip.")
SpoofInfo:AddLabel("Only YOU see the change.")
SpoofInfo:AddDivider()
SpoofInfo:AddLabel("Server-side: NOT bypassed.")

-- Settings
SettLeft:AddToggle("ShowGuiOnLoad",       { Text = "Show GUI On Load",     Default = true })
SettLeft:AddToggle("EnableNotifications", { Text = "Enable Notifications", Default = true })
SettRight:AddToggle("DebugMode", { Text = "Generic Debug",   Default = false })
SettRight:AddToggle("ShowFps",   { Text = "Show FPS Counter",Default = false })
SettUI:AddToggle("RightShiftToggle", { Text = "Right Shift to Close", Default = true })

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("4realium/rivals")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("4realium")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- Notify helper
local function Notify(text, dur)
    if not Toggles.EnableNotifications.Value then return end
    Library:Notify(tostring(text), dur or 3)
end

-- ============================================================
-- ESP
-- ============================================================
do
    local espInstances = {}
    local espEnabled   = false

    local function getEspColor()
        local c = Options.EspColor and Options.EspColor.Value
        return (typeof(c) == "Color3") and c or Color3.fromRGB(255, 80, 80)
    end

    local function getComponents()
        return {
            Box2D     = Toggles.EspBoxes2D     and Toggles.EspBoxes2D.Value,
            Tracer    = Toggles.EspTracer      and Toggles.EspTracer.Value,
            Skeleton  = Toggles.EspSkeleton    and Toggles.EspSkeleton.Value,
            Highlight = Toggles.EspHighlight   and Toggles.EspHighlight.Value,
            Arrow     = Toggles.EspArrow       and Toggles.EspArrow.Value,
        }
    end

    local function createEsp(p)
        if p == player then return end
        if espInstances[p] then pcall(function() espInstances[p]:Destroy() end) espInstances[p] = nil end
        local function onChar(character)
            character:WaitForChild("HumanoidRootPart", 10)
            if not character:FindFirstChild("HumanoidRootPart") then return end
            if espInstances[p] then pcall(function() espInstances[p]:Destroy() end) espInstances[p] = nil end
            if not ESPLibrary then return end
            local comp = getComponents()
            local col  = getEspColor()
            local ok, inst = pcall(function()
                return ESPLibrary:Add({
                    Name              = p.Name,
                    Model             = character,
                    Color             = col,
                    MaxDistance       = Options.EspMaxDist and Options.EspMaxDist.Value or 1000,
                    TextSize          = 14,
                    ESPType           = "Highlight",
                    FillColor         = col,
                    OutlineColor      = Color3.new(1,1,1),
                    FillTransparency  = 0.5,
                    OutlineTransparency = 0,
                    Box2D     = { Enabled = comp.Box2D,     Color = col, Thickness = 2 },
                    Tracer    = { Enabled = comp.Tracer,    Color = col, From = "Bottom" },
                    Skeleton  = { Enabled = comp.Skeleton,  Color = col, Thickness = 1 },
                    Arrow     = { Enabled = comp.Arrow,     Color = col },
                })
            end)
            if ok and inst then
                espInstances[p] = inst
                if not espEnabled then pcall(function() inst:Hide() end) end
            end
        end
        if p.Character then task.spawn(onChar, p.Character) end
        p.CharacterAdded:Connect(onChar)
    end

    local function removeEsp(p)
        if espInstances[p] then pcall(function() espInstances[p]:Destroy() end) espInstances[p] = nil end
    end

    local function enableEsp()
        espEnabled = true
        for _, p in ipairs(Players:GetPlayers()) do pcall(createEsp, p) end
        Players.PlayerAdded:Connect(function(p) pcall(createEsp, p) end)
        Players.PlayerRemoving:Connect(function(p) pcall(removeEsp, p) end)
    end

    local function disableEsp()
        espEnabled = false
        for p, inst in pairs(espInstances) do pcall(function() inst:Destroy() end) espInstances[p] = nil end
    end

    local function updateAll()
        if not ESPLibrary then return end
        local col     = getEspColor()
        local comp    = getComponents()
        local maxDist = Options.EspMaxDist and Options.EspMaxDist.Value or 1000
        for _, inst in pairs(espInstances) do
            if inst and not inst.Deleted then
                pcall(function()
                    inst:SetEveryColor(col, true)
                    inst.CurrentSettings.MaxDistance = maxDist
                    if inst.CurrentSettings.Box2D     then inst.CurrentSettings.Box2D.Enabled     = comp.Box2D     end
                    if inst.CurrentSettings.Tracer    then inst.CurrentSettings.Tracer.Enabled    = comp.Tracer    end
                    if inst.CurrentSettings.Skeleton  then inst.CurrentSettings.Skeleton.Enabled  = comp.Skeleton  end
                    if inst.CurrentSettings.Arrow     then inst.CurrentSettings.Arrow.Enabled     = comp.Arrow     end
                    if comp.Highlight then inst:Show() else inst:Hide() end
                end)
            end
        end
    end

    Toggles.EspEnabled:OnChanged(function(v) if v then enableEsp() else disableEsp() end end)
    Toggles.EspBoxes2D:OnChanged(updateAll)
    Toggles.EspTracer:OnChanged(updateAll)
    Toggles.EspSkeleton:OnChanged(updateAll)
    Toggles.EspHighlight:OnChanged(updateAll)
    Toggles.EspArrow:OnChanged(updateAll)
    Options.EspColor:OnChanged(updateAll)
    Options.EspMaxDist:OnChanged(updateAll)
    RegisterUnload(disableEsp)
end

-- ============================================================
-- Player Chams
-- ============================================================
do
    local chams, charConns = {}, {}
    local addedConn, removedConn

    local function getColor()
        local c = Options.PlayerChamsColor and Options.PlayerChamsColor.Value
        return (typeof(c) == "Color3") and c or Color3.fromRGB(200,80,180)
    end

    local function makeHighlight(char)
        if not char or not char:IsA("Model") then return nil end
        local h = Instance.new("Highlight")
        h.Name              = "4realium_PlayerChams"
        h.Adornee           = char
        h.FillColor         = getColor()
        h.OutlineColor      = Color3.fromRGB(18,16,25)
        h.Parent            = CoreGui
        return h
    end

    local function remove(p)
        if charConns[p] then charConns[p]:Disconnect() charConns[p] = nil end
        if chams[p]     then chams[p]:Destroy()        chams[p]     = nil end
    end

    local function add(p)
        if not p or p == player then return end
        remove(p)
        if p.Character then chams[p] = makeHighlight(p.Character) end
        charConns[p] = p.CharacterAdded:Connect(function(c)
            if chams[p] then chams[p]:Destroy() end
            chams[p] = makeHighlight(c)
        end)
    end

    local function enable()
        for _, p in ipairs(Players:GetPlayers()) do pcall(add, p) end
        addedConn   = Players.PlayerAdded:Connect(function(p)   pcall(add, p)    end)
        removedConn = Players.PlayerRemoving:Connect(function(p) pcall(remove, p) end)
    end

    local function disable()
        if addedConn   then addedConn:Disconnect()   addedConn   = nil end
        if removedConn then removedConn:Disconnect()  removedConn = nil end
        for p in pairs(charConns) do pcall(function() charConns[p]:Disconnect() end) charConns[p] = nil end
        for p in pairs(chams)     do pcall(function() chams[p]:Destroy() end)        chams[p]     = nil end
    end

    local function refreshColors()
        local col = getColor()
        for _, h in pairs(chams) do if h and h.Parent then h.FillColor = col end end
    end

    Toggles.PlayerChams:OnChanged(function(v) if v then enable() else disable() end end)
    Options.PlayerChamsColor:OnChanged(refreshColors)
    if Toggles.PlayerChams.Value then enable() end
    RegisterUnload(disable)
end

-- ============================================================
-- Show Enemy Weapons
-- ============================================================
do
    local labels    = {}
    local isEnabled = false
    local conn

    local function extractWeapon(name)
        local p = string.split(name, " - ")
        return p[3] or p[2] or name
    end
    local function extractPlayer(name)
        return (string.split(name," - "))[1] or "Unknown"
    end
    local function normalizeWeapon(raw)
        if not raw then return raw end
        local lname = raw:lower()
        for norm, list in pairs(WeaponDefs) do
            for _, alias in ipairs(list) do
                if alias:lower() == lname then return norm:gsub("_"," ") end
            end
        end
        return raw
    end

    local ViewModels = Workspace:FindFirstChild("ViewModels")

    local containerGui = Instance.new("ScreenGui")
    containerGui.Name          = "4realium_EnemyWeapons"
    containerGui.ResetOnSpawn  = false
    pcall(function() containerGui.Parent = CoreGui end)

    local container = Instance.new("Frame")
    container.Name                = "EWContainer"
    container.Size                = UDim2.new(0,200,0,0)
    container.AutomaticSize       = Enum.AutomaticSize.Y
    container.Position            = UDim2.new(1,-220,0,24)
    container.BackgroundTransparency = 1
    container.Visible             = false
    container.Parent              = containerGui
    Instance.new("UIListLayout", container).Padding = UDim.new(0,4)

    local function updateDisplay()
        if not isEnabled or not ViewModels then return end
        local active = {}
        for _, vm in ipairs(ViewModels:GetChildren()) do
            if vm:IsA("Model") then
                local pname = extractPlayer(vm.Name)
                if pname == player.Name then continue end
                local pl = Players:FindFirstChild(pname)
                if not pl then continue end
                local isTeam = _G.RivalsCHT_TeamCheck and _G.RivalsCHT_TeamCheck.IsTeammate and _G.RivalsCHT_TeamCheck.IsTeammate(pl) or false
                if isTeam then continue end
                local norm = normalizeWeapon(extractWeapon(vm.Name))
                active[pname] = norm
                if not labels[pname] then
                    local lbl = Instance.new("TextLabel")
                    lbl.Size                  = UDim2.new(1,0,0,24)
                    lbl.BackgroundTransparency= 1
                    lbl.Font                  = Enum.Font.GothamSemibold
                    lbl.TextSize              = 13
                    lbl.TextColor3            = Color3.new(1,1,1)
                    lbl.TextXAlignment        = Enum.TextXAlignment.Left
                    lbl.Visible               = false
                    lbl.Parent                = container
                    labels[pname]             = lbl
                end
                labels[pname].Text    = pname .. " | " .. norm
                labels[pname].Visible = true
            end
        end
        for pname, lbl in pairs(labels) do
            if not active[pname] then lbl.Visible = false end
        end
    end

    local function enable()
        if isEnabled then return end
        isEnabled = true; container.Visible = true
        conn = RunService.Heartbeat:Connect(updateDisplay)
    end
    local function disable()
        if not isEnabled then return end
        isEnabled = false; container.Visible = false
        if conn then conn:Disconnect(); conn = nil end
        for _, l in pairs(labels) do l.Visible = false end
    end

    local function GetEnemyHeldWeapon(pl)
        if not ViewModels then return nil end
        local name = type(pl)=="string" and pl or (pl and pl.Name)
        for _, vm in ipairs(ViewModels:GetChildren()) do
            if vm:IsA("Model") and extractPlayer(vm.Name) == name then
                return normalizeWeapon(extractWeapon(vm.Name)), extractWeapon(vm.Name), vm
            end
        end
        return nil
    end

    local function GetLocalPlayerHeldWeapon()
        if not ViewModels then return nil end
        local fp = ViewModels:FindFirstChild("FirstPerson")
        if not fp then return nil end
        for _, c in ipairs(fp:GetChildren()) do
            if c:IsA("Model") then
                local raw = extractWeapon(c.Name)
                return normalizeWeapon(raw), raw, c
            end
        end
        return nil
    end

    Toggles.ShowEnemyWeapons:OnChanged(function(v) if v then enable() else disable() end end)
    if Toggles.ShowEnemyWeapons.Value then enable() end

    _G.RivalsCHTUI                      = _G.RivalsCHTUI or {}
    _G.RivalsCHTUI.ShowEnemyWeapons     = { GetEnemyHeldWeapon = GetEnemyHeldWeapon, GetLocalPlayerHeldWeapon = GetLocalPlayerHeldWeapon }
    RegisterUnload(function() disable(); if containerGui then containerGui:Destroy() end end)
end

-- ============================================================
-- Hide Smoke
-- ============================================================
do
    local wsConn, running = nil, false
    local function handleSmoke(inst)
        if not inst or not inst.Parent then return end
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("ParticleEmitter") then d.Enabled = false
            elseif d:IsA("BasePart")    then d.Transparency = 1
            elseif d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
        end
        task.defer(function() if inst and inst.Parent then inst:Destroy() end end)
    end
    local function enable()
        if running then return end; running = true
        wsConn = Workspace.DescendantAdded:Connect(function(c)
            if running and c and c.Name == "Smoke Grenade" then handleSmoke(c) end
        end)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v and v.Name == "Smoke Grenade" then handleSmoke(v) end
        end
    end
    local function disable()
        running = false
        if wsConn then wsConn:Disconnect(); wsConn = nil end
    end
    Toggles.HideSmoke:OnChanged(function(v) if v then enable() else disable() end end)
    if Toggles.HideSmoke.Value then enable() end
    RegisterUnload(disable)
end

-- ============================================================
-- Hide Flashbang
-- ============================================================
do
    local wsConn, guiConn, enabled = nil, nil, false
    local lastShow = 0
    local function handle(inst)
        if not inst then return end
        pcall(function() inst:Destroy() end)
        local now = tick()
        if now - lastShow < 0.5 then return end
        lastShow = now
        Library:Notify("You are currently flashbanged!", 3)
    end
    local function enable()
        if wsConn then return end; enabled = true
        wsConn = Workspace.ChildAdded:Connect(function(c) if c and c.Name=="FlashbangEffect" then handle(c) end end)
        local pg = player and player:FindFirstChild("PlayerGui")
        if pg then guiConn = pg.ChildAdded:Connect(function(c) if c and c.Name:lower():find("flash") then handle(c) end end) end
    end
    local function disable()
        enabled = false
        if wsConn  then wsConn:Disconnect();  wsConn  = nil end
        if guiConn then guiConn:Disconnect(); guiConn = nil end
    end
    Toggles.HideFlashbang:OnChanged(function(v) if v then enable() else disable() end end)
    if Toggles.HideFlashbang.Value then enable() end
    RegisterUnload(disable)
end

-- ============================================================
-- Aimbot (Improved)
-- ============================================================
do
    local loopConn, fovCircle, fovDrawConn
    local leftDown    = false
    local aimAccumX, aimAccumY = 0, 0
    local _aimLastTime = nil
    local persistentTarget    = nil
    local targetBehindWallsEnabled = false

    local function enableFovCircle()
        if fovCircle then return end
        if not (typeof(Drawing) == "table" and Drawing.new) then return end
        fovCircle           = Drawing.new("Circle")
        fovCircle.Filled    = false
        fovCircle.Thickness = 1
        fovCircle.Color     = Color3.new(1,1,1)
        fovCircle.Visible   = true
        fovDrawConn = RunService.RenderStepped:Connect(function()
            if not fovCircle then return end
            local cam = Workspace.CurrentCamera; if not cam then return end
            local vs = cam.ViewportSize
            fovCircle.Position = Vector2.new(vs.X * 0.5, vs.Y * 0.5)
            fovCircle.Radius   = Options.AimbotFOV and Options.AimbotFOV.Value or 150
            fovCircle.Visible  = Toggles.DrawFovCircle.Value
        end)
    end

    local function disableFovCircle()
        if fovDrawConn then fovDrawConn:Disconnect(); fovDrawConn = nil end
        if fovCircle   then pcall(function() fovCircle:Remove() end); fovCircle = nil end
    end

    Toggles.DrawFovCircle:OnChanged(function(v)
        if v then enableFovCircle() elseif fovCircle then fovCircle.Visible = false end
    end)
    if Toggles.DrawFovCircle.Value then enableFovCircle() end

    Toggles.TargetBehindWalls:OnChanged(function(v) targetBehindWallsEnabled = v end)
    targetBehindWallsEnabled = Toggles.TargetBehindWalls.Value

    local function isAlive(ch)
        if not ch then return false end
        local h = ch:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end

    local function getAimPart(ch)
        if not ch then return nil end
        local part = Options.AimPart and Options.AimPart.Value or "Head"
        return ch:FindFirstChild(part) or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    end

    local function findTarget()
        local cam = Workspace.CurrentCamera; if not cam then return nil end
        local vs = cam.ViewportSize
        local cx, cy = vs.X * 0.5, vs.Y * 0.5
        local fov = Options.AimbotFOV and Options.AimbotFOV.Value or 150
        local teamCheck = Toggles.TeamCheck.Value
        local best, bestD = nil, math.huge

        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == player then continue end
            local ch = pl.Character; if not ch then continue end
            if not isAlive(ch) then continue end
            if teamCheck and _G.RivalsCHT_TeamCheck.IsTeammate(pl) then continue end
            local aimPart = getAimPart(ch); if not aimPart then continue end
            local s = cam:WorldToViewportPoint(aimPart.Position)
            if s.Z <= 0 then continue end
            if not targetBehindWallsEnabled then
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Blacklist
                rp.FilterDescendantsInstances = { ch }
                local dir = aimPart.Position - cam.CFrame.Position
                local ray = Workspace:Raycast(cam.CFrame.Position, dir, rp)
                if ray and ray.Instance and not ray.Instance:IsDescendantOf(ch) then continue end
            end
            local dx, dy = s.X - cx, s.Y - cy
            local d = math.sqrt(dx*dx + dy*dy)
            if d < bestD and d <= fov then bestD = d; best = aimPart end
        end
        return best, bestD
    end

    local function calcPrediction(aimPart, cam)
        if not Toggles.AimPrediction.Value then return aimPart.Position end
        local ch = aimPart.Parent
        local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso"))
        if not root or not root:IsA("BasePart") then return aimPart.Position end
        local strength = (Options.PredictionStrength and Options.PredictionStrength.Value or 50) / 100
        local vel  = root.Velocity
        local dist = (aimPart.Position - cam.CFrame.Position).Magnitude
        local tt   = dist / 900
        local dir  = (aimPart.Position - cam.CFrame.Position)
        local dirU = dir.Magnitude > 0 and dir / dir.Magnitude or Vector3.new(0,0,0)
        local lateral = vel - dirU * vel:Dot(dirU)
        local lf = tt < 0.04 and 0 or tt < 0.12 and (tt-0.04)/0.08 or 1
        return aimPart.Position + lateral * tt * lf * strength
    end

    local function startLoop()
        if loopConn then return end
        loopConn = RunService.RenderStepped:Connect(function()
            local forceActive = (_G.RivalsCHT_Aimbot and _G.RivalsCHT_Aimbot.ForceActive) or false
            if not leftDown and not forceActive then return end
            if not Toggles.Aimbot.Value and not forceActive then return end
            local cam = Workspace.CurrentCamera; if not cam then return end

            local aimPart = findTarget()
            local now     = tick()
            local persistent = Toggles.PersistentAimbot.Value

            if aimPart and persistent then
                persistentTarget = { model = aimPart.Parent, lastPos = aimPart.Position, t = now }
            elseif not aimPart and persistent and persistentTarget and persistentTarget.model and persistentTarget.model.Parent then
                local reac = getAimPart(persistentTarget.model)
                if reac then
                    aimPart = reac; persistentTarget.lastPos = reac.Position; persistentTarget.t = now
                elseif (now - (persistentTarget.t or 0)) <= 3 then
                    aimPart = { Position = persistentTarget.lastPos }
                else
                    persistentTarget = nil
                end
            end

            if not aimPart or not aimPart.Position then return end

            local dt = _aimLastTime and (now - _aimLastTime) or 0; _aimLastTime = now
            local predicted = calcPrediction(aimPart, cam)

            local vp = cam:WorldToViewportPoint(predicted); if vp.Z <= 0 then return end
            local mp = UserInputService:GetMouseLocation()
            local dx, dy = vp.X - mp.X, vp.Y - mp.Y

            if Toggles.UseAimbotSmoothing.Value then
                local sv  = math.max(1, Options.AimbotSmoothing and Options.AimbotSmoothing.Value or 5)
                local fps = dt > 0 and math.clamp(math.sqrt(60*dt), 0.9, 2) or 1
                aimAccumX = aimAccumX + dx/sv
                aimAccumY = aimAccumY + dy/sv
                local mx, my = 0, 0
                if math.abs(aimAccumX) >= 1 then mx = math.floor(aimAccumX); aimAccumX = aimAccumX - mx end
                if math.abs(aimAccumY) >= 1 then my = math.floor(aimAccumY); aimAccumY = aimAccumY - my end
                if mx ~= 0 or my ~= 0 then
                    mousemoverel(math.clamp(mx*fps,-150,150), math.clamp(my*fps,-150,150))
                end
            else
                mousemoverel(dx, dy)
            end
        end)
    end

    local function stopLoop()
        if loopConn then loopConn:Disconnect(); loopConn = nil end
    end

    local inputB = UserInputService.InputBegan:Connect(function(in_, gp)
        if gp then return end
        if in_.UserInputType == Enum.UserInputType.MouseButton1 then leftDown = true; startLoop() end
    end)
    local inputE = UserInputService.InputEnded:Connect(function(in_)
        if in_.UserInputType == Enum.UserInputType.MouseButton1 then leftDown = false; stopLoop() end
    end)

    Options.AimLockKey:OnClick(function()
        if _G.RivalsCHT_Aimbot then _G.RivalsCHT_Aimbot.ForceActive = true; startLoop() end
    end)
    Options.AimLockKey:OnChanged(function()
        if _G.RivalsCHT_Aimbot then
            local state = Options.AimLockKey:GetState()
            _G.RivalsCHT_Aimbot.ForceActive = not not state
            if not state then stopLoop() end
        end
    end)

    _G.RivalsCHT_Aimbot = {
        ForceActive = false,
        Start   = startLoop,
        Stop    = stopLoop,
        IsEnabled = function() return Toggles.Aimbot.Value end,
        IsAlive   = function(target)
            if typeof(target) == "Instance" and target:IsA("Model") then return isAlive(target) end
            return false
        end,
        GetPersistentTarget   = function() return persistentTarget end,
        ClearPersistentTarget = function() persistentTarget = nil end,
        SetPersistentTarget   = function(model)
            if not model then return end
            local head = model:FindFirstChild("Head") or (model.PrimaryPart)
            persistentTarget = { model = model, lastPos = head and head.Position, t = tick() }
        end,
        Trigger = function() _G.RivalsCHT_Aimbot.ForceActive = true;  startLoop() end,
        Release = function() _G.RivalsCHT_Aimbot.ForceActive = false; stopLoop() end,
    }

    _G.RivalsCHT_AimAssist = {
        IsHeadInFOV = function(target)
            local headPos, headInst = nil, nil
            if typeof(target) == "Instance" then
                if target:IsA("Model") then
                    headInst = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
                    if headInst then headPos = headInst.Position end
                elseif target:IsA("BasePart") then headInst = target; headPos = target.Position end
            end
            if not headPos then return false, nil, nil, headInst end
            local cam = Workspace.CurrentCamera; if not cam then return false, nil, nil, headInst end
            local vp = cam:WorldToViewportPoint(headPos)
            if not vp or vp.Z <= 0 then return false, nil, nil, headInst end
            local vs = cam.ViewportSize; local cx, cy = vs.X*0.5, vs.Y*0.5
            local dx, dy = vp.X-cx, vp.Y-cy
            local d   = math.sqrt(dx*dx+dy*dy)
            local fov = Options.AimbotFOV and Options.AimbotFOV.Value or 150
            return d <= fov, d, Vector2.new(vp.X, vp.Y), headInst
        end,
    }

    RegisterUnload(function()
        pcall(function() inputB:Disconnect() end)
        pcall(function() inputE:Disconnect() end)
        stopLoop(); disableFovCircle()
    end)
end

-- ============================================================
-- Silent Aim
-- ============================================================
do
    local saHook = nil

    local function findNearestForSilent()
        local cam = Workspace.CurrentCamera; if not cam then return nil end
        local vs = cam.ViewportSize
        local cx, cy = vs.X*0.5, vs.Y*0.5
        local fov  = Options.AimbotFOV and Options.AimbotFOV.Value or 150
        local best, bestD = nil, math.huge
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == player then continue end
            local ch = pl.Character; if not ch then continue end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if Toggles.SilentTeamCheck.Value and _G.RivalsCHT_TeamCheck.IsTeammate(pl) then continue end
            local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"); if not head then continue end
            local s = cam:WorldToViewportPoint(head.Position)
            if s.Z <= 0 then continue end
            local dx, dy = s.X-cx, s.Y-cy
            local d = math.sqrt(dx*dx+dy*dy)
            if d < bestD and d <= fov then bestD = d; best = head end
        end
        return best
    end

    local function enable()
        if saHook then return end
        pcall(function()
            saHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" then
                    if Toggles.SilentAim and Toggles.SilentAim.Value then
                        local target = findNearestForSilent()
                        if target then
                            return target, target.Position, Vector3.new(0,1,0), Enum.Material.SmoothPlastic
                        end
                    end
                end
                return saHook(self, ...)
            end))
        end)
    end

    local function disable()
        -- hookmetamethod can't be unhooked cleanly; just disable via toggle check
    end

    Toggles.SilentAim:OnChanged(function(v)
        if v then enable() else disable() end
    end)
    if Toggles.SilentAim.Value then enable() end
end

-- ============================================================
-- Hitbox Expander
-- ============================================================
do
    local hitboxConns   = {}
    local origSizes     = {}
    local addedConn, removedConn

    local function expandPlayer(p)
        if not p or p == player then return end
        local ch = p.Character
        if not ch then return end
        local head = ch:FindFirstChild("Head")
        if not head then return end
        if not origSizes[head] then origSizes[head] = head.Size end
        local sz = Options.HitboxSize and Options.HitboxSize.Value or 5
        head.Size = Vector3.new(sz, sz, sz)
    end

    local function restorePlayer(p)
        if not p or p == player then return end
        local ch = p.Character; if not ch then return end
        local head = ch:FindFirstChild("Head"); if not head then return end
        if origSizes[head] then head.Size = origSizes[head]; origSizes[head] = nil end
    end

    local function enable()
        for _, p in ipairs(Players:GetPlayers()) do pcall(expandPlayer, p) end
        addedConn   = Players.PlayerAdded:Connect(function(p)
            task.wait(2); pcall(expandPlayer, p)
        end)
        removedConn = Players.PlayerRemoving:Connect(function(p) pcall(restorePlayer, p) end)
    end

    local function disable()
        if addedConn   then addedConn:Disconnect();   addedConn   = nil end
        if removedConn then removedConn:Disconnect();  removedConn = nil end
        for _, p in ipairs(Players:GetPlayers()) do pcall(restorePlayer, p) end
    end

    Toggles.HitboxExpander:OnChanged(function(v) if v then enable() else disable() end end)
    Options.HitboxSize:OnChanged(function()
        if Toggles.HitboxExpander.Value then
            for _, p in ipairs(Players:GetPlayers()) do pcall(expandPlayer, p) end
        end
    end)
    RegisterUnload(disable)
end

-- ============================================================
-- Auto-Shoot
-- ============================================================
do
    local loopConn, firing = nil, false

    local function isInFOV(head)
        if not head then return false end
        local cam = Workspace.CurrentCamera; if not cam then return false end
        local vp = cam:WorldToViewportPoint(head.Position)
        if not vp or vp.Z <= 0 then return false end
        local vs = cam.ViewportSize; local cx, cy = vs.X*0.5, vs.Y*0.5
        local dx, dy = vp.X-cx, vp.Y-cy
        return math.sqrt(dx*dx+dy*dy) <= (Options.AimbotFOV and Options.AimbotFOV.Value or 150)
    end

    local function isVisible(head)
        if not head or not head.Parent then return false end
        local cam = Workspace.CurrentCamera; if not cam then return false end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = { head.Parent }
        local ray = Workspace:Raycast(cam.CFrame.Position, head.Position - cam.CFrame.Position, rp)
        return not (ray and ray.Instance and not ray.Instance:IsDescendantOf(head.Parent))
    end

    local function check()
        if not Toggles.AutoShoot.Value then
            if firing then mouse1release(); firing = false end
            return
        end
        local found = nil
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == player then continue end
            if Toggles.TeamCheck.Value and _G.RivalsCHT_TeamCheck.IsTeammate(pl) then continue end
            local ch = pl.Character; if not ch then continue end
            if _G.RivalsCHT_Aimbot and not _G.RivalsCHT_Aimbot.IsAlive(ch) then continue end
            local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"); if not head then continue end
            if isInFOV(head) and isVisible(head) then found = { player = pl, head = head }; break end
        end
        if not found then
            if firing then mouse1release(); firing = false end
        else
            if not firing then mouse1press(); firing = true end
        end
    end

    loopConn = RunService.Heartbeat:Connect(function() pcall(check) end)
    RegisterUnload(function()
        if loopConn then loopConn:Disconnect() end
        if firing   then pcall(mouse1release) end
    end)
end

-- ============================================================
-- Trigger Bot
-- ============================================================
do
    local lastFire = 0

    RunService.Heartbeat:Connect(function()
        if not Toggles.TriggerBot then return end
        if not Toggles.TriggerBot.Value then return end
        if not Options.TriggerBotKey then return end
        local ok, keyState = pcall(function() return Options.TriggerBotKey:GetState() end)
        if not ok or not keyState then return end

        local cam = Workspace.CurrentCamera; if not cam then return end
        local unitRay = cam:ScreenPointToRay(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        local lc = player.Character
        rp.FilterDescendantsInstances = lc and { lc } or {}
        local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, rp)
        if result and result.Instance then
            local hit = result.Instance
            local model = hit:FindFirstAncestorOfClass("Model")
            if model then
                local targetPl = Players:GetPlayerFromCharacter(model)
                if targetPl and targetPl ~= player then
                    if Toggles.TeamCheck.Value and _G.RivalsCHT_TeamCheck.IsTeammate(targetPl) then return end
                    local delay = (Options.TriggerDelay and Options.TriggerDelay.Value or 50) / 1000
                    local now   = tick()
                    if now - lastFire >= delay then
                        lastFire = now
                        mouse1click()
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- Sixth Sense
-- ============================================================
do
    local renderConn, tripmineLabels, katanaWarned = nil, {}, false

    local function getKatanaHolders()
        local results = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == player then continue end
            if Toggles.TeamCheck.Value and _G.RivalsCHT_TeamCheck.IsTeammate(pl) then continue end
            local ch  = pl.Character; if not ch then continue end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if _G.RivalsCHTUI and _G.RivalsCHTUI.ShowEnemyWeapons then
                local n = _G.RivalsCHTUI.ShowEnemyWeapons.GetEnemyHeldWeapon(pl)
                if n and n:lower():find("katana") then
                    table.insert(results, pl.Name)
                end
            end
        end
        return results
    end

    local function enable()
        renderConn = RunService.RenderStepped:Connect(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("tripmine") and not tripmineLabels[obj] then
                    local b = Instance.new("BillboardGui")
                    b.Size = UDim2.new(0,100,0,30); b.StudsOffset = Vector3.new(0,2,0)
                    b.AlwaysOnTop = true; b.Adornee = obj; b.Parent = CoreGui
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 0.5
                    t.BackgroundColor3 = Color3.fromRGB(255,50,50); t.Text = "TRIPMINE"
                    t.TextColor3 = Color3.new(1,1,1); t.TextScaled = true; t.Font = Enum.Font.GothamBold
                    tripmineLabels[obj] = b
                end
            end
            local toRemove = {}
            for mine, gui in pairs(tripmineLabels) do
                if not mine or not mine.Parent then pcall(function() gui:Destroy() end); table.insert(toRemove, mine) end
            end
            for _, k in ipairs(toRemove) do tripmineLabels[k] = nil end
            local katanas = getKatanaHolders()
            if #katanas > 0 and not katanaWarned then
                Library:Notify("Katana nearby: " .. katanas[1], 2)
                katanaWarned = true
            elseif #katanas == 0 then
                katanaWarned = false
            end
        end)
    end

    local function disable()
        if renderConn then renderConn:Disconnect(); renderConn = nil end
        for _, gui in pairs(tripmineLabels) do pcall(function() gui:Destroy() end) end
        tripmineLabels = {}; katanaWarned = false
    end

    Toggles.SixthSense:OnChanged(function(v) if v then enable() else disable() end end)
    if Toggles.SixthSense.Value then enable() end
    RegisterUnload(disable)
end

-- ============================================================
-- Movement
-- ============================================================
do
    local flyConn, noclipConn, bhopConn
    local flyBody = nil
    local originalGravity = Workspace.Gravity

    -- Speed
    local function applySpeed()
        local ch  = player.Character; if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if Toggles.SpeedEnabled and Toggles.SpeedEnabled.Value then
            hum.WalkSpeed = Options.WalkSpeed and Options.WalkSpeed.Value or 32
        else
            hum.WalkSpeed = 16
        end
    end

    Toggles.SpeedEnabled:OnChanged(function() applySpeed() end)
    Options.WalkSpeed:OnChanged(function() if Toggles.SpeedEnabled.Value then applySpeed() end end)
    player.CharacterAdded:Connect(function() task.wait(0.5); applySpeed() end)

    -- NoClip
    local function enableNoClip()
        if noclipConn then return end
        noclipConn = RunService.Stepped:Connect(function()
            if not Toggles.NoClip.Value then return end
            local ch = player.Character; if not ch then return end
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
    local function disableNoClip()
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local ch = player.Character; if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end

    Toggles.NoClip:OnChanged(function(v) if v then enableNoClip() else disableNoClip() end end)

    -- Fly
    local function enableFly()
        local ch  = player.Character; if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum.PlatformStand = true

        flyBody = Instance.new("BodyVelocity")
        flyBody.Velocity    = Vector3.new(0,0,0)
        flyBody.MaxForce    = Vector3.new(math.huge, math.huge, math.huge)
        flyBody.Parent      = hrp

        flyConn = RunService.RenderStepped:Connect(function()
            if not Toggles.FlyEnabled.Value then return end
            local speed = Options.FlySpeed and Options.FlySpeed.Value or 50
            local cam   = Workspace.CurrentCamera; if not cam then return end
            local dir   = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)      then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)  then dir = dir - Vector3.new(0,1,0) end
            flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.new(0,0,0)
        end)
    end

    local function disableFly()
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBody then flyBody:Destroy(); flyBody = nil end
        local ch  = player.Character; if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    Toggles.FlyEnabled:OnChanged(function(v) if v then enableFly() else disableFly() end end)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if Toggles.FlyEnabled.Value then enableFly() end
    end)

    -- Infinite Jump
    local jumpConn
    jumpConn = UserInputService.JumpRequest:Connect(function()
        if not Toggles.InfiniteJump or not Toggles.InfiniteJump.Value then return end
        local ch  = player.Character; if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    RegisterUnload(function() if jumpConn then jumpConn:Disconnect() end end)

    -- Jump Power
    Options.JumpPower:OnChanged(function()
        local ch  = player.Character; if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
            hum.JumpPower = Options.JumpPower.Value
        end
    end)

    -- Gravity
    Toggles.LowGravity:OnChanged(function(v)
        if v then
            Workspace.Gravity = Options.GravityStrength and Options.GravityStrength.Value or 50
        else
            Workspace.Gravity = originalGravity
        end
    end)
    Options.GravityStrength:OnChanged(function()
        if Toggles.LowGravity and Toggles.LowGravity.Value then
            Workspace.Gravity = Options.GravityStrength.Value
        end
    end)

    -- Super Jump
    local sjConn = UserInputService.JumpRequest:Connect(function()
        if not Toggles.SuperJump or not Toggles.SuperJump.Value then return end
        local ch  = player.Character; if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local bv  = Instance.new("BodyVelocity")
        bv.Velocity  = Vector3.new(0, Options.SuperJumpPower and Options.SuperJumpPower.Value or 100, 0)
        bv.MaxForce  = Vector3.new(0, math.huge, 0)
        bv.Parent    = hrp
        game:GetService("Debris"):AddItem(bv, 0.1)
    end)

    RegisterUnload(function()
        disableFly()
        disableNoClip()
        Workspace.Gravity = originalGravity
        if sjConn then sjConn:Disconnect() end
    end)
end

-- ============================================================
-- Spoof - Skin Unlock (DISABLED - Server-Sided Only)
-- Cosmetics are server-controlled. Use a specialized exploit or skip.
-- ============================================================
do
    local CONFIG_PATH = "4realium/unlock_config.json"
    
    local function loadConfig()
        local ok, data = pcall(function()
            if readfile then
                local raw = readfile(CONFIG_PATH)
                if raw and #raw > 0 then return HttpService:JSONDecode(raw) end
            end
        end)
        return (ok and data) or { Skins = false, Wraps = false, Charms = false, Emotes = false }
    end

    local function saveConfig(cfg)
        pcall(function()
            if writefile then writefile(CONFIG_PATH, HttpService:JSONEncode(cfg)) end
        end)
    end

    local function applyConfig()
        saveConfig({
            Skins  = Toggles.UnlockSkins.Value,
            Wraps  = Toggles.UnlockWraps.Value,
            Charms = Toggles.UnlockCharms.Value,
            Emotes = Toggles.UnlockEmotes.Value,
        })
        Notify("Cosmetics are server-sided. This is a placeholder.")
    end

    Toggles.UnlockSkins:OnChanged(applyConfig)
    Toggles.UnlockWraps:OnChanged(applyConfig)
    Toggles.UnlockCharms:OnChanged(applyConfig)
    Toggles.UnlockEmotes:OnChanged(applyConfig)

    task.spawn(function()
        task.wait(2)
        local cfg = loadConfig()
        if cfg.Skins  then Toggles.UnlockSkins:Set(true) end
        if cfg.Wraps  then Toggles.UnlockWraps:Set(true) end
        if cfg.Charms then Toggles.UnlockCharms:Set(true) end
        if cfg.Emotes then Toggles.UnlockEmotes:Set(true) end
    end)
end
