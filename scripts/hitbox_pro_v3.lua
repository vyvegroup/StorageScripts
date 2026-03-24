--[[
    Hitbox Pro Script v3.0 - ACTUAL WORKING HITBOX
    - Expands REAL character body parts (not fake parts)
    - Works with both R6 and R15 characters
    - Team Check (All / Enemy Only)
    - Death Detection (Auto remove hitbox when player dies)
    - Mobile Friendly UI with Drag Support
    
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
    Mode = "Enemy", -- "All" or "Enemy"
    Size = 8, -- Multiplier for hitbox size
    Transparency = 0.7,
    Color = Color3.fromRGB(255, 0, 0),
    TeamColor = Color3.fromRGB(0, 255, 0)
}

-- R6 Body Parts
local R6Parts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

-- R15 Body Parts
local R15Parts = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}

-- Check if game has teams
local function hasTeams()
    local Teams = game:FindService("Teams")
    return Teams and #Teams:GetTeams() > 0
end

-- Check if player is on enemy team
local function isEnemy(player)
    if Config.Mode == "All" then
        return true
    end
    
    if not hasTeams() then
        return true
    end
    
    if not LocalPlayer.Team or not player.Team then
        return true
    end
    
    return LocalPlayer.Team ~= player.Team
end

-- Check if character is alive
local function isAlive(character)
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    if humanoid.Health <= 0 then return false end
    
    return true
end

-- Get character type (R6 or R15)
local function getCharacterType(character)
    if character:FindFirstChild("Torso") then
        return "R6"
    elseif character:FindFirstChild("UpperTorso") then
        return "R15"
    end
    return "Unknown"
end

-- Get body parts for character
local function getBodyParts(character)
    local charType = getCharacterType(character)
    if charType == "R6" then
        return R6Parts
    elseif charType == "R15" then
        return R15Parts
    end
    return {}
end

-- Store original sizes
local function storeOriginalSizes(player, character)
    if OriginalSizes[player] then return end
    
    OriginalSizes[player] = {}
    local bodyParts = getBodyParts(character)
    
    for _, partName in ipairs(bodyParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            OriginalSizes[player][partName] = {
                Size = part.Size,
                Transparency = part.Transparency,
                Color = part.Color,
                Material = part.Material
            }
        end
    end
end

-- Expand hitbox for a single part
local function expandPart(part, multiplier)
    if not part or not part:IsA("BasePart") then return end
    
    -- Calculate new size
    local originalSize = part.Size
    local newSize = originalSize * multiplier
    
    -- Apply new size
    part.Size = newSize
    
    -- Make transparent but visible for debugging
    part.Transparency = Config.Transparency
    part.Material = Enum.Material.SmoothPlastic
    
    -- Color based on mode
    if Config.Mode == "Enemy" then
        part.Color = Config.Color
    else
        part.Color = Config.TeamColor
    end
    
    -- Handle MeshParts (R15)
    if part:IsA("MeshPart") then
        -- For MeshParts, we need to also adjust the mesh scale
        -- But since we can't change MeshScale directly, we just change the part size
        -- The collision box will still expand
    end
end

-- Restore original hitbox
local function restorePart(part, originalData)
    if not part or not originalData then return end
    
    part.Size = originalData.Size
    part.Transparency = originalData.Transparency
    part.Color = originalData.Color
    part.Material = originalData.Material
end

-- Create hitbox for player (expand their body parts)
local function createHitbox(player)
    if player == LocalPlayer then return end
    
    -- Clean up existing hitbox
    if Hitboxes[player] then
        removeHitbox(player)
    end
    
    local character = player.Character
    if not character then return end
    
    -- Check if alive
    if not isAlive(character) then return end
    
    -- Check team
    if not isEnemy(player) then return end
    
    -- Store original sizes
    storeOriginalSizes(player, character)
    
    -- Expand all body parts
    local bodyParts = getBodyParts(character)
    local expandedParts = {}
    
    for _, partName in ipairs(bodyParts) do
        local part = character:FindFirstChild(partName)
        if part then
            expandPart(part, Config.Size)
            table.insert(expandedParts, part)
        end
    end
    
    -- Store reference
    Hitboxes[player] = {
        Character = character,
        Parts = expandedParts,
        Connections = {}
    }
    
    -- Add highlight effect for visibility
    local highlight = Instance.new("Highlight")
    highlight.Name = "HitboxHighlight"
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0.5
    highlight.FillColor = Config.Mode == "Enemy" and Config.Color or Config.TeamColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Adornee = character
    highlight.Parent = character
    
    Hitboxes[player].Highlight = highlight
    
    -- Monitor health changes
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
    
    -- Monitor character removal
    local ancestryConn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeHitbox(player)
        end
    end)
    table.insert(Hitboxes[player].Connections, ancestryConn)
end

