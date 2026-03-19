-- ================================================================
-- NPC CONTROLLER v5
-- Fix: góc dưới bị vuông khi minimize
--      → Panel.ClipsDescendants=true + Header cao 58px (16px bị clip)
--      → UICorner của Panel tự bo góc sạch khi thu nhỏ còn 42px
-- Thêm: ReturnBack — lưu vị trí hiện tại trước khi về start
-- ================================================================

local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer

-- ================================================================
-- UTILS
-- ================================================================
local function mkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
end

local function mkPad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
end

local function tw(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end

local C = {
    bg0     = Color3.fromRGB(10,  11,  15),
    bg1     = Color3.fromRGB(18,  20,  26),
    bg2     = Color3.fromRGB(26,  29,  38),
    bg3     = Color3.fromRGB(32,  36,  48),
    header  = Color3.fromRGB(14,  16,  22),
    accent  = Color3.fromRGB(92,  210, 160),
    accentD = Color3.fromRGB(20,  50,  36),
    blue    = Color3.fromRGB(88,  170, 255),
    blueD   = Color3.fromRGB(18,  40,  75),
    orange  = Color3.fromRGB(255, 170, 70),
    orangeD = Color3.fromRGB(55,  35,  8),
    warn    = Color3.fromRGB(255, 100, 80),
    txt0    = Color3.fromRGB(220, 225, 235),
    txt1    = Color3.fromRGB(130, 138, 158),
    txt2    = Color3.fromRGB(65,  72,  92),
    dot_off = Color3.fromRGB(50,  55,  72),
}

-- ================================================================
-- GUI
-- ================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name           = "NpcCtrlV5"
Gui.Parent         = game.CoreGui
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ================================================================
-- SHADOW (sibling của Panel, sync qua Heartbeat)
-- ================================================================
local Shadow = Instance.new("ImageLabel")
Shadow.Parent             = Gui
Shadow.Size               = UDim2.new(0, 250, 0, 310)
Shadow.Position           = UDim2.new(0, 12, 0.5, -152)
Shadow.BackgroundTransparency = 1
Shadow.Image              = "rbxassetid://6014261993"
Shadow.ImageColor3        = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency  = 0.52
Shadow.ScaleType          = Enum.ScaleType.Slice
Shadow.SliceCenter        = Rect.new(49, 49, 450, 450)
Shadow.ZIndex             = 1

-- ================================================================
-- PANEL
-- ClipsDescendants = TRUE là chìa khóa fix góc minimize:
-- Khi Panel thu lại còn 42px, UICorner của Panel bo sạch 4 góc.
-- Header (cao 58px) bị cắt tại y=42 → 2 góc dưới của Header không lộ.
-- ================================================================
local PANEL_H_FULL = 278
local PANEL_H_MIN  = 42

local Panel = Instance.new("Frame")
Panel.Name             = "Panel"
Panel.Parent           = Gui
Panel.Size             = UDim2.new(0, 218, 0, PANEL_H_FULL)
Panel.Position         = UDim2.new(0, 28, 0.5, -(PANEL_H_FULL/2))
Panel.BackgroundColor3 = C.bg1
Panel.BorderSizePixel  = 0
Panel.Active           = true
Panel.ZIndex           = 2
Panel.ClipsDescendants = true  -- KEY: cắt children tại border → UICorner hoạt động đúng
mkCorner(Panel, 16)

-- UIDragDetector đặt trực tiếp trên Panel
local DD = Instance.new("UIDragDetector")
DD.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
DD.DragStyle     = Enum.UIDragDetectorDragStyle.TranslatePlane
DD.Parent        = Panel

-- ✅ Sync shadow qua Heartbeat — đơn giản, không cần event của DragDetector
RunService.Heartbeat:Connect(function()
    local p = Panel.Position
    Shadow.Position = UDim2.new(p.X.Scale, p.X.Offset - 16, p.Y.Scale, p.Y.Offset - 12)
end)

-- ================================================================
-- HEADER
-- Cao 58px = 42 (visible) + 16 (bị Panel.ClipsDescendants cắt)
-- UICorner bo 4 góc, 2 góc dưới không thấy → header trông phẳng dưới
-- Khi minimize Panel=42px, toàn bộ header vừa khít → Panel tự bo đẹp
-- ================================================================
local Header = Instance.new("Frame")
Header.Parent           = Panel
Header.Size             = UDim2.new(1, 0, 0, 58)
Header.Position         = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel  = 0
Header.ZIndex           = 3
mkCorner(Header, 16)

-- Drag hint (ba chấm giữa header)
local DragHint = Instance.new("TextLabel")
DragHint.Parent             = Header
DragHint.Size               = UDim2.new(0, 40, 0, 42)
DragHint.Position           = UDim2.new(0.5, -20, 0, 0)
DragHint.BackgroundTransparency = 1
DragHint.Text               = "· · ·"
DragHint.TextSize           = 11
DragHint.Font               = Enum.Font.Gotham
DragHint.TextColor3         = C.txt2
DragHint.TextXAlignment     = Enum.TextXAlignment.Center
DragHint.TextYAlignment     = Enum.TextYAlignment.Bottom
DragHint.ZIndex             = 4

-- Title
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Parent             = Header
TitleLbl.Size               = UDim2.new(1, -72, 0, 42)
TitleLbl.Position           = UDim2.new(0, 16, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "NPC Control"
TitleLbl.TextSize           = 13
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextColor3         = C.txt0
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
TitleLbl.ZIndex             = 4

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent           = Header
MinBtn.Size             = UDim2.new(0, 26, 0, 26)
MinBtn.Position         = UDim2.new(1, -36, 0, 8)
MinBtn.BackgroundColor3 = C.bg2
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.Text             = "−"
MinBtn.TextSize         = 15
MinBtn.TextColor3       = C.txt1
MinBtn.BorderSizePixel  = 0
MinBtn.ZIndex           = 5
mkCorner(MinBtn, 7)

MinBtn.MouseEnter:Connect(function() tw(MinBtn, {BackgroundColor3=C.bg3}) end)
MinBtn.MouseLeave:Connect(function() tw(MinBtn, {BackgroundColor3=C.bg2}) end)

-- ================================================================
-- CONTENT
-- ================================================================
local Content = Instance.new("Frame")
Content.Parent             = Panel
Content.Size               = UDim2.new(1, 0, 1, -42)
Content.Position           = UDim2.new(0, 0, 0, 42)
Content.BackgroundTransparency = 1
Content.ZIndex             = 3

local CLayout = Instance.new("UIListLayout")
CLayout.Parent              = Content
CLayout.SortOrder           = Enum.SortOrder.LayoutOrder
CLayout.Padding             = UDim.new(0, 6)
CLayout.FillDirection       = Enum.FillDirection.Vertical
CLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mkPad(Content, 10, 10, 12, 12)

-- Row/label/button factories
local function makeRow(order, bgColor)
    local row = Instance.new("Frame")
    row.Parent            = Content
    row.Size              = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3  = bgColor or C.bg2
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    row.ZIndex            = 4
    mkCorner(row, 11)
    return row
end

local function addAccent(row, color)
    local a = Instance.new("Frame")
    a.Parent=row; a.Size=UDim2.new(0,3,0,24); a.Position=UDim2.new(0,10,0.5,-12)
    a.BackgroundColor3=color; a.BorderSizePixel=0; a.ZIndex=5
    mkCorner(a,2); return a
end

local function addMainLbl(row, text, color)
    local l = Instance.new("TextLabel")
    l.Parent=row; l.BackgroundTransparency=1
    l.Size=UDim2.new(1,-80,1,0); l.Position=UDim2.new(0,22,0,0)
    l.Text=text; l.TextSize=13; l.Font=Enum.Font.GothamBold
    l.TextColor3=color; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=5; return l
end

local function addSubLbl(row, text, color)
    local l = Instance.new("TextLabel")
    l.Parent=row; l.BackgroundTransparency=1
    l.Size=UDim2.new(1,-20,0,14); l.Position=UDim2.new(0,22,1,-17)
    l.Text=text; l.TextSize=10; l.Font=Enum.Font.Gotham
    l.TextColor3=color; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=5; return l
end

local function addBtn(row)
    local b = Instance.new("TextButton")
    b.Parent=row; b.Size=UDim2.new(1,0,1,0)
    b.BackgroundTransparency=1; b.Text=""; b.ZIndex=7
    return b
end

-- ================================================================
-- ROW 1: FREEZE TOGGLE
-- ================================================================
local FreezeRow    = makeRow(1)
local FreezeAccent = addAccent(FreezeRow, C.dot_off)
local FreezeLbl    = addMainLbl(FreezeRow, "Freeze NPCs", C.txt0)
local FreezeSub    = addSubLbl(FreezeRow, "0 / 6 bị khóa", C.txt2)
local FreezeBtn    = addBtn(FreezeRow)

local ToggleBg = Instance.new("Frame")
ToggleBg.Parent=FreezeRow; ToggleBg.Size=UDim2.new(0,42,0,22)
ToggleBg.Position=UDim2.new(1,-52,0.5,-11); ToggleBg.BackgroundColor3=C.dot_off
ToggleBg.BorderSizePixel=0; ToggleBg.ZIndex=5
mkCorner(ToggleBg,11)

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Parent=ToggleBg; ToggleKnob.Size=UDim2.new(0,16,0,16)
ToggleKnob.Position=UDim2.new(0,3,0.5,-8); ToggleKnob.BackgroundColor3=C.txt1
ToggleKnob.BorderSizePixel=0; ToggleKnob.ZIndex=6
mkCorner(ToggleKnob,8)

FreezeBtn.MouseEnter:Connect(function() tw(FreezeRow,{BackgroundColor3=C.bg3}) end)
FreezeBtn.MouseLeave:Connect(function() tw(FreezeRow,{BackgroundColor3=C.bg2}) end)

-- ================================================================
-- ROW 2: VỀ VỊ TRÍ BAN ĐẦU
-- Trước khi teleport: lưu vị trí hiện tại vào returnCFrame
-- ================================================================
local TpRow    = makeRow(2)
local TpAccent = addAccent(TpRow, C.blue)
local TpLbl    = addMainLbl(TpRow, "Về vị trí ban đầu", C.blue)
local TpSub    = addSubLbl(TpRow, "Lưu vị trí → teleport", C.txt2)
local TpBtn    = addBtn(TpRow)

TpBtn.MouseEnter:Connect(function() tw(TpRow,{BackgroundColor3=C.bg3}) end)
TpBtn.MouseLeave:Connect(function() tw(TpRow,{BackgroundColor3=C.bg2}) end)

-- ================================================================
-- ROW 3: RETURN BACK
-- Quay về vị trí đã lưu lúc nhấn "Về vị trí ban đầu"
-- Mờ ban đầu, sáng lên khi có vị trí lưu
-- ================================================================
local RbRow    = makeRow(3, C.bg0)   -- bắt đầu mờ (bg0)
local RbAccent = addAccent(RbRow, C.orangeD)
local RbLbl    = addMainLbl(RbRow, "Return Back", C.txt2)
local RbSub    = addSubLbl(RbRow, "Nhấn 'Về ban đầu' trước", C.txt2)
local RbBtn    = addBtn(RbRow)

-- ================================================================
-- ROW 4: STATUS BAR
-- ================================================================
local StatusRow = Instance.new("Frame")
StatusRow.Parent=Content; StatusRow.Size=UDim2.new(1,0,0,28)
StatusRow.BackgroundColor3=C.bg0; StatusRow.BorderSizePixel=0
StatusRow.LayoutOrder=4; StatusRow.ZIndex=4
mkCorner(StatusRow,8)

local StatusDot = Instance.new("Frame")
StatusDot.Parent=StatusRow; StatusDot.Size=UDim2.new(0,6,0,6)
StatusDot.Position=UDim2.new(0,11,0.5,-3); StatusDot.BackgroundColor3=C.dot_off
StatusDot.BorderSizePixel=0; StatusDot.ZIndex=5
mkCorner(StatusDot,3)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Parent=StatusRow; StatusLbl.Size=UDim2.new(1,-28,1,0)
StatusLbl.Position=UDim2.new(0,24,0,0); StatusLbl.BackgroundTransparency=1
StatusLbl.Text="Chờ lệnh"; StatusLbl.TextSize=10; StatusLbl.Font=Enum.Font.Gotham
StatusLbl.TextColor3=C.txt2; StatusLbl.TextXAlignment=Enum.TextXAlignment.Left
StatusLbl.ZIndex=5

-- ================================================================
-- MINIMIZE LOGIC
-- ================================================================
local isMin = false

MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    local h = isMin and PANEL_H_MIN or PANEL_H_FULL
    tw(Panel,  {Size=UDim2.new(0,218,0,h)}, 0.22, Enum.EasingStyle.Quart)
    tw(Shadow, {Size=UDim2.new(0,250,0,h+30)}, 0.22, Enum.EasingStyle.Quart)
    Content.Visible = not isMin
    MinBtn.Text = isMin and "+" or "−"
end)

-- ================================================================
-- FREEZE LOGIC
-- ================================================================
local isFrozen   = false
local npcFolder  = workspace:FindFirstChild("LocalNPCs")
local frozenData = {}
local NPC_COUNT  = 6
local EXILE      = Vector3.new(99999, 99999, 99999)

local function deepFreeze(npc, status)
    local key=tostring(npc); local data=frozenData[key] or {}; frozenData[key]=data
    local hrp=npc:FindFirstChild("HumanoidRootPart")
    if status and hrp then data.origCF=hrp.CFrame end
    for _,obj in pairs(npc:GetDescendants()) do
        if obj:IsA("BasePart") then
            if status then
                data[obj]={an=obj.Anchored,ct=obj.CanTouch,cc=obj.CanCollide}
                obj.Anchored=true; obj.CanTouch=false; obj.CanCollide=false
                obj.Velocity=Vector3.zero; obj.RotVelocity=Vector3.zero
                obj.AssemblyLinearVelocity=Vector3.zero
                obj.AssemblyAngularVelocity=Vector3.zero
                pcall(function() obj:SetNetworkOwner(nil) end)
            else local s=data[obj]; if s then obj.Anchored=s.an;obj.CanTouch=s.ct;obj.CanCollide=s.cc end end
        elseif obj:IsA("Humanoid") then
            if status then
                data[obj]={ws=obj.WalkSpeed,jp=obj.JumpPower,ps=obj.PlatformStand}
                obj.WalkSpeed=0;obj.JumpPower=0;obj.PlatformStand=true
            else local s=data[obj]; if s then obj.WalkSpeed=s.ws;obj.JumpPower=s.jp;obj.PlatformStand=s.ps end end
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            if status then data[obj]={d=obj.Disabled};obj.Disabled=true
            else local s=data[obj]; if s then obj.Disabled=s.d end end
        elseif obj:IsA("Animator") then
            if status then for _,t in pairs(obj:GetPlayingAnimationTracks()) do t:Stop(0) end end
        elseif obj:IsA("BodyMover") or obj:IsA("AlignPosition") or obj:IsA("AlignOrientation")
            or obj:IsA("LinearVelocity") or obj:IsA("AngularVelocity")
            or obj:IsA("VectorForce") or obj:IsA("Torque") then
            if status then data[obj]={en=obj.Enabled};obj.Enabled=false
            else local s=data[obj]; if s then obj.Enabled=s.en end end
        end
    end
    if hrp then
        if status then hrp.CFrame=CFrame.new(EXILE)
        else local cf=data.origCF; if cf then hrp.Anchored=false;hrp.CFrame=cf end end
    end
end

local function setFreezeUI(on, count)
    if on then
        tw(ToggleBg,{BackgroundColor3=C.accent})
        tw(ToggleKnob,{Position=UDim2.new(1,-19,0.5,-8),BackgroundColor3=Color3.new(1,1,1)})
        tw(FreezeAccent,{BackgroundColor3=C.accent})
        FreezeLbl.TextColor3=C.accent
        FreezeSub.Text=count.." / "..NPC_COUNT.." bị khóa"; FreezeSub.TextColor3=C.accent
        tw(StatusDot,{BackgroundColor3=C.accent})
        StatusLbl.Text="Đang freeze  ·  "..count.." NPC"; StatusLbl.TextColor3=C.accent
        tw(Panel,{BackgroundColor3=Color3.fromRGB(13,21,17)})
    else
        tw(ToggleBg,{BackgroundColor3=C.dot_off})
        tw(ToggleKnob,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=C.txt1})
        tw(FreezeAccent,{BackgroundColor3=C.dot_off})
        FreezeLbl.TextColor3=C.txt0
        FreezeSub.Text="0 / "..NPC_COUNT.." bị khóa"; FreezeSub.TextColor3=C.txt2
        tw(StatusDot,{BackgroundColor3=C.dot_off})
        StatusLbl.Text="Chờ lệnh"; StatusLbl.TextColor3=C.txt2
        tw(Panel,{BackgroundColor3=C.bg1})
    end
