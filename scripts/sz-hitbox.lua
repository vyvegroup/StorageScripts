--[[
    SZ Hitbox Pro v7.0 - Premium UI Edition
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✓ Expands HumanoidRootPart (Real Damage!)
    ✓ Modern UI with Animations
    ✓ Mobile Optimized Touch Controls
    ✓ Visual Effects & Feedback
    ✓ Team Check | Death Detection
    
    Made by Super Z
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Config
local LocalPlayer = Players.LocalPlayer
local Hitboxes = {}
local Connections = {}
local OriginalSizes = {}

local Config = {
    Enabled = false,
    Mode = "Enemy",
    Size = 15,
    Transparency = 0.65
}

-- Colors
local Colors = {
    Primary = Color3.fromRGB(99, 102, 241),
    PrimaryDark = Color3.fromRGB(79, 70, 229),
    Success = Color3.fromRGB(34, 197, 94),
    Danger = Color3.fromRGB(239, 68, 68),
    Warning = Color3.fromRGB(245, 158, 11),
    Dark = Color3.fromRGB(15, 15, 20),
    DarkLight = Color3.fromRGB(25, 25, 35),
    Gray = Color3.fromRGB(40, 40, 55),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(156, 163, 175)
}

-- ═══════════════════════════════════════════════
-- CORE FUNCTIONS
-- ═══════════════════════════════════════════════

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
    return humanoid.Health > 0
end

local function createHitbox(player)
    if player == LocalPlayer then return end
    
    if Hitboxes[player] then
        removeHitbox(player)
    end
    
    local character = player.Character
    if not character or not isAlive(character) or not isEnemy(player) then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if not OriginalSizes[player] then
        OriginalSizes[player] = rootPart.Size
    end
    
    rootPart.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
    rootPart.Transparency = Config.Transparency
    
    Hitboxes[player] = {
        Character = character,
        RootPart = rootPart,
        Connections = {}
    }
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SZHighlight"
    highlight.FillTransparency = 0.88
    highlight.OutlineTransparency = 0.4
    highlight.FillColor = Color3.fromRGB(99, 102, 241)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Adornee = character
    highlight.Parent = character
    Hitboxes[player].Highlight = highlight
    
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
    
    local ancestryConn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then removeHitbox(player) end
    end)
    table.insert(Hitboxes[player].Connections, ancestryConn)
end

function removeHitbox(player)
    local data = Hitboxes[player]
    if data then
        if data.RootPart and data.RootPart.Parent and OriginalSizes[player] then
            data.RootPart.Size = OriginalSizes[player]
            data.RootPart.Transparency = 0
        end
        if data.Highlight then data.Highlight:Destroy() end
        if data.Connections then
            for _, conn in ipairs(data.Connections) do
                if conn then conn:Disconnect() end
            end
        end
        Hitboxes[player] = nil
    end
end

local function updateHitboxSizes()
    for player, data in pairs(Hitboxes) do
        if data.RootPart and data.RootPart.Parent then
            data.RootPart.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
        end
    end
end

local function refreshHitboxes()
    for player, _ in pairs(Hitboxes) do removeHitbox(player) end
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
        if isEnemy(player) then createHitbox(player) end
    end)
    table.insert(Connections, charConn)
    if player.Character and Config.Enabled and isEnemy(player) then
        createHitbox(player)
    end
end

local function startSystem()
    if Config.Enabled then return end
    Config.Enabled = true
    for _, player in pairs(Players:GetPlayers()) do setupPlayer(player) end
    table.insert(Connections, Players.PlayerAdded:Connect(setupPlayer))
    table.insert(Connections, Players.PlayerRemoving:Connect(function(p) removeHitbox(p) end))
    refreshHitboxes()
end

local function stopSystem()
    Config.Enabled = false
    for _, conn in pairs(Connections) do if conn then conn:Disconnect() end end
    Connections = {}
    for player, _ in pairs(Hitboxes) do removeHitbox(player) end
    Hitboxes = {}
end

-- ═══════════════════════════════════════════════
-- PREMIUM UI
-- ═══════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SZHitboxPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local success, CoreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.25, 0)
MainFrame.BackgroundColor3 = Colors.Dark
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- Gradient Border Effect
local Stroke = Instance.new("UIStroke")
Stroke.Color = Colors.Primary
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local GradientBg = Instance.new("UIGradient")
GradientBg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
GradientBg.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = Colors.DarkLight
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 25)
HeaderFix.Position = UDim2.new(0, 0, 1, -25)
HeaderFix.BackgroundColor3 = Colors.DarkLight
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Logo Icon
local LogoIcon = Instance.new("Frame")
LogoIcon.Size = UDim2.new(0, 36, 0, 36)
LogoIcon.Position = UDim2.new(0, 14, 0.5, -18)
LogoIcon.BackgroundColor3 = Colors.Primary
LogoIcon.Parent = Header

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 10)
LogoCorner.Parent = LogoIcon

