--[[
    SZ Hitbox Script v6.0 - EXPAND ROOT PART ONLY
    - Expands ONLY HumanoidRootPart (main hitbox)
    - Does NOT create new parts
    - Does NOT change visual properties (no desync)
    - Just changes SIZE = Real damage!
    
    Made by Super Z
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Hitboxes = {}
local Connections = {}
local OriginalSizes = {}

local Config = {
    Enabled = false,
    Mode = "Enemy",
    Size = 15,
    Transparency = 0.7
}

-- Check teams
local function hasTeams()
    local Teams = game:FindService("Teams")
    return Teams and #Teams:GetTeams() > 0
end

local function isEnemy(player)
    if Config.Mode == "All" then return true end
    if not hasTeams() then return true end
    if not LocalPlayer.Team or not player.Team then return true end
    return LocalPlayer.Team ~= player.Team
end

local function isAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

-- Expand HumanoidRootPart
local function createHitbox(player)
    if player == LocalPlayer then return end
    
    if Hitboxes[player] then
        removeHitbox(player)
    end
    
    local character = player.Character
    if not character then return end
    if not isAlive(character) then return end
    if not isEnemy(player) then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Store original size
    if not OriginalSizes[player] then
        OriginalSizes[player] = rootPart.Size
    end
    
    -- ONLY change SIZE - nothing else!
    rootPart.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
    
    -- Make it visible (optional - for debugging)
    rootPart.Transparency = Config.Transparency
    
    -- Store reference
    Hitboxes[player] = {
        Character = character,
        RootPart = rootPart,
        Connections = {}
    }
    
    -- Add highlight for visibility
    local highlight = Instance.new("Highlight")
    highlight.Name = "SZHighlight"
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0.5
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Adornee = character
    highlight.Parent = character
    
    Hitboxes[player].Highlight = highlight
    
    -- Monitor health
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        local healthConn = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                task.wait(0.1)
                removeHitbox(player)
            end
        end)
        table.insert(Hitboxes[player].Connections, healthConn)
    end
    
    -- Monitor character
    local ancestryConn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeHitbox(player)
        end
    end)
    table.insert(Hitboxes[player].Connections, ancestryConn)
end

-- Remove and restore
function removeHitbox(player)
    local data = Hitboxes[player]
    if data then
        -- Restore original size
        if data.RootPart and data.RootPart.Parent and OriginalSizes[player] then
            data.RootPart.Size = OriginalSizes[player]
            data.RootPart.Transparency = 0
        end
        
        if data.Highlight and data.Highlight.Parent then
            data.Highlight:Destroy()
        end
        
        if data.Connections then
            for _, conn in ipairs(data.Connections) do
                if conn then conn:Disconnect() end
            end
        end
        
        Hitboxes[player] = nil
    end
end

-- Update sizes
local function updateHitboxSizes()
    for player, data in pairs(Hitboxes) do
        if data.RootPart and data.RootPart.Parent then
            data.RootPart.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
        end
    end
end

local function refreshHitboxes()
    for player, _ in pairs(Hitboxes) do
        removeHitbox(player)
    end
    
    if not Config.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createHitbox(player)
        end
    end
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    
    local charConn = player.CharacterAdded:Connect(function(character)
        if not Config.Enabled then return end
        task.wait(0.3)
        if not isEnemy(player) then return end
        createHitbox(player)
    end)
    
    table.insert(Connections, charConn)
    
    if player.Character then
        if Config.Enabled and isEnemy(player) then
            createHitbox(player)
        end
    end
end

local function startSystem()
    if Config.Enabled then return end
    Config.Enabled = true
    
    for _, player in pairs(Players:GetPlayers()) do
        setupPlayer(player)
    end
    
    local joinConn = Players.PlayerAdded:Connect(setupPlayer)
    table.insert(Connections, joinConn)
    
    local leaveConn = Players.PlayerRemoving:Connect(function(player)
        removeHitbox(player)
        OriginalSizes[player] = nil
    end)
    table.insert(Connections, leaveConn)
    
    refreshHitboxes()
end

local function stopSystem()
    Config.Enabled = false
    
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    Connections = {}
    
    for player, _ in pairs(Hitboxes) do
        removeHitbox(player)
    end
    Hitboxes = {}
end

local function toggleSystem()
    if Config.Enabled then
        stopSystem()
    else
        startSystem()
    end
    return Config.Enabled
end

local function changeMode()
    if Config.Mode == "Enemy" then
        Config.Mode = "All"
    else
        Config.Mode = "Enemy"
    end
    refreshHitboxes()
    return Config.Mode
end

-- ==================== UI ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SZHitboxUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local success, CoreGui = pcall(function() return game:GetService("CoreGui") end)
if success then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 240)
MainFrame.Position = UDim2.new(0.5, -120, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 20)
TitleFix.Position = UDim2.new(0, 0, 1, -20)
TitleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 SZ Hitbox v6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -28, 1, -56)
Content.Position = UDim2.new(0, 14, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Info
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 36)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "✅ Expands HumanoidRootPart\nReal character part = REAL DAMAGE!"
InfoLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = Content

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0, 0, 0, 42)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "🔴  HITBOX: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(1, 0, 0, 42)
ModeBtn.Position = UDim2.new(0, 0, 0, 92)
ModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
ModeBtn.BorderSizePixel = 0
ModeBtn.Text = "👥  MODE: ENEMY TEAM"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.TextSize = 15
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.Parent = Content

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 10)
ModeCorner.Parent = ModeBtn