end

local function toggleFreeze(status)
    if not npcFolder then
        StatusLbl.Text="⚠  Không tìm thấy LocalNPCs"
        StatusLbl.TextColor3=C.warn; StatusDot.BackgroundColor3=C.warn; return
    end
    local count=0
    for i=1,NPC_COUNT do
        local npc=npcFolder:FindFirstChild("LocalGuard_Base"..i)
        if npc then deepFreeze(npc,status); if status then count+=1 end end
    end
    if not status then frozenData={} end
    setFreezeUI(status,count)
end

FreezeBtn.MouseButton1Click:Connect(function()
    isFrozen=not isFrozen; toggleFreeze(isFrozen)
end)

RunService.Heartbeat:Connect(function()
    if not isFrozen or not npcFolder then return end
    for i=1,NPC_COUNT do
        local npc=npcFolder:FindFirstChild("LocalGuard_Base"..i)
        if npc then
            local hrp=npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                if (hrp.Position-EXILE).Magnitude>200 then hrp.CFrame=CFrame.new(EXILE) end
                hrp.Velocity=Vector3.zero; hrp.AssemblyLinearVelocity=Vector3.zero
            end
            local hum=npc:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed=0 end
        end
    end
end)

-- ================================================================
-- TELEPORT LOGIC
-- ================================================================
local character     = player.Character or player.CharacterAdded:Wait()
local initialCFrame = character:WaitForChild("HumanoidRootPart").CFrame