local LogoGradient = Instance.new("UIGradient")
LogoGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(129, 140, 248)),
    ColorSequenceKeypoint.new(1, Colors.Primary)
})
LogoGradient.Rotation = 45
LogoGradient.Parent = LogoIcon

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 24, 0, 24)
LogoText.Position = UDim2.new(0.5, -12, 0.5, -12)
LogoText.BackgroundTransparency = 1
LogoText.Text = "🎯"
LogoText.TextSize = 18
LogoText.Parent = LogoIcon

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 56, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SZ Hitbox Pro"
Title.TextColor3 = Colors.Text
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = Colors.Danger
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -32, 1, -72)
Content.Position = UDim2.new(0, 16, 0, 64)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Status Badge
local StatusBadge = Instance.new("Frame")
StatusBadge.Size = UDim2.new(1, 0, 0, 32)
StatusBadge.BackgroundColor3 = Colors.Gray
StatusBadge.Parent = Content

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusBadge

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 12, 0.5, -5)
StatusDot.BackgroundColor3 = Colors.Danger
StatusDot.Parent = StatusBadge

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -70, 1, 0)
StatusText.Position = UDim2.new(0, 30, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "STATUS: INACTIVE"
StatusText.TextColor3 = Colors.TextMuted
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBadge

local StatusCount = Instance.new("TextLabel")
StatusCount.Size = UDim2.new(0, 50, 1, 0)
StatusCount.Position = UDim2.new(1, -54, 0, 0)
StatusCount.BackgroundTransparency = 1
StatusCount.Text = "0"
StatusCount.TextColor3 = Colors.TextMuted
StatusCount.TextSize = 12
StatusCount.Font = Enum.Font.GothamBold
StatusCount.Parent = StatusBadge

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 48)
ToggleBtn.Position = UDim2.new(0, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Colors.Gray
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = ""
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 14)
ToggleCorner.Parent = ToggleBtn

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new(Colors.Gray, Colors.Gray)
ToggleGradient.Parent = ToggleBtn

local ToggleIcon = Instance.new("TextLabel")
ToggleIcon.Size = UDim2.new(0, 32, 0, 32)
ToggleIcon.Position = UDim2.new(0, 12, 0.5, -16)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Text = "⏻"
ToggleIcon.TextSize = 22
ToggleIcon.TextColor3 = Colors.TextMuted
ToggleIcon.Parent = ToggleBtn

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
ToggleLabel.Position = UDim2.new(0, 48, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "ACTIVATE HITBOX"
ToggleLabel.TextColor3 = Colors.Text
ToggleLabel.TextSize = 14
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ToggleBtn

-- Mode Button
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(1, 0, 0, 48)
ModeBtn.Position = UDim2.new(0, 0, 0, 96)
ModeBtn.BackgroundColor3 = Colors.Gray
ModeBtn.BorderSizePixel = 0
ModeBtn.Text = ""
ModeBtn.Parent = Content

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 14)
ModeCorner.Parent = ModeBtn

local ModeIcon = Instance.new("TextLabel")
ModeIcon.Size = UDim2.new(0, 32, 0, 32)
ModeIcon.Position = UDim2.new(0, 12, 0.5, -16)
ModeIcon.BackgroundTransparency = 1
ModeIcon.Text = "👥"
ModeIcon.TextSize = 20
ModeIcon.Parent = ModeBtn

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, -60, 1, 0)
ModeLabel.Position = UDim2.new(0, 48, 0, 0)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "MODE: ENEMY TEAM"
ModeLabel.TextColor3 = Colors.Text
ModeLabel.TextSize = 14
ModeLabel.Font = Enum.Font.GothamBold
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = ModeBtn

local ModeBadge = Instance.new("Frame")
ModeBadge.Size = UDim2.new(0, 8, 0, 8)
ModeBadge.Position = UDim2.new(1, -20, 0.5, -4)
ModeBadge.BackgroundColor3 = Colors.Primary
ModeBadge.Parent = ModeBtn

local ModeBadgeCorner = Instance.new("UICorner")
ModeBadgeCorner.CornerRadius = UDim.new(1, 0)
ModeBadgeCorner.Parent = ModeBadge

-- Size Slider
local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(1, 0, 0, 60)
SliderContainer.Position = UDim2.new(0, 0, 0, 156)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = Content

local SliderHeader = Instance.new("Frame")
SliderHeader.Size = UDim2.new(1, 0, 0, 24)
SliderHeader.BackgroundTransparency = 1
SliderHeader.Parent = SliderContainer

