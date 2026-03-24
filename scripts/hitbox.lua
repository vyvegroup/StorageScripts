--!noverify

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
    Enabled = false,
    ExpandAmount = 2, -- Default expansion amount
    TargetPart = "HumanoidRootPart", -- Part to expand hitbox on
    TeamCheckMode = "All" -- "All" or "Enemies"
}

local UI = Instance.new("ScreenGui")
UI.Name = "HitboxExpanderUI"
UI.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 180) -- Increased height for new button
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -90) -- Center adjusted
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true -- Enable dragging
MainFrame.Parent = UI

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Hitbox Expander"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = TitleBar

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Enable Hitbox"
ToggleButton.Font = Enum.Font.SourceSansSemibold
ToggleButton.TextSize = 16
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

local TeamCheckButton = Instance.new("TextButton")
TeamCheckButton.Size = UDim2.new(0.8, 0, 0, 30)
TeamCheckButton.Position = UDim2.new(0.1, 0, 0.45, 0) -- Position below ToggleButton
TeamCheckButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
TeamCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckButton.Text = "Mode: All Players"
TeamCheckButton.Font = Enum.Font.SourceSansSemibold
TeamCheckButton.TextSize = 16
TeamCheckButton.BorderSizePixel = 0
TeamCheckButton.Parent = MainFrame

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
SliderFrame.Position = UDim2.new(0.1, 0, 0.65, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(0.5, 0, 1, 0) -- Initial size
Slider.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
Slider.BorderSizePixel = 0
Slider.Parent = SliderFrame

local SliderHandle = Instance.new("Frame")
SliderHandle.Size = UDim2.new(0, 10, 1, 0)
SliderHandle.Position = UDim2.new(0.5, -5, 0, 0)
SliderHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
SliderHandle.BorderSizePixel = 0
SliderHandle.Parent = SliderFrame

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(0.8, 0, 0, 20)
ValueLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
ValueLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLabel.Text = "Expand: " .. Settings.ExpandAmount
ValueLabel.Font = Enum.Font.SourceSans
ValueLabel.TextSize = 14
ValueLabel.BorderSizePixel = 0
ValueLabel.Parent = MainFrame

-- Draggable UI logic (for mobile and desktop)
local dragging
local dragInput
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragInput = input
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Ended then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Slider logic
local sliding = false
SliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        local function onInputChanged(inputChanged)
            if inputChanged == input and sliding then
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = math.clamp((mousePos.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                Slider.Size = UDim2.new(relativeX, 0, 1, 0)
                SliderHandle.Position = UDim2.new(relativeX, -SliderHandle.Size.X.Offset / 2, 0, 0)
                Settings.ExpandAmount = math.floor(relativeX * 10) + 1 -- Expand from 1 to 11
                ValueLabel.Text = "Expand: " .. Settings.ExpandAmount
            end
        end
        local inputChangedConn = UserInputService.InputChanged:Connect(onInputChanged)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Ended then
                sliding = false
                inputChangedConn:Disconnect()
            end
        end)
    end
end)

-- Hitbox expansion logic
local function updateHitbox(character, playerObject)
    if not character or not character:FindFirstChild(Settings.TargetPart) then return end

    -- Team Check Logic
    if Settings.TeamCheckMode == "Enemies" and playerObject and LocalPlayer.Team and playerObject.Team and LocalPlayer.Team == playerObject.Team then
        -- If in Enemies mode and on the same team, ensure hitbox is removed or not created
        local hitboxPart = character:FindFirstChild("ExpandedHitbox")
        if hitboxPart then
            hitboxPart:Destroy()
        end
        return
    end

    local part = character[Settings.TargetPart]
    local currentSize = part.Size

    -- Create or update an invisible part for hitbox expansion
    local hitboxPart = character:FindFirstChild("ExpandedHitbox")
    if not hitboxPart then
        hitboxPart = Instance.new("Part")
        hitboxPart.Name = "ExpandedHitbox"
        hitboxPart.Transparency = 1 -- Invisible
        hitboxPart.CanCollide = false
        hitboxPart.Anchored = false
        hitboxPart.Massless = true
        hitboxPart.Parent = character
        local weld = Instance.new("Weld")
        weld.Part0 = part
        weld.Part1 = hitboxPart
        weld.Parent = hitboxPart
    end

    if Settings.Enabled then
        hitboxPart.Size = currentSize * Settings.ExpandAmount
        hitboxPart.CFrame = part.CFrame
        if hitboxPart.Weld then
            hitboxPart.Weld.C0 = part.CFrame:inverse() * hitboxPart.CFrame
        end
    else
        hitboxPart.Size = Vector3.new(0,0,0) -- Make it effectively disappear
    end
end

-- Toggle button functionality
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        ToggleButton.Text = "Disable Hitbox"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        ToggleButton.Text = "Enable Hitbox"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
    -- Update all players' hitboxes immediately
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            updateHitbox(player.Character, player)
        end
    end
end)

