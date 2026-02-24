-- ═══════════════════════════════════════
-- EXAMPLE USAGE
-- ═══════════════════════════════════════
local FlavorUI = loadstring(game:HttpGet("https://venxy.wasmer.app/raw/lib"))()

-- Tạo Window
local Window = FlavorUI.new({
    Title = "Game Hub",
    Size = UDim2.new(0, 290, 0, 370),
})

-- Tạo toggle button cho mobile
FlavorUI.CreateToggleButton(Window, {
    Position = UDim2.new(0, 14, 0.4, 0),
})

-- ═══ TAB 1: COMBAT ═══
local CombatTab = Window:AddTab({
    Name = "Combat",
    Icon = "⚔",
})

local MainSection = CombatTab:AddSection({ Name = "Main" })

MainSection:AddToggle({
    Name = "Auto Attack",
    Description = "Automatically attacks nearby enemies",
    Default = false,
    Callback = function(value)
        print("Auto Attack:", value)
    end,
})

MainSection:AddSlider({
    Name = "Attack Range",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 5,
    Suffix = " studs",
    Callback = function(value)
        print("Range:", value)
    end,
})

MainSection:AddToggle({
    Name = "Auto Parry",
    Default = true,
    Callback = function(value)
        print("Auto Parry:", value)
    end,
})

MainSection:AddDropdown({
    Name = "Target Mode",
    Options = {"Nearest", "Lowest HP", "Highest Level", "Random"},
    Default = "Nearest",
    Callback = function(value)
        print("Target:", value)
    end,
})

-- ═══ TAB 2: MOVEMENT ═══
local MoveTab = Window:AddTab({
    Name = "Move",
    Icon = "🏃",
})

local SpeedSection = MoveTab:AddSection({ Name = "Speed" })

SpeedSection:AddToggle({
    Name = "Speed Hack",
    Callback = function(v)
        if v then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
})

SpeedSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(v)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end)
    end,
})

SpeedSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 10,
    Callback = function(v)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
        end)
    end,
})

local TeleportSection = MoveTab:AddSection({ Name = "Teleport" })

TeleportSection:AddButton({
    Name = "TP to Spawn",
    Description = "Teleport back to spawn point",
    Callback = function()
        FlavorUI:Notify({
            Title = "Teleported",
            Message = "You have been moved to spawn",
            Type = "Success",
            Duration = 2,
        })
    end,
})

-- ═══ TAB 3: VISUALS ═══
local VisualTab = Window:AddTab({
    Name = "Visuals",
    Icon = "👁",
})

local ESPSection = VisualTab:AddSection({ Name = "ESP" })

ESPSection:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(v) print("ESP:", v) end,
})

ESPSection:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 122, 255),
    Callback = function(color)
        print("Color:", color)
    end,
})

ESPSection:AddDropdown({
    Name = "ESP Type",
    Options = {"Box", "Corner", "Highlight", "Name Only"},
    Default = "Box",
    Callback = function(v) print("ESP Type:", v) end,
})

-- ═══ TAB 4: SETTINGS ═══
local SettingsTab = Window:AddTab({
    Name = "Settings",
    Icon = "⚙",
})

local InfoSection = SettingsTab:AddSection({ Name = "Info" })

InfoSection:AddParagraph({
    Title = "Flavor UI v2.0",
    Content = "A modern, clean UI library designed for mobile. Inspired by Apple, Google, and Microsoft design systems.",
})

InfoSection:AddLabel({
    Text = "Made with ❤️ for the community",
})

InfoSection:AddInput({
    Name = "Webhook URL",
    Placeholder = "https://discord.com/api/...",
    Callback = function(v) print("Webhook:", v) end,
})

InfoSection:AddAccentButton({
    Name = "Join Discord",
    Callback = function()
        FlavorUI:Notify({
            Title = "Discord",
            Message = "Link copied to clipboard!",
            Type = "Info",
        })
    end,
})

InfoSection:AddAccentButton({
    Name = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end,
})

-- Welcome notification
FlavorUI:Notify({
    Title = "Welcome",
    Message = "Flavor UI loaded successfully!",
    Type = "Success",
    Duration = 3,
})