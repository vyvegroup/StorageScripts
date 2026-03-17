-- ============================================================
-- NPC FREEZE + TELEPORT CONTROLLER
-- Full Deep Freeze: Anchored, CanTouch, Scripts, BodyMovers
-- Teleport NPC ra vị trí siêu xa để vô hiệu damage hitbox
-- UIDragDetector cho cả 2 frame
-- ============================================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ============================================================
-- SHARED DRAG HELPER (dùng UIDragDetector)
-- ============================================================

local function makeDraggable(frame)
    local detector = Instance.new("UIDragDetector")
    detector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
    detector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane
    detector.Parent = frame
    return detector
end

-- ============================================================
-- PHẦN 1: NPC FREEZE + TELEPORT
-- ============================================================

local ScreenGui1 = Instance.new("ScreenGui")
local Frame1 = Instance.new("Frame")
local UICorner1 = Instance.new("UICorner")
local FreezeBtn = Instance.new("TextButton")

ScreenGui1.Name = "NpcControl"
ScreenGui1.Parent = game.CoreGui
ScreenGui1.ResetOnSpawn = false
ScreenGui1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame1.Name = "FreezeFrame"
Frame1.Parent = ScreenGui1
Frame1.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame1.Position = UDim2.new(0.1, 0, 0.4, 0)
Frame1.Size = UDim2.new(0, 160, 0, 50)
Frame1.Active = true
Frame1.ClipsDescendants = false

UICorner1.CornerRadius = UDim.new(0, 8)
UICorner1.Parent = Frame1

FreezeBtn.Parent = Frame1
FreezeBtn.Size = UDim2.new(1, 0, 1, 0)
FreezeBtn.BackgroundTransparency = 1
FreezeBtn.Font = Enum.Font.SourceSansBold
FreezeBtn.Text = "FREEZE: OFF"
FreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FreezeBtn.TextSize = 20
FreezeBtn.ZIndex = 2

-- ✅ Drag cho Frame1
makeDraggable(Frame1)

-- ============================================================
-- FREEZE + TELEPORT LOGIC
-- ============================================================

local isFrozen = false
local npcFolder = workspace:FindFirstChild("LocalNPCs")

-- Lưu vị trí gốc và trạng thái gốc của từng NPC
local frozenData = {}

-- Vị trí siêu xa để vô hiệu hitbox/damage radius
local EXILE_POSITION = Vector3.new(99999, 99999, 99999)
local NPC_COUNT = 6

