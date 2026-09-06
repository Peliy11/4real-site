getgenv().SCRIPT_KEY = nil

local Onyx = loadstring(game:HttpGet("https://cdn.jnkie.com/OnyxUI.lua"))()

Onyx.Appearance = {
    Title = "4realium",
    Subtitle = "Enter your key to continue",
    KeylessTitle = "4realium",
    KeylessSubtitle = "No key required for this build - you're verified.",
    Icon = "",
}

Onyx.Links.Discord = "discord.gg/jnkie"
Onyx.Storage.FileName = "4realium_key"
Onyx.Storage.Remember = false
Onyx.Storage.AutoLoad = false
Onyx.Options.Keyless = false

Onyx.Shop = {
    Enabled = true,
    Icon = "",
    Title = "Get Premium",
    Subtitle = "Instant delivery - 24/7 support",
    ButtonText = "Buy",
    Link = "jnkie.com"
}

Onyx:LaunchJunkie({
    Service = "4real",
    Identifier = "1104877",
    Provider = "Apollo Program"
})

while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
end
