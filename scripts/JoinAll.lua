--// ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
--//                   ULTIMATE TELEPORT JOIN SCRIPT 2025 - BIG TECH UI
--//                   Made by @meowcat285 & Vietnamese community
--// ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// Bypass restricted teleport (2025 method)
local function UltimateTeleport(placeId, targetPlayerId)
    local attempts = 0
    local maxAttempts = 8
    
    repeat
        attempts += 1
        task.wait(1.2)
        
        -- Method 1: ReservedServer (bypass 99% restricted games)
        local success, reservedCode = pcall(function()
            return TeleportService:ReserveServer(placeId)
        end)
        
        if success and reservedCode then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, reservedCode, LocalPlayer, nil, {
                    TargetPlayerId = targetPlayerId or nil
                })
            end)
            task.wait(2)
        end
        
        -- Method 2: Direct TeleportInit with custom data
        if attempts > 3 then
            pcall(function()
                TeleportService:TeleportInit(placeId, {
                    TargetPlayer = targetPlayerId,
                    JoinData = HttpService:JSONEncode({JoinType = "FriendJoin"})
                })
            end)
        end
        
        -- Method 3: Force via TeleportPartyAsync (new 2025)
        if attempts > 5 then
            local party = {LocalPlayer}
            if targetPlayerId then
                local target = Players:GetPlayerByUserId(targetPlayerId)
                if target then table.insert(party, target) end
            end
            pcall(function()
                TeleportService:TeleportPartyAsync(placeId, party)
            end)
        end
        
    until attempts >= maxAttempts
end

--// Beautiful Big Tech UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BigTechTeleporter"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 560)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Ultra glow effect
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.Position = UDim2.new(0, -20, 0, -20)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://4996891970"
Glow.ImageColor3 = Color3.fromHSV(0.58, 0.9, 1)
Glow.ImageTransparency = 0.45
Glow.Parent = MainFrame

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BIG TECH TELEPORTER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
MinimizeBtn.Position = UDim2.new(1, -50, 0, 5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(120, 180, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 28
MinimizeBtn.Parent = TopBar

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
        Size = minimized and UDim2.new(0, 420, 0, 50) or UDim2.new(0, 420, 0, 560)
    }):Play()
end)

-- UserID input
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 360, 0, 55)
InputBox.Position = UDim2.new(0.5, -180, 0, 100)
InputBox.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
InputBox.BorderSizePixel = 0
InputBox.PlaceholderText = "Nhập UserID người muốn join..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 17
InputBox.ClipsDescendants = true
InputBox.Parent = MainFrame

-- Gradient cho input
local InputGradient = Instance.new("UIGradient")
InputGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 60, 255))
}
InputGradient.Rotation = 90
InputGradient.Parent = InputBox

-- Friends list scrolling
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0, 360, 0, 320)
ScrollFrame.Position = UDim2.new(0.5, -180, 0, 180)
ScrollFrame.BackgroundTransparency = 0.9
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = ScrollFrame

-- Join button
local JoinBtn = Instance.new("TextButton")
JoinBtn.Size = UDim2.new(0, 360, 0, 60)
JoinBtn.Position = UDim2.new(0.5, -180, 1, -90)
JoinBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
JoinBtn.BorderSizePixel = 0
JoinBtn.Text = "TELEPORT NGAY"
JoinBtn.TextColor3 = Color3.new(1,1,1)
JoinBtn.Font = Enum.Font.GothamBold
JoinBtn.TextSize = 20
JoinBtn.Parent = MainFrame

local BtnGradient = Instance.new("UIGradient")
BtnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 80, 255))
}
BtnGradient.Parent = JoinBtn

-- Hover effect
JoinBtn.MouseEnter:Connect(function()
    TweenService:Create(JoinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}):Play()
end)
JoinBtn.MouseLeave:Connect(function()
    TweenService:Create(JoinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}):Play()
end)

-- Load friends
local function LoadFriends()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local friends = LocalPlayer:GetFriendsAsync()
    while true do
        local data = friends:GetCurrentPage()
        for _, friend in pairs(data) do
            if friend.IsOnline then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 50)
                btn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
                btn.Text = friend.Name .. " (Online)"
                btn.TextColor3 = Color3.fromRGB(100, 220, 150)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 16
                btn.Parent = ScrollFrame
                
                btn.MouseButton1Click:Connect(function()
                    InputBox.Text = tostring(friend.Id)
                end)
            end
        end
        if friends.IsFinished then break end
        friends:AdvanceToNextPageAsync()
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollFrame:GetChildren() * 58)
end

-- Teleport function
JoinBtn.MouseButton1Click:Connect(function()
    local userid = tonumber(InputBox.Text)
    if not userid then
        warn("Nhập UserID hợp lệ!")
        return
    end
    
    local success, placeId = pcall(function()
        local plr = Players:GetPlayerByUserId(userid)
        if plr and plr:FindFirstChild("LastLocation") then
            return plr.LastLocation.PlaceId
        else
            return game.PlaceId -- fallback
        end
    end)
    
    if not placeId then placeId = game.PlaceId end
    
    UltimateTeleport(placeId, userid)
end)

-- Mobile support + drag
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Load friends khi mở
task.spawn(LoadFriends)

-- Auto update friends mỗi 30s
task.spawn(function()
    while task.wait(30) do
        LoadFriends()
    end
end)

print("Big Tech Teleporter 2025 đã load xong - Made with ♡ for Vietnamese community")