local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(1, 0, 0, 48)
SliderContainer.Position = UDim2.new(0, 0, 0, 144)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = Content

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "📏  Size: 15 studs"
SliderLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
SliderLabel.TextSize = 13
SliderLabel.Font = Enum.Font.GothamSemibold
SliderLabel.Parent = SliderContainer

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 12)
Slider.Position = UDim2.new(0, 0, 1, -12)
Slider.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Slider.BorderSizePixel = 0
Slider.Text = ""
Slider.Parent = SliderContainer

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = Slider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.22, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = Slider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 6)
FillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 18, 0, 18)
SliderKnob.Position = UDim2.new(0.22, -9, 0.5, -9)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = Slider

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.Position = UDim2.new(0, 0, 1, -22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Only changes SIZE - no desync!"
StatusLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Content

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 70, 0, 44)
MinimizeBtn.Position = UDim2.new(0.5, -35, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "🎯"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 22
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Visible = false
MinimizeBtn.Parent = ScreenGui

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 14)
MinCorner.Parent = MinimizeBtn

-- Drag
local isDragging, dragStartPos, frameStartPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = Vector3.new(input.Position.X, input.Position.Y, 0)
        frameStartPos = Vector3.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y, 0)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector3.new(input.Position.X, input.Position.Y, 0) - dragStartPos
        local newPos = frameStartPos + delta
        local screen = workspace.CurrentCamera.ViewportSize
        newPos = Vector3.new(math.clamp(newPos.X, 0, screen.X - MainFrame.AbsoluteSize.X), math.clamp(newPos.Y, 0, screen.Y - MainFrame.AbsoluteSize.Y), 0)
        MainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Buttons
ToggleBtn.MouseButton1Click:Connect(function()
    local enabled = toggleSystem()
    if enabled then
        ToggleBtn.Text = "🟢  HITBOX: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 150, 75)
    else
        ToggleBtn.Text = "🔴  HITBOX: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    local mode = changeMode()
    if mode == "Enemy" then
        ModeBtn.Text = "👥  MODE: ENEMY TEAM"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    else
        ModeBtn.Text = "🌐  MODE: ALL PLAYERS"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(90, 55, 170)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopSystem()
    ScreenGui:Destroy()
end)

local lastTap = 0
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.4 then
            MainFrame.Visible = false
            MinimizeBtn.Visible = true
        end
        lastTap = now
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizeBtn.Visible = false
end)

-- Slider
local isSliding = false

local function updateSlider(input)
    local relX = input.Position.X - Slider.AbsolutePosition.X
    local percent = math.clamp(relX / Slider.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, -9, 0.5, -9)
    
    local size = math.floor(5 + percent * 45)
    Config.Size = size
    SliderLabel.Text = "📏  Size: " .. size .. " studs"
    
    updateHitboxSizes()
end

Slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding then updateSlider(input) end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

-- Hover
local function addHover(btn, normal, hover)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play() end)
end

addHover(ToggleBtn, Color3.fromRGB(35, 35, 48), Color3.fromRGB(50, 50, 65))
addHover(ModeBtn, Color3.fromRGB(35, 35, 48), Color3.fromRGB(50, 50, 65))
addHover(CloseBtn, Color3.fromRGB(230, 60, 60), Color3.fromRGB(255, 90, 90))

-- Notification
local function notify(title, text, duration)
    duration = duration or 3
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 280, 0, 70)
    Notification.Position = UDim2.new(1, 20, 0, 20)
    Notification.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    Notification.BorderSizePixel = 0
    Notification.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 14)
    NotifCorner.Parent = Notification
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(55, 55, 75)
    NotifStroke.Thickness = 1
    NotifStroke.Parent = Notification
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -24, 0, 24)
    NTitle.Position = UDim2.new(0, 14, 0, 12)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NTitle.TextSize = 16
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notification
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -24, 0, 22)
    NText.Position = UDim2.new(0, 14, 0, 38)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(170, 170, 190)
    NText.TextSize = 13
    NText.Font = Enum.Font.Gotham
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notification
    
    TweenService:Create(Notification, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -300, 0, 20)}):Play()
    task.delay(duration, function()
        TweenService:Create(Notification, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 20, 0, 20)}):Play()
        task.wait(0.25)
        Notification:Destroy()
    end)
end

notify("🎯 SZ Hitbox v6", "Expands HumanoidRootPart only!", 4)

if hasTeams() then
    StatusLabel.Text = "⚔️ Teams detected | RootPart expansion"
else
    StatusLabel.Text = "⚠️ No teams | All players mode"
    Config.Mode = "All"
    ModeBtn.Text = "🌐  MODE: ALL PLAYERS"
    ModeBtn.BackgroundColor3 = Color3.fromRGB(90, 55, 170)
end

print("[SZ Hitbox v6] Loaded!")
print("[SZ Hitbox v6] Expands HumanoidRootPart (real character part)")
print("[SZ Hitbox v6] This is the MAIN hitbox - should deal damage!")