local function deepFreeze(npc, status)
    local npcKey = tostring(npc)
    local data = frozenData[npcKey] or {}
    frozenData[npcKey] = data

    -- Lưu CFrame gốc của HumanoidRootPart trước khi teleport
    local hrp = npc:FindFirstChild("HumanoidRootPart")

    if status then
        -- ✅ Lưu vị trí gốc để restore sau
        if hrp then
            data.originalCFrame = hrp.CFrame
        end
    end

    for _, obj in pairs(npc:GetDescendants()) do

        -- 1. BasePart: Anchor + zero velocity + tắt touch + mạng về server
        if obj:IsA("BasePart") then
            if status then
                data[obj] = {
                    anchored   = obj.Anchored,
                    canTouch   = obj.CanTouch,
                    canCollide = obj.CanCollide,
                }
                obj.Anchored = true
                obj.CanTouch = false
                obj.CanCollide = false -- tắt collide để hitbox không trigger
                obj.Velocity = Vector3.zero
                obj.RotVelocity = Vector3.zero
                obj.AssemblyLinearVelocity  = Vector3.zero
                obj.AssemblyAngularVelocity = Vector3.zero
                pcall(function() obj:SetNetworkOwner(nil) end)
            else
                local saved = data[obj]
                if saved then
                    obj.Anchored   = saved.anchored
                    obj.CanTouch   = saved.canTouch
                    obj.CanCollide = saved.canCollide
                end
            end

        -- 2. Humanoid: WalkSpeed/JumpPower = 0, PlatformStand
        elseif obj:IsA("Humanoid") then
            if status then
                data[obj] = {
                    walkSpeed    = obj.WalkSpeed,
                    jumpPower    = obj.JumpPower,
                    platformStand = obj.PlatformStand,
                }
                obj.WalkSpeed     = 0
                obj.JumpPower     = 0
                obj.PlatformStand = true
            else
                local saved = data[obj]
                if saved then
                    obj.WalkSpeed     = saved.walkSpeed
                    obj.JumpPower     = saved.jumpPower
                    obj.PlatformStand = saved.platformStand
                end
            end

        -- 3. Script / LocalScript: Disabled = true
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            if status then
                data[obj] = { disabled = obj.Disabled }
                obj.Disabled = true
            else
                local saved = data[obj]
                if saved then obj.Disabled = saved.disabled end
            end

        -- 4. Animator: dừng tất cả animation
        elseif obj:IsA("Animator") then
            if status then
                for _, track in pairs(obj:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end

        -- 5. BodyMover / Force / Constraint: Enabled = false
        elseif obj:IsA("BodyMover")
            or obj:IsA("AlignPosition")
            or obj:IsA("AlignOrientation")
            or obj:IsA("LinearVelocity")
            or obj:IsA("AngularVelocity")
            or obj:IsA("VectorForce")
            or obj:IsA("Torque") then
            if status then
                data[obj] = { enabled = obj.Enabled }
                obj.Enabled = false
            else
                local saved = data[obj]
                if saved then obj.Enabled = saved.enabled end
            end
        end
    end

    -- ✅ Teleport toàn bộ NPC ra vị trí siêu xa sau khi đã anchor
    -- (làm sau cùng để tránh lag khi đang iterate descendants)
    if hrp then
        if status then
            -- Đặt tất cả parts về exile bằng cách dịch chuyển HumanoidRootPart
            hrp.CFrame = CFrame.new(EXILE_POSITION)
        else
            -- Restore về vị trí gốc
            local savedCF = data.originalCFrame
            if savedCF then
                hrp.CFrame = savedCF
                -- Unanchor sau khi đã về đúng vị trí
                hrp.Anchored = false
            end
        end
    end
end

local function toggleFreeze(status)
    if not npcFolder then
        warn("[NpcFreeze] Không tìm thấy 'LocalNPCs' trong Workspace!")
        return
    end

    for i = 1, NPC_COUNT do
        local npc = npcFolder:FindFirstChild("LocalGuard_Base" .. i)
        if npc then
            deepFreeze(npc, status)
        end
    end

    if not status then
        frozenData = {}
    end
end

FreezeBtn.MouseButton1Click:Connect(function()
    isFrozen = not isFrozen
    toggleFreeze(isFrozen)

    if isFrozen then
        FreezeBtn.Text = "FREEZE: ON"
        FreezeBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
        Frame1.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
    else
        FreezeBtn.Text = "FREEZE: OFF"
        FreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Frame1.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)

-- ✅ Heartbeat: giữ freeze & exile liên tục chống server override
RunService.Heartbeat:Connect(function()
    if not isFrozen or not npcFolder then return end
    for i = 1, NPC_COUNT do
        local npc = npcFolder:FindFirstChild("LocalGuard_Base" .. i)
        if npc then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Giữ exile position
                if (hrp.Position - EXILE_POSITION).Magnitude > 100 then
                    hrp.CFrame = CFrame.new(EXILE_POSITION)
                end
                hrp.Velocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 0
            end
        end
    end
end)

-- ============================================================
-- PHẦN 2: TELEPORT BACK TO START
-- ============================================================

local ScreenGui2 = Instance.new("ScreenGui")
local Frame2 = Instance.new("Frame")
local UICorner2 = Instance.new("UICorner")
local ActionButton = Instance.new("TextButton")
local BtnCorner = Instance.new("UICorner")

local character = player.Character or player.CharacterAdded:Wait()
local initialCFrame = character:WaitForChild("HumanoidRootPart").CFrame

ScreenGui2.Name = "TeleportBackUI"
ScreenGui2.Parent = game.CoreGui
ScreenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame2.Name = "TeleportFrame"
Frame2.Parent = ScreenGui2
Frame2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Frame2.Position = UDim2.new(0.5, -75, 0.5, -25)
Frame2.Size = UDim2.new(0, 160, 0, 50)
Frame2.Active = true

UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = Frame2

ActionButton.Name = "ActionButton"
ActionButton.Parent = Frame2
ActionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ActionButton.Size = UDim2.new(1, -10, 1, -10)
ActionButton.Position = UDim2.new(0, 5, 0, 5)
ActionButton.Font = Enum.Font.SourceSansBold
ActionButton.Text = "Back to Start"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.TextSize = 18
ActionButton.ZIndex = 2

BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ActionButton

-- ✅ Drag cho Frame2
makeDraggable(Frame2)

ActionButton.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = initialCFrame
    end
end)