--[[
    Hitbox Pro Script v2.0
    - UI Draggable (Mobile Support)
    - Team Check (All / Enemy Only)
    - Death Detection (Auto remove hitbox when player dies)
    - Real-time Position Tracking
    - Optimized Performance
    
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
local Config = {
    Enabled = false,
    Mode = "Enemy", -- "All" or "Enemy"
    Size = Vector3.new(8, 8, 8),
    Transparency = 0.7,
    Color = Color3.fromRGB(255, 0, 0),
    TeamColor = Color3.fromRGB(0, 255, 0),
    UpdateRate = 1/60 -- 60 FPS
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
        return true -- No team = enemy
    end
    
    return LocalPlayer.Team ~= player.Team
end

-- Check if character is alive
local function isAlive(character)
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    -- Check health
    if humanoid.Health <= 0 then return false end
    
    -- Check if body parts are still there
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    
    return head ~= nil or torso ~= nil
end

-- Create hitbox for player
local function createHitbox(player)
    if player == LocalPlayer then return end
    
    -- Clean up existing hitbox
    if Hitboxes[player] then
        removeHitbox(player)
    end
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Check if alive
    if not isAlive(character) then return end
    
    -- Check team
    if not isEnemy(player) then return end
    
    -- Create hitbox part
    local hitbox = Instance.new("Part")
    hitbox.Name = "HitboxPro_" .. player.Name
    hitbox.Size = Config.Size
    hitbox.Transparency = Config.Transparency
    hitbox.Color = Config.Mode == "Enemy" and Config.Color or Config.TeamColor
    hitbox.Material = Enum.Material.SmoothPlastic
    hitbox.CanCollide = false
    hitbox.Anchored = true
    hitbox.CastShadow = false
    hitbox.Archivable = false
    
    -- Position at root part
    hitbox.CFrame = rootPart.CFrame
    
    -- Add to workspace
    hitbox.Parent = workspace
    
    -- Store reference
    Hitboxes[player] = {
        Part = hitbox,
        Character = character,
        LastUpdate = tick()
    }
    
    -- Add highlight effect
    local highlight = Instance.new("Highlight")
    highlight.Name = "HitboxHighlight"
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.3
    highlight.FillColor = hitbox.Color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Adornee = character
    highlight.Parent = hitbox
    
    -- Store highlight reference
    Hitboxes[player].Highlight = highlight
end

-- Remove hitbox for player (forward declaration fix)
local removeHitbox
removeHitbox = function(player)
    local data = Hitboxes[player]
    if data then
        if data.Part and data.Part.Parent then
            data.Part:Destroy()
        end
        if data.Highlight and data.Highlight.Parent then
            data.Highlight:Destroy()
        end
        if data.Connection then
            data.Connection:Disconnect()
        end
        Hitboxes[player] = nil
    end
end

-- Update hitbox position
local function updateHitbox(player)
    local data = Hitboxes[player]
    if not data or not data.Part then return end
    
    local character = player.Character
    if not character then
        removeHitbox(player)
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        removeHitbox(player)
        return
    end
    
    -- Check if still alive
    if not isAlive(character) then
        removeHitbox(player)
        return
    end
    
    -- Smooth position update
    data.Part.CFrame = rootPart.CFrame
    data.LastUpdate = tick()
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
    player.CharacterAdded:Connect(function(character)
        if not Config.Enabled then return end
        
        -- Wait for character to load
        task.wait(0.5)
        
        -- Check team
        if not isEnemy(player) then return end
        
        createHitbox(player)
        
        -- Monitor humanoid health
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                if health <= 0 then
                    -- Player died, remove hitbox
                    task.wait(0.1)
                    removeHitbox(player)
                end
            end)
        end
        
        -- Monitor character removal
        character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                removeHitbox(player)
            end
        end)
    end)
    
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
    table.insert(Connections, Players.PlayerAdded:Connect(setupPlayer))
    
    -- Players leaving
    table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
        removeHitbox(player)
    end))
    
    -- Update loop - position tracking
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        for player, data in pairs(Hitboxes) do
            if data.Part and data.Part.Parent then
                updateHitbox(player)
            end
        end
    end))
    
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
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Position = UDim2.new(0.5, -100, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

-- Rounded corners
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Title bar (drag area)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Fix bottom corners
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title text
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Hitbox Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -45)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(1, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

-- Mode Button
local ModeBtn = Instance.new("TextButton")
ModeBtn.Name = "ModeBtn"
ModeBtn.Size = UDim2.new(1, 0, 0, 35)
ModeBtn.Position = UDim2.new(0, 0, 0, 45)
ModeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ModeBtn.BorderSizePixel = 0
ModeBtn.Text = "👥 Mode: Enemy"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.TextSize = 14
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.Parent = Content

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 8)
ModeCorner.Parent = ModeBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Made by Super Z | v2.0"
StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Content