-- Team Check Button functionality
TeamCheckButton.MouseButton1Click:Connect(function()
    if Settings.TeamCheckMode == "All" then
        Settings.TeamCheckMode = "Enemies"
        TeamCheckButton.Text = "Mode: Enemies Only"
    else
        Settings.TeamCheckMode = "All"
        TeamCheckButton.Text = "Mode: All Players"
    end
    -- Update all players' hitboxes immediately after mode change
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            updateHitbox(player.Character, player)
        end
    end
end)

-- Update hitboxes for all players when settings change or new players join
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        RunService.Heartbeat:Wait()
        updateHitbox(character, player)
        character.Humanoid.Died:Connect(function()
            local hitboxPart = character:FindFirstChild("ExpandedHitbox")
            if hitboxPart then
                hitboxPart:Destroy()
            end
        end)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        updateHitbox(player.Character, player)
        player.Character.Humanoid.Died:Connect(function()
            local hitboxPart = player.Character:FindFirstChild("ExpandedHitbox")
            if hitboxPart then
                hitboxPart:Destroy()
            end
        end)
    end
    player.CharacterAdded:Connect(function(character)
        RunService.Heartbeat:Wait()
        updateHitbox(character, player)
        character.Humanoid.Died:Connect(function()
            local hitboxPart = character:FindFirstChild("ExpandedHitbox")
            if hitboxPart then
                hitboxPart:Destroy()
            end
        end)
    end)
end

-- Continuously update hitbox position (for moving characters)
RunService.Heartbeat:Connect(function()
    if Settings.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild(Settings.TargetPart) then
                local hitboxPart = player.Character:FindFirstChild("ExpandedHitbox")
                if hitboxPart and hitboxPart.Weld and Settings.Enabled then -- Only update if enabled
                    -- Re-check team logic here for continuous updates
                    if Settings.TeamCheckMode == "Enemies" and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                        hitboxPart.Size = Vector3.new(0,0,0)
                    else
                        local part = player.Character[Settings.TargetPart]
                        hitboxPart.Size = part.Size * Settings.ExpandAmount
                        hitboxPart.CFrame = part.CFrame
                        hitboxPart.Weld.C0 = part.CFrame:inverse() * hitboxPart.CFrame
                    end
                elseif hitboxPart and not Settings.Enabled then
                    hitboxPart.Size = Vector3.new(0,0,0)
                end
            end
        end
    end
end)

-- Initial UI setup for slider
local initialRelativeX = (Settings.ExpandAmount - 1) / 10
Slider.Size = UDim2.new(initialRelativeX, 0, 1, 0)
SliderHandle.Position = UDim2.new(initialRelativeX, -SliderHandle.Size.X.Offset / 2, 0, 0)
ValueLabel.Text = "Expand: " .. Settings.ExpandAmount

print("Hitbox Expander Script Loaded!")
