import { readFileSync } from 'fs';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://dnybtgfpewrkxnkhqrst.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRueWJ0Z2ZwZXdya3hua2hxcnN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2NTAzMDAsImV4cCI6MjEwNDIyNjMwMH0.TNzA75rw2iqiAnA0ITSBS_x4coNCSECqTujahas3LPg'
);

const keySystem = `-- WindUI loader
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "4realium"
Junkie.identifier = "1196591"
Junkie.provider = "4realium"

WindUI.Services.junkiedevelopment = {
    Name = "Junkie Development", 
    Icon = "shield-check",
    Args = { "ServiceId", "ApiKey", "Provider" },

    New = function()
        local function Verify(key)
            local result = Junkie.check_key(key)
            if result and result.valid then
                if result.message == "KEYLESS" then
                    getgenv().SCRIPT_KEY = "KEYLESS"
                    return true, "Keyless mode"
                elseif result.message == "KEY_VALID" then
                    getgenv().SCRIPT_KEY = key
                    return true, "Key valid"
                else
                    return false, "Invalid key"
                end
            end
        end

        local function Copy()
            local link = Junkie.get_key_link()
            if setclipboard then setclipboard(link) end
            return link
        end

        return { Verify = Verify, Copy = Copy }
    end
}

local Window = WindUI:CreateWindow({
    Title = "4realium",
    Theme = "Dark",
    Transparent = true,
    Resizable = true,

    KeySystem = {
        Note = "Enter your key to continue.",
        SaveKey = true,
        API = {
            {
                Title = "Junkie",
                Desc  = "Click to copy link",
                Icon  = "key-round",
                Type  = "junkiedevelopment"
            }
        }
    }
})

while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
end

`;

const scriptFile = readFileSync('C:/Users/eliwp/Downloads/4realium_fixed.txt', 'utf8');

const old = 'HomeGame:AddLabel("Players: " .. tostring(#Players:GetPlayers()) .. " / " .. tostring(game.MaxPlayers))';
const fix = 'HomeGame:AddLabel("Players: " .. tostring(#Players:GetPlayers()) .. " / " .. (pcall(function() return game.MaxPlayers end) and tostring(game.MaxPlayers) or "?"))';
const body = scriptFile.replace(old, fix);

const fullCode = keySystem + body;

console.log('Total code length:', fullCode.length);

const { data, error } = await supabase
  .from('scripts')
  .update({
    code: fullCode,
    key_code: ''
  })
  .eq('slug', 'rivals')
  .select('id, slug');

if (error) {
  console.error('Error:', error.message);
  process.exit(1);
}

console.log('Updated:', JSON.stringify(data));