-- Size Slider Container
local SliderContainer = Instance.new("Frame")
SliderContainer.Name = "SliderContainer"
SliderContainer.Size = UDim2.new(1, 0, 0, 30)
SliderContainer.Position = UDim2.new(0, 0, 0, 90)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = Content

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 15)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Hitbox Size: 8"
SliderLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
SliderLabel.TextSize = 11
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.Parent = SliderContainer

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 8)
Slider.Position = UDim2.new(0, 0, 1, -8)
Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
Slider.BorderSizePixel = 0
Slider.Text = ""
Slider.Parent = SliderContainer

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = Slider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(120, 90, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = Slider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = SliderFill

-- Minimize button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 60, 0, 35)
MinimizeBtn.Position = UDim2.new(0.5, -30, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "🎯"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Visible = false
MinimizeBtn.Parent = ScreenGui

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- ==================== DRAG SYSTEM ====================

local isDragging = false
local dragStartPos = Vector3.new()
local frameStartPos = Vector3.new()

-- For TitleBar drag
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
        
        -- Clamp to screen
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

-- Connect drag events
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

-- Touch drag for mobile
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        onDragStart(input)
    end
end)

-- ==================== BUTTON EVENTS ====================

-- Toggle button
ToggleBtn.MouseButton1Click:Connect(function()
    local enabled = toggleSystem()
    if enabled then
        ToggleBtn.Text = "🟢 ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 80)
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

-- Mode button
ModeBtn.MouseButton1Click:Connect(function()
    local mode = changeMode()
    if mode == "Enemy" then
        ModeBtn.Text = "👥 Mode: Enemy"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    else
        ModeBtn.Text = "🌐 Mode: All"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 150)
    end
end)

-- Close button
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
            -- Double tap - minimize
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
    
    local size = math.floor(4 + percent * 16) -- Size range: 4-20
    Config.Size = Vector3.new(size, size, size)
    SliderLabel.Text = "Hitbox Size: " .. size
    
    -- Update existing hitboxes
    for player, data in pairs(Hitboxes) do
        if data.Part then
            data.Part.Size = Config.Size
        end
    end
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
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = normalColor
        }):Play()
    end)
end

addHoverEffect(ToggleBtn, Color3.fromRGB(45, 45, 55), Color3.fromRGB(55, 55, 65))
addHoverEffect(ModeBtn, Color3.fromRGB(45, 45, 55), Color3.fromRGB(55, 55, 65))
addHoverEffect(CloseBtn, Color3.fromRGB(200, 60, 60), Color3.fromRGB(230, 80, 80))

-- ==================== INITIALIZATION ====================

-- Notify
local function notify(title, text, duration)
    duration = duration or 3
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 250, 0, 60)
    Notification.Position = UDim2.new(1, -270, 0, 20)
    Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Notification.BorderSizePixel = 0
    Notification.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = Notification
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(60, 60, 70)
    NotifStroke.Thickness = 1
    NotifStroke.Parent = Notification
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -20, 0, 20)
    NTitle.Position = UDim2.new(0, 10, 0, 8)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NTitle.TextSize = 14
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notification
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 0, 20)
    NText.Position = UDim2.new(0, 10, 0, 30)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(180, 180, 190)
    NText.TextSize = 12
    NText.Font = Enum.Font.Gotham
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notification
    
    -- Animate in
    Notification.Position = UDim2.new(1, 20, 0, 20)
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -270, 0, 20)
    }):Play()
    
    -- Animate out and destroy
    task.delay(duration, function()
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 20, 0, 20)
        }):Play()
        task.wait(0.3)
        Notification:Destroy()
    end)
end

-- Initialize
notify("🎯 Hitbox Pro", "Script loaded! Drag title to move.", 4)

-- Team check info
if hasTeams() then
    StatusLabel.Text = "Teams detected | v2.0"
else
    StatusLabel.Text = "No teams | All mode only"
    -- Force All mode if no teams
    Config.Mode = "All"
    ModeBtn.Text = "🌐 Mode: All"
    ModeBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 150)
end

print("[Hitbox Pro] Script loaded successfully!")
print("[Hitbox Pro] Use the toggle button to enable hitboxes")
print("[Hitbox Pro] Drag the title bar to move the UI")