-- Remove hitbox for player (restore original sizes)
function removeHitbox(player)
    local data = Hitboxes[player]
    if data then
        -- Restore original sizes
        if OriginalSizes[player] then
            local character = player.Character
            if character then
                for partName, originalData in pairs(OriginalSizes[player]) do
                    local part = character:FindFirstChild(partName)
                    if part then
                        restorePart(part, originalData)
                    end
                end
            end
            OriginalSizes[player] = nil
        end
        
        -- Remove highlight
        if data.Highlight and data.Highlight.Parent then
            data.Highlight:Destroy()
        end
        
        -- Disconnect all connections
        if data.Connections then
            for _, conn in ipairs(data.Connections) do
                if conn then conn:Disconnect() end
            end
        end
        
        Hitboxes[player] = nil
    end
end

-- Update hitbox sizes when config changes
local function updateHitboxSizes()
    for player, data in pairs(Hitboxes) do
        if data.Character and isAlive(data.Character) then
            local bodyParts = getBodyParts(data.Character)
            for _, partName in ipairs(bodyParts) do
                local part = data.Character:FindFirstChild(partName)
                if part and OriginalSizes[player] and OriginalSizes[player][partName] then
                    local baseSize = OriginalSizes[player][partName].Size
                    part.Size = baseSize * Config.Size
                end
            end
            
            -- Update highlight color
            if data.Highlight then
                data.Highlight.FillColor = Config.Mode == "Enemy" and Config.Color or Config.TeamColor
            end
        end
    end
end

-- Refresh all hitboxes
local function refreshHitboxes()
    -- Remove all first
    for player, _ in pairs(Hitboxes) do
        removeHitbox(player)
    end
    
    if not Config.Enabled then return end
    
    -- Create new ones
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createHitbox(player)
        end
    end
end

-- Setup player connections
local function setupPlayer(player)
    if player == LocalPlayer then return end
    
    -- Character added
    local charConn = player.CharacterAdded:Connect(function(character)
        if not Config.Enabled then return end
        
        -- Wait for character to load
        task.wait(0.5)
        
        -- Check team
        if not isEnemy(player) then return end
        
        createHitbox(player)
    end)
    
    table.insert(Connections, charConn)
    
    -- If character already exists
    if player.Character then
        if Config.Enabled and isEnemy(player) then
            createHitbox(player)
        end
    end
end

-- Start hitbox system
local function startSystem()
    if Config.Enabled then return end
    Config.Enabled = true
    
    -- Setup existing players
    for _, player in pairs(Players:GetPlayers()) do
        setupPlayer(player)
    end
    
    -- New players joining
    local joinConn = Players.PlayerAdded:Connect(setupPlayer)
    table.insert(Connections, joinConn)
    
    -- Players leaving
    local leaveConn = Players.PlayerRemoving:Connect(function(player)
        removeHitbox(player)
        OriginalSizes[player] = nil
    end)
    table.insert(Connections, leaveConn)
    
    refreshHitboxes()
end

-- Stop hitbox system
local function stopSystem()
    Config.Enabled = false
    
    -- Disconnect all
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    Connections = {}
    
    -- Remove all hitboxes
    for player, _ in pairs(Hitboxes) do
        removeHitbox(player)
    end
    Hitboxes = {}
    OriginalSizes = {}
end

-- Toggle system
local function toggleSystem()
    if Config.Enabled then
        stopSystem()
    else
        startSystem()
    end
    return Config.Enabled
end

-- Change mode
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

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Try to get coregui
local success, CoreGui = pcall(function()
    return game:GetService("CoreGui")
end)
if success then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 200)
MainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Rounded corners
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- Stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 65)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Title bar (drag area)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

-- Fix bottom corners
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 18)
TitleFix.Position = UDim2.new(0, 0, 1, -18)
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title text
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Hitbox Pro v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 55, 55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -50)
Content.Position = UDim2.new(0, 12, 0, 46)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(1, 0, 0, 38)
ToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "🔴 HITBOX: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

-- Mode Button
local ModeBtn = Instance.new("TextButton")
ModeBtn.Name = "ModeBtn"
ModeBtn.Size = UDim2.new(1, 0, 0, 38)
ModeBtn.Position = UDim2.new(0, 0, 0, 48)
ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
ModeBtn.BorderSizePixel = 0
ModeBtn.Text = "👥 MODE: ENEMY TEAM"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.TextSize = 14
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.Parent = Content

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 10)
ModeCorner.Parent = ModeBtn