local SliderIcon = Instance.new("TextLabel")
SliderIcon.Size = UDim2.new(0, 20, 0, 20)
SliderIcon.Position = UDim2.new(0, 0, 0.5, -10)
SliderIcon.BackgroundTransparency = 1
SliderIcon.Text = "📏"
SliderIcon.TextSize = 14
SliderIcon.Parent = SliderHeader

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -60, 1, 0)
SliderLabel.Position = UDim2.new(0, 24, 0, 0)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Hitbox Size"
SliderLabel.TextColor3 = Colors.Text
SliderLabel.TextSize = 13
SliderLabel.Font = Enum.Font.GothamSemibold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderHeader

local SliderValue = Instance.new("TextLabel")
SliderValue.Size = UDim2.new(0, 40, 1, 0)
SliderValue.Position = UDim2.new(1, -40, 0, 0)
SliderValue.BackgroundTransparency = 1
SliderValue.Text = "15"
SliderValue.TextColor3 = Colors.Primary
SliderValue.TextSize = 14
SliderValue.Font = Enum.Font.GothamBold
SliderValue.Parent = SliderHeader

local SliderTrack = Instance.new("TextButton")
SliderTrack.Size = UDim2.new(1, 0, 0, 14)
SliderTrack.Position = UDim2.new(0, 0, 1, -14)
SliderTrack.BackgroundColor3 = Colors.DarkLight
SliderTrack.BorderSizePixel = 0
SliderTrack.Text = ""
SliderTrack.Parent = SliderContainer

local SliderTrackCorner = Instance.new("UICorner")
SliderTrackCorner.CornerRadius = UDim.new(1, 0)
SliderTrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.22, 0, 1, 0)
SliderFill.BackgroundColor3 = Colors.Primary
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(1, 0)
SliderFillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 24, 0, 24)
SliderKnob.Position = UDim2.new(0.22, -12, 0.5, -12)
SliderKnob.BackgroundColor3 = Colors.Text
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = SliderTrack

local SliderKnobCorner = Instance.new("UICorner")
SliderKnobCorner.CornerRadius = UDim.new(1, 0)
SliderKnobCorner.Parent = SliderKnob

local SliderKnobStroke = Instance.new("UIStroke")
SliderKnobStroke.Color = Colors.Primary
SliderKnobStroke.Thickness = 3
SliderKnobStroke.Parent = SliderKnob

-- Info Text
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 0, 20)
InfoText.Position = UDim2.new(0, 0, 1, -20)
InfoText.BackgroundTransparency = 1
InfoText.Text = "✨ Expands HumanoidRootPart for real damage"
InfoText.TextColor3 = Colors.TextMuted
InfoText.TextSize = 10
InfoText.Font = Enum.Font.Gotham
InfoText.Parent = Content

-- Minimized Button
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 60, 0, 60)
MiniBtn.Position = UDim2.new(0.5, -30, 0, 0)
MiniBtn.BackgroundColor3 = Colors.DarkLight
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "🎯"
MiniBtn.TextSize = 28
MiniBtn.Visible = false
MiniBtn.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniBtn

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Colors.Primary
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniBtn

-- ═══════════════════════════════════════════════
-- ANIMATIONS & INTERACTIONS
-- ═══════════════════════════════════════════════

-- Pulse Animation for Status Dot
local function pulseDot(dot, active)
    if active then
        local tween = TweenService:Create(dot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundColor3 = Color3.fromRGB(74, 222, 128)
        })
        tween:Play()
        return tween
    else
        dot.BackgroundColor3 = Colors.Danger
    end
end

local activeTween = nil

-- Update UI
local function updateUI()
    if Config.Enabled then
        StatusDot.BackgroundColor3 = Colors.Success
        StatusText.Text = "STATUS: ACTIVE"
        StatusText.TextColor3 = Colors.Success
        StatusCount.TextColor3 = Colors.Success
        ToggleLabel.Text = "DEACTIVATE HITBOX"
        ToggleGradient.Color = ColorSequence.new(Colors.Success, Color3.fromRGB(22, 163, 74))
        ToggleIcon.TextColor3 = Colors.Text
        activeTween = pulseDot(StatusDot, true)
    else
        if activeTween then activeTween:Cancel() end
        StatusDot.BackgroundColor3 = Colors.Danger
        StatusText.Text = "STATUS: INACTIVE"
        StatusText.TextColor3 = Colors.TextMuted
        StatusCount.TextColor3 = Colors.TextMuted
        ToggleLabel.Text = "ACTIVATE HITBOX"
        ToggleGradient.Color = ColorSequence.new(Colors.Gray, Colors.Gray)
        ToggleIcon.TextColor3 = Colors.TextMuted
    end
    StatusCount.Text = tostring(#Hitboxes)
end

-- Button Press Effect
local function pressEffect(btn, callback)
    local originalSize = btn.Size
    local originalPos = btn.Position
    
    btn.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 4)
    btn.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 2, originalPos.Y.Scale, originalPos.Y.Offset + 2)
    
    task.delay(0.1, function()
        btn.Size = originalSize
        btn.Position = originalPos
    end)
    
    callback()