-- returnCFrame: vị trí lưu TRƯỚC khi về start → ReturnBack dùng
local returnCFrame = nil

local function setRbActive(active)
    if active then
        tw(RbRow,    {BackgroundColor3=C.bg2})
        tw(RbAccent, {BackgroundColor3=C.orange})
        tw(RbLbl,    {TextColor3=C.orange})
        RbSub.Text="Quay về vị trí trước"; RbSub.TextColor3=C.txt1
    else
        tw(RbRow,    {BackgroundColor3=C.bg0})
        tw(RbAccent, {BackgroundColor3=C.orangeD})
        tw(RbLbl,    {TextColor3=C.txt2})
        RbSub.Text="Nhấn 'Về ban đầu' trước"; RbSub.TextColor3=C.txt2
    end
end

-- Về vị trí ban đầu
TpBtn.MouseButton1Click:Connect(function()
    local char=player.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    -- Lưu vị trí hiện tại để ReturnBack có thể dùng
    returnCFrame = hrp.CFrame
    setRbActive(true)

    hrp.CFrame = initialCFrame

    tw(TpRow,{BackgroundColor3=C.blueD},0.08)
    TpLbl.Text="✓  Đã về!"; tw(TpLbl,{TextColor3=Color3.fromRGB(150,220,255)})
    TpSub.Text="Vị trí cũ đã lưu vào Return Back"
    task.delay(1.6, function()
        TpLbl.Text="Về vị trí ban đầu"; tw(TpLbl,{TextColor3=C.blue})
        TpSub.Text="Lưu vị trí → teleport"
        tw(TpRow,{BackgroundColor3=C.bg2},0.25)
    end)
end)

-- Return Back
RbBtn.MouseButton1Click:Connect(function()
    if not returnCFrame then
        RbSub.Text="⚠  Chưa có vị trí! Nhấn 'Về ban đầu' trước"
        task.delay(2, function()
            if not returnCFrame then RbSub.Text="Nhấn 'Về ban đầu' trước" end
        end)
        return
    end
    local char=player.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    hrp.CFrame = returnCFrame

    tw(RbRow,{BackgroundColor3=C.orangeD},0.08)
    RbLbl.Text="✓  Đã quay về!"; tw(RbLbl,{TextColor3=Color3.fromRGB(255,215,130)})
    RbSub.Text="Vị trí đã khôi phục"
    task.delay(1.6, function()
        RbLbl.Text="Return Back"; tw(RbLbl,{TextColor3=C.orange})
        RbSub.Text="Quay về vị trí trước"
        tw(RbRow,{BackgroundColor3=C.bg2},0.25)
    end)
end)

RbBtn.MouseEnter:Connect(function()
    tw(RbRow,{BackgroundColor3= returnCFrame and C.bg3 or C.bg0})
end)
RbBtn.MouseLeave:Connect(function()
    tw(RbRow,{BackgroundColor3= returnCFrame and C.bg2 or C.bg0})
end)