-- Size Slider Container
local SliderContainer = Instance.new("Frame")
SliderContainer.Name = "SliderContainer"
SliderContainer.Size = UDim2.new(1, 0, 0, 40)
SliderContainer.Position = UDim2.new(0, 0, 0, 96)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = Content

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 18)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "📏 Size Multiplier: 8x"
SliderLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
SliderLabel.TextSize = 12
SliderLabel.Font = Enum.Font.GothamSemibold
SliderLabel.Parent = SliderContainer

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 10)
Slider.Position = UDim2.new(0, 0, 1, -10)
Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
Slider.BorderSizePixel = 0
Slider.Text = ""
Slider.Parent = SliderContainer

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 5)
SliderCorner.Parent = Slider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.35, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = Slider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 5)
FillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new(0.35, -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = Slider

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(0, 8)
KnobCorner.Parent = SliderKnob

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.Position = UDim2.new(0, 0, 1, -22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "✨ Expands actual hitbox parts"
StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Content

-- Minimize button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 70, 0, 40)
MinimizeBtn.Position = UDim2.new(0.5, -35, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "🎯"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Visible = false
MinimizeBtn.Parent = ScreenGui

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 12)
MinCorner.Parent = MinimizeBtn

-- ==================== DRAG SYSTEM ====================

local isDragging = false
local dragStartPos = Vector3.new()
local frameStartPos = Vector3.new()

local function onDragStart(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = Vector3.new(input.Position.X, input.Position.Y, 0)
        frameStartPos = Vector3.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y, 0)
    end
end

local function onDragMove(input)
    if isDragging then
        local delta = Vector3.new(input.Position.X, input.Position.Y, 0) - dragStartPos
        local newPos = frameStartPos + delta
        
        local screenWidth = workspace.CurrentCamera.ViewportSize.X
        local screenHeight = workspace.CurrentCamera.ViewportSize.Y
        
        newPos = Vector3.new(
            math.clamp(newPos.X, 0, screenWidth - MainFrame.AbsoluteSize.X),
            math.clamp(newPos.Y, 0, screenHeight - MainFrame.AbsoluteSize.Y),
            0
        )
        
        MainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end

local function onDragEnd()
    isDragging = false
end

TitleBar.InputBegan:Connect(onDragStart)
UserInputService.InputChanged:Connect(function(input)
    if isDragging then
        onDragMove(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        onDragEnd()
    end
end)

-- ==================== BUTTON EVENTS ====================

ToggleBtn.MouseButton1Click:Connect(function()
    local enabled = toggleSystem()
    if enabled then
        ToggleBtn.Text = "🟢 HITBOX: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
    else
        ToggleBtn.Text = "🔴 HITBOX: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    local mode = changeMode()
    if mode == "Enemy" then
        ModeBtn.Text = "👥 MODE: ENEMY TEAM"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    else
        ModeBtn.Text = "🌐 MODE: ALL PLAYERS"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 160)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopSystem()
    ScreenGui:Destroy()
end)

-- Double tap to minimize on mobile
local lastTap = 0
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.5 then
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

-- Slider functionality
local isSliding = false
local function updateSlider(input)
    local relX = input.Position.X - Slider.AbsolutePosition.X
    local percent = math.clamp(relX / Slider.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
    
    local size = math.floor(2 + percent * 18) -- Size range: 2-20x
    Config.Size = size
    SliderLabel.Text = "📏 Size Multiplier: " .. size .. "x"
    
    updateHitboxSizes()
end

Slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

-- Button hover effects
local function addHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = normalColor
        }):Play()
    end)
end

addHoverEffect(ToggleBtn, Color3.fromRGB(40, 40, 52), Color3.fromRGB(55, 55, 70))
addHoverEffect(ModeBtn, Color3.fromRGB(40, 40, 52), Color3.fromRGB(55, 55, 70))
addHoverEffect(CloseBtn, Color3.fromRGB(220, 55, 55), Color3.fromRGB(255, 80, 80))

-- ==================== INITIALIZATION ====================

-- Notification
local function notify(title, text, duration)
    duration = duration or 3
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 260, 0, 65)
    Notification.Position = UDim2.new(1, 20, 0, 20)
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Notification.BorderSizePixel = 0
    Notification.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 12)
    NotifCorner.Parent = Notification
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(60, 60, 80)
    NotifStroke.Thickness = 1
    NotifStroke.Parent = Notification
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -24, 0, 22)
    NTitle.Position = UDim2.new(0, 12, 0, 10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NTitle.TextSize = 15
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notification
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -24, 0, 20)
    NText.Position = UDim2.new(0, 12, 0, 34)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(170, 170, 190)
    NText.TextSize = 12
    NText.Font = Enum.Font.Gotham
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notification
    
    -- Animate in
    TweenService:Create(Notification, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -280, 0, 20)
    }):Play()
    
    -- Animate out
    task.delay(duration, function()
        TweenService:Create(Notification, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 20, 0, 20)
        }):Play()
        task.wait(0.25)
        Notification:Destroy()
    end)
end

-- Initialize
notify("🎯 Hitbox Pro v3", "Drag title to move UI!", 4)

-- Team check
if hasTeams() then
    StatusLabel.Text = "⚔️ Teams detected | Expands actual parts"
else
    StatusLabel.Text = "⚠️ No teams | All players mode"
    Config.Mode = "All"
    ModeBtn.Text = "🌐 MODE: ALL PLAYERS"
    ModeBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 160)
end

print("[Hitbox Pro v3] Loaded successfully!")
print("[Hitbox Pro v3] This version expands ACTUAL character hitbox parts")
print("[Hitbox Pro v3] Works with both R6 and R15 characters")