end

-- Drag System
local isDragging = false
local dragStart, frameStart

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = Vector3.new(input.Position.X, input.Position.Y, 0)
        frameStart = Vector3.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y, 0)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector3.new(input.Position.X, input.Position.Y, 0) - dragStart
        local newPos = frameStart + delta
        local screen = workspace.CurrentCamera.ViewportSize
        newPos = Vector3.new(
            math.clamp(newPos.X, 0, screen.X - MainFrame.AbsoluteSize.X),
            math.clamp(newPos.Y, 0, screen.Y - MainFrame.AbsoluteSize.Y),
            0
        )
        MainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Button Events
ToggleBtn.MouseButton1Click:Connect(function()
    pressEffect(ToggleBtn, function()
        if Config.Enabled then stopSystem() else startSystem() end
        updateUI()
    end)
end)

ModeBtn.MouseButton1Click:Connect(function()
    pressEffect(ModeBtn, function()
        if Config.Mode == "Enemy" then
            Config.Mode = "All"
            ModeLabel.Text = "MODE: ALL PLAYERS"
            ModeIcon.Text = "🌐"
        else
            Config.Mode = "Enemy"
            ModeLabel.Text = "MODE: ENEMY TEAM"
            ModeIcon.Text = "👥"
        end
        refreshHitboxes()
    end)
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopSystem()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 260, 0, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- Double Tap Minimize (Mobile)
local lastTapTime = 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTapTime < 0.3 then
            MainFrame.Visible = false
            MiniBtn.Visible = true
        end
        lastTapTime = now
    end
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniBtn.Visible = false
end)

-- Slider
local isSliding = false

local function updateSlider(input)
    local relX = input.Position.X - SliderTrack.AbsolutePosition.X
    local percent = math.clamp(relX / SliderTrack.AbsoluteSize.X, 0, 1)
    
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, -12, 0.5, -12)
    
    local size = math.floor(5 + percent * 45)
    Config.Size = size
    SliderValue.Text = tostring(size)
    
    updateHitboxSizes()
end

SliderTrack.InputBegan:Connect(function(input)
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

-- Hover Effects
local function addHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
    end)
end

addHover(ToggleBtn, Colors.Gray, Color3.fromRGB(55, 55, 75))
addHover(ModeBtn, Colors.Gray, Color3.fromRGB(55, 55, 75))
addHover(CloseBtn, Colors.Danger, Color3.fromRGB(248, 113, 113))

-- Entrance Animation
MainFrame.Size = UDim2.new(0, 260, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.5, -130, 0.5, 0)

local entranceTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 260, 0, 320),
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -130, 0.25, 0)
})
entranceTween:Play()

-- Notification
local function notify(title, text)
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 280, 0, 70)
    Notification.Position = UDim2.new(1, 20, 0, 20)
    Notification.BackgroundColor3 = Colors.DarkLight
    Notification.BorderSizePixel = 0
    Notification.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 14)
    NotifCorner.Parent = Notification
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Colors.Primary
    NotifStroke.Thickness = 1
    NotifStroke.Parent = Notification
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -24, 0, 24)
    NTitle.Position = UDim2.new(0, 14, 0, 12)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Colors.Text
    NTitle.TextSize = 15
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notification
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -24, 0, 22)
    NText.Position = UDim2.new(0, 14, 0, 38)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Colors.TextMuted
    NText.TextSize = 12
    NText.Font = Enum.Font.Gotham
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notification
    
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -300, 0, 20)
    }):Play()
    
    task.delay(3, function()
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 20, 0, 20)
        }):Play()
        task.wait(0.3)
        Notification:Destroy()
    end)
end

-- Initialize
task.wait(0.5)
notify("🎯 SZ Hitbox Pro v7", "Premium UI loaded! Double-tap header to minimize.")

if not hasTeams() then
    Config.Mode = "All"
    ModeLabel.Text = "MODE: ALL PLAYERS"
    ModeIcon.Text = "🌐"
    InfoText.Text = "⚠️ No teams detected - All players mode active"
end

-- Update count periodically
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(0.5)
        StatusCount.Text = tostring(#Hitboxes)
    end
end)

print("═════════════════════════════════════")
print("  SZ Hitbox Pro v7.0 - Premium UI")
print("═════════════════════════════════════")
print("  ✓ Modern UI with Animations")
print("  ✓ Mobile Optimized Touch Controls")
print("  ✓ Real Damage - Expands RootPart")
print("═════════════════════════════════════")
