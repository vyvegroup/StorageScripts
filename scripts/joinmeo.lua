--// ═══════════════════════════════════════════════════════════════════
--//  STALKER JOIN UI v3.1 — ULTRA BIG TECH + PERSISTENT STORAGE
--//  Compact • Mobile Drag • Cross-Game • Browse • Auto Save/Load
--// ═══════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// ═══════════════════ STORAGE SYSTEM ═════════════════════════════
local Storage = {}
local SAVE_FILE = "StalkerJoinV3_Data.json"
local PROFILES_FILE = "StalkerJoinV3_Profiles.json"

function Storage:HasFileSystem()
    return (writefile and readfile and isfile) ~= nil
end

function Storage:Save(fileName, data)
    if not self:HasFileSystem() then return false end
    local ok, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(data))
    end)
    return ok
end

function Storage:Load(fileName)
    if not self:HasFileSystem() then return nil end
    local ok, result = pcall(function()
        if isfile(fileName) then
            return HttpService:JSONDecode(readfile(fileName))
        end
        return nil
    end)
    if ok then return result end
    return nil
end

function Storage:Delete(fileName)
    if not self:HasFileSystem() then return end
    pcall(function()
        if isfile(fileName) then
            delfile(fileName)
        end
    end)
end

-- Main data structure
local SaveData = {
    cookie = "",
    lastUserId = "",
    lastUsername = "",
    windowPos = {x = 0.5, y = 0.5},
    fabPos = {x = 12, y = 0.45},
    activeTab = "Track",
    autoTrackInterval = 12,
    theme = "dark",
    profiles = {},
    activeProfile = "Default",
    searchHistory = {},
    settings = {
        autoSave = true,
        showNotifications = true,
        compactMode = false,
        saveWindowPos = true,
    }
}

local function LoadSaveData()
    local data = Storage:Load(SAVE_FILE)
    if data then
        for k, v in pairs(data) do
            SaveData[k] = v
        end
    end
end

local function WriteSaveData()
    if not SaveData.settings.autoSave then return end
    Storage:Save(SAVE_FILE, SaveData)
end

-- Debounced save (avoid spam writes)
local saveQueued = false
local function QueueSave()
    if saveQueued then return end
    saveQueued = true
    task.delay(1, function()
        saveQueued = false
        WriteSaveData()
    end)
end

-- Load on start
LoadSaveData()

--// ═══════════════════ THEME ══════════════════════════════════════
local T = {
    Bg          = Color3.fromRGB(8, 8, 12),
    BgFloat     = Color3.fromRGB(14, 14, 20),
    Surface     = Color3.fromRGB(18, 18, 25),
    Surface2    = Color3.fromRGB(24, 24, 32),
    Surface3    = Color3.fromRGB(30, 30, 40),
    Elevated    = Color3.fromRGB(36, 36, 48),
    Primary     = Color3.fromRGB(100, 100, 255),
    PrimaryDim  = Color3.fromRGB(70, 70, 200),
    Accent      = Color3.fromRGB(160, 80, 255),
    AccentDim   = Color3.fromRGB(120, 60, 200),
    Green       = Color3.fromRGB(40, 200, 120),
    GreenDim    = Color3.fromRGB(25, 150, 90),
    Red         = Color3.fromRGB(240, 60, 80),
    RedDim      = Color3.fromRGB(180, 40, 60),
    Yellow      = Color3.fromRGB(250, 190, 40),
    Blue        = Color3.fromRGB(60, 145, 255),
    Cyan        = Color3.fromRGB(0, 210, 230),
    Orange      = Color3.fromRGB(245, 140, 40),
    Text        = Color3.fromRGB(240, 240, 248),
    Text2       = Color3.fromRGB(160, 160, 180),
    Text3       = Color3.fromRGB(100, 100, 120),
    Text4       = Color3.fromRGB(60, 60, 78),
    Border      = Color3.fromRGB(38, 38, 50),
    BorderLight = Color3.fromRGB(50, 50, 65),
    Glow        = Color3.fromRGB(100, 100, 255),
    Grad1       = Color3.fromRGB(100, 100, 255),
    Grad2       = Color3.fromRGB(180, 80, 255),
    Grad3       = Color3.fromRGB(0, 210, 230),
}

--// ═══════════════════ UTILITIES ══════════════════════════════════
local function Tween(obj, props, dur, style, dir)
    return TweenService:Create(obj, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
end

local function Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = p; return c
end

local function Stroke(p, col, th, tr)
    local s = Instance.new("UIStroke"); s.Color = col or T.Border; s.Thickness = th or 1; s.Transparency = tr or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end

local function Pad(p, t, b, l, r)
    local pd = Instance.new("UIPadding"); pd.PaddingTop = UDim.new(0,t or 0); pd.PaddingBottom = UDim.new(0,b or 0); pd.PaddingLeft = UDim.new(0,l or 0); pd.PaddingRight = UDim.new(0,r or 0); pd.Parent = p; return pd
end

local function Ripple(btn)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = Color3.new(1,1,1); r.BackgroundTransparency = 0.82
    r.BorderSizePixel = 0; r.Size = UDim2.new(0,0,0,0)
    r.Position = UDim2.new(0.5,0,0.5,0); r.AnchorPoint = Vector2.new(0.5,0.5)
    r.ZIndex = btn.ZIndex + 10; r.Parent = btn; Corner(r, 100)
    local mx = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
    local tw = Tween(r, {Size = UDim2.new(0,mx,0,mx), BackgroundTransparency = 1}, 0.55)
    tw:Play(); tw.Completed:Connect(function() r:Destroy() end)
end

--// ═══════════════════ CLEANUP ════════════════════════════════════
pcall(function() CoreGui:FindFirstChild("StalkerV3"):Destroy() end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "StalkerV3"; Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.ResetOnSpawn = false; Gui.IgnoreGuiInset = true
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--// ═══════════════════ NOTIFICATION SYSTEM ════════════════════════
local function Notify(text, color, duration)
    if not SaveData.settings.showNotifications then return end
    local note = Instance.new("Frame")
    note.Size = UDim2.new(0, IsMobile and 260 or 280, 0, 36)
    note.Position = UDim2.new(0.5, 0, 0, -40)
    note.AnchorPoint = Vector2.new(0.5, 0)
    note.BackgroundColor3 = T.Surface
    note.BorderSizePixel = 0; note.ZIndex = 300; note.Parent = Gui
    Corner(note, 8); Stroke(note, color or T.Primary, 1, 0.3)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,3,0.6,0); dot.Position = UDim2.new(0,0,0.2,0)
    dot.BackgroundColor3 = color or T.Primary; dot.BorderSizePixel = 0
    dot.ZIndex = 301; dot.Parent = note; Corner(dot, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-16,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.TextColor3 = T.Text; lbl.TextSize = IsMobile and 10 or 11
    lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 301; lbl.Parent = note

    Tween(note, {Position = UDim2.new(0.5, 0, 0, 50)}, 0.4, Enum.EasingStyle.Back):Play()
    task.delay(duration or 3, function()
        local tw = Tween(note, {Position = UDim2.new(0.5, 0, 0, -40)}, 0.3)
        tw:Play(); tw.Completed:Connect(function() note:Destroy() end)
    end)
end

--// ═══════════════════ FAB TOGGLE ═════════════════════════════════
local fabX = SaveData.fabPos and SaveData.fabPos.x or 12
local fabY = SaveData.fabPos and SaveData.fabPos.y or 0.45

local Fab = Instance.new("TextButton")
Fab.Size = UDim2.new(0, 44, 0, 44)
Fab.Position = UDim2.new(0, fabX, fabY, 0)
Fab.AnchorPoint = Vector2.new(0, 0.5)
Fab.BackgroundColor3 = T.Primary; Fab.Text = ""; Fab.AutoButtonColor = false
Fab.ZIndex = 200; Fab.Parent = Gui; Corner(Fab, 22)

local FabIcon = Instance.new("TextLabel")
FabIcon.Size = UDim2.new(1,0,1,0); FabIcon.BackgroundTransparency = 1
FabIcon.Text = "👁"; FabIcon.TextSize = 18; FabIcon.ZIndex = 201; FabIcon.Parent = Fab

local FabRing = Instance.new("Frame")
FabRing.Size = UDim2.new(1,8,1,8); FabRing.Position = UDim2.new(0.5,0,0.5,0)
FabRing.AnchorPoint = Vector2.new(0.5,0.5); FabRing.BackgroundTransparency = 1
FabRing.ZIndex = 199; FabRing.Parent = Fab; Corner(FabRing, 26)
local fabStroke = Stroke(FabRing, T.Glow, 1.5, 0.4)

spawn(function()
    while Fab.Parent do
        Tween(fabStroke, {Transparency = 0.2}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play(); wait(1.2)
        Tween(fabStroke, {Transparency = 0.7}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play(); wait(1.2)
    end
end)

-- Fab Drag + save position
do
    local dragging, dragStart, startPos, moved
    Fab.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false; dragStart = i.Position; startPos = Fab.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if moved and SaveData.settings.saveWindowPos then
                        SaveData.fabPos = {x = Fab.Position.X.Offset, y = Fab.Position.Y.Scale}
                        QueueSave()
                    end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            if d.Magnitude > 5 then moved = true end
            Fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--// ═══════════════════ MAIN FRAME ═════════════════════════════════
local W = IsMobile and 310 or 330
local H = IsMobile and 460 or 480

local savedX = SaveData.windowPos and SaveData.windowPos.x or 0.5
local savedY = SaveData.windowPos and SaveData.windowPos.y or 0.5

local Main = Instance.new("Frame")
Main.Name = "Main"; Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(savedX, 0, savedY, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = T.Bg; Main.BorderSizePixel = 0
Main.ClipsDescendants = true; Main.Visible = false; Main.ZIndex = 50
Main.Parent = Gui; Corner(Main, 14); Stroke(Main, T.Border, 1, 0.3)

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1,60,1,60); Shadow.Position = UDim2.new(0.5,0,0.5,0)
Shadow.AnchorPoint = Vector2.new(0.5,0.5); Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"; Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.35; Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23,23,277,277); Shadow.ZIndex = 49; Shadow.Parent = Main

--// ═══════════════════ HEADER ═════════════════════════════════════
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,44); Header.BackgroundColor3 = T.Surface
Header.BorderSizePixel = 0; Header.ZIndex = 55; Header.Parent = Main; Corner(Header, 14)

local HdrFix = Instance.new("Frame")
HdrFix.Size = UDim2.new(1,0,0,16); HdrFix.Position = UDim2.new(0,0,1,-16)
HdrFix.BackgroundColor3 = T.Surface; HdrFix.BorderSizePixel = 0; HdrFix.ZIndex = 55; HdrFix.Parent = Header

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1,0,0,2); TopLine.BackgroundColor3 = T.Grad1
TopLine.BorderSizePixel = 0; TopLine.ZIndex = 58; TopLine.Parent = Header; Corner(TopLine, 1)
local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, T.Grad1), ColorSequenceKeypoint.new(0.4, T.Grad2), ColorSequenceKeypoint.new(1, T.Grad3)
}
topGrad.Parent = TopLine
spawn(function()
    local o = 0
    while TopLine.Parent do o = (o + 0.003) % 1; topGrad.Offset = Vector2.new(o, 0); RunService.Heartbeat:Wait() end
end)

local HdrBorder = Instance.new("Frame")
HdrBorder.Size = UDim2.new(1,0,0,1); HdrBorder.Position = UDim2.new(0,0,1,0)
HdrBorder.BackgroundColor3 = T.Border; HdrBorder.BackgroundTransparency = 0.4
HdrBorder.BorderSizePixel = 0; HdrBorder.ZIndex = 56; HdrBorder.Parent = Header

-- Save indicator
local SaveIndicator = Instance.new("Frame")
SaveIndicator.Size = UDim2.new(0, 6, 0, 6)
SaveIndicator.Position = UDim2.new(0, 8, 0.5, -3)
SaveIndicator.BackgroundColor3 = Storage:HasFileSystem() and T.Green or T.Red
SaveIndicator.ZIndex = 58; SaveIndicator.Parent = Header; Corner(SaveIndicator, 3)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0); TitleLbl.Position = UDim2.new(0,18,0,0)
TitleLbl.BackgroundTransparency = 1; TitleLbl.RichText = true
TitleLbl.Text = '<font color="#6464ff">⌘</font>  <font face="GothamBlack">STALKER</font> <font color="rgb(160,160,180)">v3.1</font>'
TitleLbl.TextColor3 = T.Text; TitleLbl.TextSize = IsMobile and 13 or 14
TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 57; TitleLbl.Parent = Header

local function HeaderBtn(icon, pos, hoverColor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,28,0,28); b.Position = pos; b.AnchorPoint = Vector2.new(0,0.5)
    b.BackgroundColor3 = T.Surface2; b.BackgroundTransparency = 1
    b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 57; b.Parent = Header; Corner(b, 6)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(1,0,1,0); ico.BackgroundTransparency = 1
    ico.Text = icon; ico.TextColor3 = T.Text3; ico.TextSize = 13
    ico.Font = Enum.Font.GothamBold; ico.ZIndex = 58; ico.Parent = b

    b.MouseEnter:Connect(function()
        Tween(b, {BackgroundTransparency = 0, BackgroundColor3 = hoverColor or T.Surface3}, 0.15):Play()
        Tween(ico, {TextColor3 = T.Text}, 0.15):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween(b, {BackgroundTransparency = 1}, 0.15):Play()
        Tween(ico, {TextColor3 = T.Text3}, 0.15):Play()
    end)
    b.MouseButton1Click:Connect(function() Ripple(b) end)
    return b
end

local MinBtn = HeaderBtn("─", UDim2.new(1, -68, 0.5, -14))
local CloseBtn = HeaderBtn("✕", UDim2.new(1, -36, 0.5, -14), T.RedDim)

-- Header Drag + save pos
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = Main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if SaveData.settings.saveWindowPos then
                        SaveData.windowPos = {x = Main.Position.X.Scale + Main.Position.X.Offset / Gui.AbsoluteSize.X, y = Main.Position.Y.Scale + Main.Position.Y.Offset / Gui.AbsoluteSize.Y}
                        QueueSave()
                    end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--// ═══════════════════ TAB BAR ════════════════════════════════════
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,36); TabBar.Position = UDim2.new(0,0,0,44)
TabBar.BackgroundColor3 = T.BgFloat; TabBar.BorderSizePixel = 0; TabBar.ZIndex = 54; TabBar.Parent = Main
Pad(TabBar, 0, 0, 8, 8)

local TabBarBorder = Instance.new("Frame")
TabBarBorder.Size = UDim2.new(1,0,0,1); TabBarBorder.Position = UDim2.new(0,0,1,0)
TabBarBorder.BackgroundColor3 = T.Border; TabBarBorder.BackgroundTransparency = 0.5
TabBarBorder.BorderSizePixel = 0; TabBarBorder.ZIndex = 55; TabBarBorder.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder; TabLayout.Padding = UDim.new(0, 3)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center; TabLayout.Parent = TabBar

local tabs = {}
local activeTab = nil
local tabPages = {}

local function CreateTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Name = name; btn.Size = UDim2.new(0, IsMobile and 68 or 72, 0, 26)
    btn.BackgroundColor3 = T.Surface2; btn.BackgroundTransparency = 1
    btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 56
    btn.LayoutOrder = order; btn.Parent = TabBar; Corner(btn, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.RichText = true
    lbl.Text = icon .. " " .. name; lbl.TextColor3 = T.Text3
    lbl.TextSize = IsMobile and 9 or 10; lbl.Font = Enum.Font.GothamBold
    lbl.ZIndex = 57; lbl.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"; page.Size = UDim2.new(1,0,1,-80)
    page.Position = UDim2.new(0,0,0,80); page.BackgroundTransparency = 1
    page.BorderSizePixel = 0; page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = T.Primary; page.ScrollBarImageTransparency = 0.5
    page.CanvasSize = UDim2.new(0,0,0,0); page.Visible = false; page.ZIndex = 51
    page.Parent = Main; Pad(page, 10, 10, 12, 12)

    local pl = Instance.new("UIListLayout")
    pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 8); pl.Parent = page
    pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, pl.AbsoluteContentSize.Y + 24)
    end)

    tabPages[name] = page
    tabs[name] = {btn = btn, lbl = lbl, page = page}

    local function activate()
        for n, t in pairs(tabs) do
            if n == name then
                Tween(t.btn, {BackgroundTransparency = 0, BackgroundColor3 = T.Surface3}, 0.2):Play()
                Tween(t.lbl, {TextColor3 = T.Text}, 0.2):Play()
                t.page.Visible = true
            else
                Tween(t.btn, {BackgroundTransparency = 1}, 0.2):Play()
                Tween(t.lbl, {TextColor3 = T.Text3}, 0.2):Play()
                t.page.Visible = false
            end
        end
        activeTab = name
        SaveData.activeTab = name; QueueSave()
    end

    btn.MouseButton1Click:Connect(function() Ripple(btn); activate() end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= name then Tween(btn, {BackgroundTransparency = 0.5, BackgroundColor3 = T.Surface2}, 0.15):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then Tween(btn, {BackgroundTransparency = 1}, 0.15):Play() end
    end)

    return page, activate
end

local TrackPage, ActivateTrack = CreateTab("Track", "🎯", 1)
local BrowsePage, ActivateBrowse = CreateTab("Browse", "👥", 2)
local LogPage, ActivateLog = CreateTab("Log", "📋", 3)
local SettingsPage, ActivateSettings = CreateTab("⚙", "⚙", 4)

--// ═══════════════════ UI BUILDER ═════════════════════════════════
local function SectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,14); lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text); lbl.TextColor3 = T.Text4
    lbl.TextSize = IsMobile and 9 or 10; lbl.Font = Enum.Font.GothamBlack
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 52
    lbl.LayoutOrder = order; lbl.Parent = parent
    return lbl
end

local function InputField(parent, placeholder, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,36); frame.BackgroundColor3 = T.Surface
    frame.BorderSizePixel = 0; frame.ZIndex = 52; frame.LayoutOrder = order
    frame.Parent = parent; Corner(frame, 8)
    local st = Stroke(frame, T.Border, 1, 0.4)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-20,1,0); box.Position = UDim2.new(0,10,0,0)
    box.BackgroundTransparency = 1; box.Text = ""; box.PlaceholderText = placeholder
    box.PlaceholderColor3 = T.Text4; box.TextColor3 = T.Text
    box.TextSize = IsMobile and 12 or 13; box.Font = Enum.Font.GothamMedium
    box.TextXAlignment = Enum.TextXAlignment.Left; box.ClearTextOnFocus = false
    box.ClipsDescendants = true; box.ZIndex = 53; box.Parent = frame

    box.Focused:Connect(function() Tween(st, {Color = T.Primary, Transparency = 0}, 0.2):Play() end)
    box.FocusLost:Connect(function() Tween(st, {Color = T.Border, Transparency = 0.4}, 0.2):Play() end)

    return box, frame
end

local function ActionButton(parent, text, icon, color, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36); btn.BackgroundColor3 = color
    btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 52
    btn.LayoutOrder = order; btn.ClipsDescendants = true; btn.Parent = parent; Corner(btn, 8)

    local grad = Instance.new("UIGradient")
    grad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,0.2)}
    grad.Rotation = 135; grad.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.RichText = true
    lbl.Text = icon .. "  " .. text; lbl.TextColor3 = T.Text
    lbl.TextSize = IsMobile and 11 or 12; lbl.Font = Enum.Font.GothamBold
    lbl.ZIndex = 53; lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.new(math.min(1,color.R+0.06), math.min(1,color.G+0.06), math.min(1,color.B+0.06))}, 0.15):Play()
    end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = color}, 0.15):Play() end)
    btn.MouseButton1Click:Connect(function() Ripple(btn) end)
    return btn, lbl
end

local function ToggleSwitch(parent, label, defaultOn, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,32); row.BackgroundColor3 = T.Surface
    row.BorderSizePixel = 0; row.ZIndex = 52; row.LayoutOrder = order
    row.Parent = parent; Corner(row, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = T.Text2; lbl.TextSize = IsMobile and 10 or 11
    lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 53; lbl.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0,36,0,20); track.Position = UDim2.new(1,-46,0.5,-10)
    track.BackgroundColor3 = defaultOn and T.Primary or T.Surface3
    track.Text = ""; track.AutoButtonColor = false; track.ZIndex = 53
    track.Parent = row; Corner(track, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16); knob.Position = defaultOn and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = T.Text; knob.ZIndex = 54; knob.Parent = track; Corner(knob, 8)

    local isOn = defaultOn
    track.MouseButton1Click:Connect(function()
        isOn = not isOn
        Tween(track, {BackgroundColor3 = isOn and T.Primary or T.Surface3}, 0.2):Play()
        Tween(knob, {Position = isOn and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}, 0.2, Enum.EasingStyle.Back):Play()
        if callback then callback(isOn) end
    end)

    return row, function() return isOn end
end

local function InfoCard(parent, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,50); card.BackgroundColor3 = T.Surface
    card.BorderSizePixel = 0; card.ZIndex = 52; card.LayoutOrder = order
    card.Visible = false; card.Parent = parent; Corner(card, 8); Stroke(card, T.Primary, 1, 0.7)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0,34,0,34); avatar.Position = UDim2.new(0,8,0.5,-17)
    avatar.BackgroundColor3 = T.Surface3; avatar.ZIndex = 53; avatar.Parent = card; Corner(avatar, 17)

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1,-55,0,15); nameL.Position = UDim2.new(0,48,0,9)
    nameL.BackgroundTransparency = 1; nameL.Text = "—"; nameL.TextColor3 = T.Text
    nameL.TextSize = IsMobile and 11 or 12; nameL.Font = Enum.Font.GothamBold
    nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 53; nameL.Parent = card

    local statusL = Instance.new("TextLabel")
    statusL.Size = UDim2.new(1,-55,0,11); statusL.Position = UDim2.new(0,48,0,26)
    statusL.BackgroundTransparency = 1; statusL.Text = "—"; statusL.TextColor3 = T.Text3
    statusL.TextSize = IsMobile and 9 or 10; statusL.Font = Enum.Font.GothamMedium
    statusL.TextXAlignment = Enum.TextXAlignment.Left; statusL.ZIndex = 53; statusL.Parent = card

    return card, avatar, nameL, statusL
end

--// ═══════════════════ STATUS BAR ═════════════════════════════════
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1,0,0,22); StatusBar.Position = UDim2.new(0,0,1,-22)
StatusBar.BackgroundColor3 = T.Surface; StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 56; StatusBar.Parent = Main; Corner(StatusBar, 14)

local StatusFix = Instance.new("Frame")
StatusFix.Size = UDim2.new(1,0,0,12); StatusFix.BackgroundColor3 = T.Surface
StatusFix.BorderSizePixel = 0; StatusFix.ZIndex = 56; StatusFix.Parent = StatusBar

local StatusBorderTop = Instance.new("Frame")
StatusBorderTop.Size = UDim2.new(1,0,0,1); StatusBorderTop.BackgroundColor3 = T.Border
StatusBorderTop.BackgroundTransparency = 0.5; StatusBorderTop.BorderSizePixel = 0
StatusBorderTop.ZIndex = 57; StatusBorderTop.Parent = StatusBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0,5,0,5); StatusDot.Position = UDim2.new(0,8,0.5,-2)
StatusDot.BackgroundColor3 = T.Green; StatusDot.ZIndex = 58; StatusDot.Parent = StatusBar; Corner(StatusDot, 3)

local SaveIcon = Instance.new("TextLabel")
SaveIcon.Size = UDim2.new(0,14,1,0); SaveIcon.Position = UDim2.new(1,-50,0,0)
SaveIcon.BackgroundTransparency = 1; SaveIcon.Text = Storage:HasFileSystem() and "💾" or "⚠"
SaveIcon.TextSize = 9; SaveIcon.ZIndex = 58; SaveIcon.Parent = StatusBar

local SaveStatusLbl = Instance.new("TextLabel")
SaveStatusLbl.Size = UDim2.new(0,30,1,0); SaveStatusLbl.Position = UDim2.new(1,-36,0,0)
SaveStatusLbl.BackgroundTransparency = 1
SaveStatusLbl.Text = Storage:HasFileSystem() and "Saved" or "NoFS"
SaveStatusLbl.TextColor3 = Storage:HasFileSystem() and T.Green or T.Yellow
SaveStatusLbl.TextSize = IsMobile and 8 or 9; SaveStatusLbl.Font = Enum.Font.GothamMedium
SaveStatusLbl.ZIndex = 58; SaveStatusLbl.Parent = StatusBar

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1,-70,1,0); StatusLbl.Position = UDim2.new(0,17,0,0)
StatusLbl.BackgroundTransparency = 1; StatusLbl.Text = "Ready"
StatusLbl.TextColor3 = T.Text3; StatusLbl.TextSize = IsMobile and 9 or 10
StatusLbl.Font = Enum.Font.GothamMedium; StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.ZIndex = 58; StatusLbl.Parent = StatusBar

local function SetStatus(txt, col)
    StatusLbl.Text = txt; StatusDot.BackgroundColor3 = col or T.Green
end

local function FlashSave()
    SaveStatusLbl.Text = "Saving…"; SaveStatusLbl.TextColor3 = T.Yellow
    task.delay(0.8, function()
        SaveStatusLbl.Text = "Saved"; SaveStatusLbl.TextColor3 = T.Green
    end)
end

-- Hook save indicator
local origSave = Storage.Save
Storage.Save = function(self, ...)
    local result = origSave(self, ...)
    if result then pcall(FlashSave) end
    return result
end

--// ═══════════════════ TRACK PAGE ═════════════════════════════════
SectionLabel(TrackPage, "Target", 1)
local UserIdBox = InputField(TrackPage, "User ID…", 2)
local TargetCard, TargetAvatar, TargetName, TargetStatus = InfoCard(TrackPage, 3)

SectionLabel(TrackPage, "Authentication", 4)
local CookieBox = InputField(TrackPage, ".ROBLOSECURITY cookie…", 5)

-- Cookie mask toggle
local CookieMaskRow = Instance.new("Frame")
CookieMaskRow.Size = UDim2.new(1,0,0,20); CookieMaskRow.BackgroundTransparency = 1
CookieMaskRow.ZIndex = 52; CookieMaskRow.LayoutOrder = 6; CookieMaskRow.Parent = TrackPage

local CookieMaskInfo = Instance.new("TextLabel")
CookieMaskInfo.Size = UDim2.new(1,-50,1,0)
CookieMaskInfo.BackgroundTransparency = 1; CookieMaskInfo.RichText = true
CookieMaskInfo.Text = '<font color="rgb(60,60,78)">🔒 Stored locally only</font>'
CookieMaskInfo.TextSize = IsMobile and 8 or 9; CookieMaskInfo.Font = Enum.Font.Gotham
CookieMaskInfo.TextXAlignment = Enum.TextXAlignment.Left; CookieMaskInfo.ZIndex = 52
CookieMaskInfo.Parent = CookieMaskRow

local ClearCookieBtn = Instance.new("TextButton")
ClearCookieBtn.Size = UDim2.new(0,44,0,18); ClearCookieBtn.Position = UDim2.new(1,-44,0,0)
ClearCookieBtn.BackgroundColor3 = T.RedDim; ClearCookieBtn.BackgroundTransparency = 0.5
ClearCookieBtn.Text = ""; ClearCookieBtn.AutoButtonColor = false
ClearCookieBtn.ZIndex = 52; ClearCookieBtn.Parent = CookieMaskRow; Corner(ClearCookieBtn, 4)

local ClearCookieLbl = Instance.new("TextLabel")
ClearCookieLbl.Size = UDim2.new(1,0,1,0); ClearCookieLbl.BackgroundTransparency = 1
ClearCookieLbl.Text = "Clear"; ClearCookieLbl.TextColor3 = T.Red
ClearCookieLbl.TextSize = 8; ClearCookieLbl.Font = Enum.Font.GothamBold
ClearCookieLbl.ZIndex = 53; ClearCookieLbl.Parent = ClearCookieBtn

SectionLabel(TrackPage, "Profiles", 7)

-- Profile selector
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1,0,0,32); ProfileFrame.BackgroundColor3 = T.Surface
ProfileFrame.BorderSizePixel = 0; ProfileFrame.ZIndex = 52; ProfileFrame.LayoutOrder = 8
ProfileFrame.Parent = TrackPage; Corner(ProfileFrame, 8)

local ProfileLbl = Instance.new("TextLabel")
ProfileLbl.Size = UDim2.new(0.5,0,1,0); ProfileLbl.Position = UDim2.new(0,10,0,0)
ProfileLbl.BackgroundTransparency = 1; ProfileLbl.Text = "📁 " .. (SaveData.activeProfile or "Default")
ProfileLbl.TextColor3 = T.Text2; ProfileLbl.TextSize = IsMobile and 10 or 11
ProfileLbl.Font = Enum.Font.GothamMedium; ProfileLbl.TextXAlignment = Enum.TextXAlignment.Left
ProfileLbl.ZIndex = 53; ProfileLbl.Parent = ProfileFrame

local SaveProfileBtn = Instance.new("TextButton")
SaveProfileBtn.Size = UDim2.new(0,42,0,22); SaveProfileBtn.Position = UDim2.new(1,-92,0.5,-11)
SaveProfileBtn.BackgroundColor3 = T.Primary; SaveProfileBtn.Text = ""
SaveProfileBtn.AutoButtonColor = false; SaveProfileBtn.ZIndex = 53
SaveProfileBtn.Parent = ProfileFrame; Corner(SaveProfileBtn, 5)

local SavePLbl = Instance.new("TextLabel")
SavePLbl.Size = UDim2.new(1,0,1,0); SavePLbl.BackgroundTransparency = 1
SavePLbl.Text = "Save"; SavePLbl.TextColor3 = T.Text; SavePLbl.TextSize = 9
SavePLbl.Font = Enum.Font.GothamBold; SavePLbl.ZIndex = 54; SavePLbl.Parent = SaveProfileBtn

local LoadProfileBtn = Instance.new("TextButton")
LoadProfileBtn.Size = UDim2.new(0,42,0,22); LoadProfileBtn.Position = UDim2.new(1,-46,0.5,-11)
LoadProfileBtn.BackgroundColor3 = T.Surface3; LoadProfileBtn.Text = ""
LoadProfileBtn.AutoButtonColor = false; LoadProfileBtn.ZIndex = 53
LoadProfileBtn.Parent = ProfileFrame; Corner(LoadProfileBtn, 5)

local LoadPLbl = Instance.new("TextLabel")
LoadPLbl.Size = UDim2.new(1,0,1,0); LoadPLbl.BackgroundTransparency = 1
LoadPLbl.Text = "Load"; LoadPLbl.TextColor3 = T.Text2; LoadPLbl.TextSize = 9
LoadPLbl.Font = Enum.Font.GothamBold; LoadPLbl.ZIndex = 54; LoadPLbl.Parent = LoadProfileBtn

-- Saved profiles list
local ProfileListFrame = Instance.new("Frame")
ProfileListFrame.Size = UDim2.new(1,0,0,0); ProfileListFrame.AutomaticSize = Enum.AutomaticSize.Y
ProfileListFrame.BackgroundTransparency = 1; ProfileListFrame.ZIndex = 52
ProfileListFrame.LayoutOrder = 9; ProfileListFrame.Parent = TrackPage

local ProfileListLayout = Instance.new("UIListLayout")
ProfileListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ProfileListLayout.Padding = UDim.new(0,4)
ProfileListLayout.Parent = ProfileListFrame

SectionLabel(TrackPage, "Actions", 10)
local TrackBtn = ActionButton(TrackPage, "DÒ TÌM", "🔍", T.Primary, 11)
local JoinBtn = ActionButton(TrackPage, "THAM GIA", "🚀", T.Green, 12)
local AutoBtn, AutoBtnLbl = ActionButton(TrackPage, "TỰ ĐỘNG THEO", "⚡", T.Accent, 13)

--// ═══════════════════ BROWSE PAGE ════════════════════════════════
SectionLabel(BrowsePage, "Search Users", 1)
local SearchBox = InputField(BrowsePage, "Username (empty = server list)…", 2)
local SearchBtn = ActionButton(BrowsePage, "TÌM KIẾM", "🔎", T.Blue, 3)

-- Search history
local HistoryFrame = Instance.new("Frame")
HistoryFrame.Size = UDim2.new(1,0,0,0); HistoryFrame.AutomaticSize = Enum.AutomaticSize.Y
HistoryFrame.BackgroundTransparency = 1; HistoryFrame.ZIndex = 52
HistoryFrame.LayoutOrder = 4; HistoryFrame.Parent = BrowsePage

local HistoryLayout = Instance.new("UIListLayout")
HistoryLayout.FillDirection = Enum.FillDirection.Horizontal
HistoryLayout.SortOrder = Enum.SortOrder.LayoutOrder; HistoryLayout.Padding = UDim.new(0,4)
HistoryLayout.Wraps = true; HistoryLayout.Parent = HistoryFrame

local function RefreshHistory()
    for _, c in ipairs(HistoryFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    if SaveData.searchHistory and #SaveData.searchHistory > 0 then
        for idx, term in ipairs(SaveData.searchHistory) do
            if idx > 8 then break end
            local chip = Instance.new("TextButton")
            chip.Size = UDim2.new(0, #term * 7 + 24, 0, 22)
            chip.BackgroundColor3 = T.Surface2; chip.Text = ""
            chip.AutoButtonColor = false; chip.ZIndex = 52
            chip.LayoutOrder = idx; chip.Parent = HistoryFrame; Corner(chip, 11)

            local cLbl = Instance.new("TextLabel")
            cLbl.Size = UDim2.new(1,0,1,0); cLbl.BackgroundTransparency = 1
            cLbl.Text = "🕐 "..term; cLbl.TextColor3 = T.Text3
            cLbl.TextSize = IsMobile and 8 or 9; cLbl.Font = Enum.Font.GothamMedium
            cLbl.ZIndex = 53; cLbl.Parent = chip

            chip.MouseButton1Click:Connect(function()
                SearchBox.Text = term
            end)
            chip.MouseEnter:Connect(function() Tween(chip, {BackgroundColor3 = T.Surface3}, 0.15):Play() end)
            chip.MouseLeave:Connect(function() Tween(chip, {BackgroundColor3 = T.Surface2}, 0.15):Play() end)
        end
    end
end

SectionLabel(BrowsePage, "Results", 5)

local ResultsContainer = Instance.new("Frame")
ResultsContainer.Size = UDim2.new(1,0,0,0); ResultsContainer.AutomaticSize = Enum.AutomaticSize.Y
ResultsContainer.BackgroundTransparency = 1; ResultsContainer.ZIndex = 52
ResultsContainer.LayoutOrder = 6; ResultsContainer.Parent = BrowsePage

local ResultsLayout = Instance.new("UIListLayout")
ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder; ResultsLayout.Padding = UDim.new(0,5)
ResultsLayout.Parent = ResultsContainer

local NoResults = Instance.new("TextLabel")
NoResults.Size = UDim2.new(1,0,0,50); NoResults.BackgroundTransparency = 1
NoResults.Text = "Nhập username hoặc để trống xem server"
NoResults.TextColor3 = T.Text4; NoResults.TextSize = IsMobile and 10 or 11
NoResults.Font = Enum.Font.GothamMedium; NoResults.TextWrapped = true
NoResults.ZIndex = 52; NoResults.LayoutOrder = 0; NoResults.Parent = ResultsContainer

--// ═══════════════════ LOG PAGE ═══════════════════════════════════
local LogContainer = Instance.new("Frame")
LogContainer.Size = UDim2.new(1,0,0,0); LogContainer.AutomaticSize = Enum.AutomaticSize.Y
LogContainer.BackgroundColor3 = T.Surface; LogContainer.BorderSizePixel = 0
LogContainer.ZIndex = 52; LogContainer.LayoutOrder = 1; LogContainer.ClipsDescendants = true
LogContainer.Parent = LogPage; Corner(LogContainer, 8); Pad(LogContainer, 6, 6, 8, 8)

local LogLayout = Instance.new("UIListLayout")
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder; LogLayout.Padding = UDim.new(0, 1)
LogLayout.Parent = LogContainer

local logN = 0
local function Log(text, col)
    logN = logN + 1
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1,0,0,0); entry.AutomaticSize = Enum.AutomaticSize.Y
    entry.BackgroundTransparency = 1; entry.RichText = true
    entry.Text = '<font color="rgb(50,50,65)">'..os.date("%H:%M:%S")..'</font>  '..text
    entry.TextColor3 = col or T.Text2; entry.TextSize = IsMobile and 9 or 10
    entry.Font = Enum.Font.Code; entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextWrapped = true; entry.ZIndex = 53; entry.LayoutOrder = logN
    entry.Parent = LogContainer
    task.defer(function() LogPage.CanvasPosition = Vector2.new(0, 99999) end)
end

local ClearLogBtn = ActionButton(LogPage, "XÓA LOG", "🗑", T.RedDim, 2)
ClearLogBtn.Size = UDim2.new(1,0,0,28)

--// ═══════════════════ SETTINGS PAGE ══════════════════════════════
SectionLabel(SettingsPage, "General", 1)

ToggleSwitch(SettingsPage, "Auto Save", SaveData.settings.autoSave, 2, function(on)
    SaveData.settings.autoSave = on; QueueSave()
    Log(on and "💾 Auto-save enabled" or "💾 Auto-save disabled", T.Text2)
end)

ToggleSwitch(SettingsPage, "Notifications", SaveData.settings.showNotifications, 3, function(on)
    SaveData.settings.showNotifications = on; QueueSave()
end)

ToggleSwitch(SettingsPage, "Save Window Position", SaveData.settings.saveWindowPos, 4, function(on)
    SaveData.settings.saveWindowPos = on; QueueSave()
end)

SectionLabel(SettingsPage, "Data", 5)

local ExportBtn = ActionButton(SettingsPage, "EXPORT DATA", "📤", T.Blue, 6)
local ImportBox = InputField(SettingsPage, "Paste exported data…", 7)
local ImportBtn = ActionButton(SettingsPage, "IMPORT DATA", "📥", T.Orange, 8)

local ResetBtn = ActionButton(SettingsPage, "RESET ALL DATA", "⚠", T.RedDim, 9)

SectionLabel(SettingsPage, "Info", 10)

local InfoLbl = Instance.new("TextLabel")
InfoLbl.Size = UDim2.new(1,0,0,0); InfoLbl.AutomaticSize = Enum.AutomaticSize.Y
InfoLbl.BackgroundTransparency = 1; InfoLbl.RichText = true
InfoLbl.Text = '<font color="rgb(100,100,120)">Stalker Join v3.1\nFile System: '
    ..(Storage:HasFileSystem() and '<font color="rgb(40,200,120)">Available ✓</font>' or '<font color="rgb(240,60,80)">Not Available ✗</font>')
    ..'\nPlatform: '..(IsMobile and "Mobile 📱" or "Desktop 💻")
    ..'\nProfiles: '..tostring(SaveData.profiles and #(function() local n=0; for _ in pairs(SaveData.profiles) do n=n+1 end; return tostring(n) end)() or 0)
    ..'</font>'
InfoLbl.TextSize = IsMobile and 9 or 10; InfoLbl.Font = Enum.Font.Code
InfoLbl.TextXAlignment = Enum.TextXAlignment.Left; InfoLbl.TextWrapped = true
InfoLbl.ZIndex = 52; InfoLbl.LayoutOrder = 11; InfoLbl.Parent = SettingsPage

--// ═══════════════════ CORE LOGIC ═════════════════════════════════
local lastPlace, lastJob = nil, nil
local autoMode = false

local function LookupUserId(userId)
    pcall(function()
        TargetAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=150&height=150&format=png"
    end)
    local ok, res = pcall(function()
        local r = request({Url="https://users.roblox.com/v1/users/"..userId, Method="GET", Headers={["Content-Type"]="application/json"}})
        if r.Success then return HttpService:JSONDecode(r.Body) end
    end)
    if ok and res then
        TargetName.Text = res.displayName or res.name or "?"
        TargetCard.Visible = true
        SaveData.lastUsername = res.name or ""
        QueueSave()
        return res.name
    end
    return nil
end

local function GetPresence(userId, cookie)
    Log("🔍 Querying presence…", T.Blue)
    SetStatus("Scanning…", T.Yellow)

    local ok, resp = pcall(function()
        return request({
            Url = "https://presence.roblox.com/v1/presence/users",
            Method = "POST",
            Headers = {["Content-Type"]="application/json", ["Cookie"]=".ROBLOSECURITY="..cookie},
            Body = HttpService:JSONEncode({userIds = {tonumber(userId)}})
        })
    end)

    if not ok then Log("❌ Request failed", T.Red); SetStatus("Error", T.Red); return nil, nil end

    if resp.Success then
        local data = HttpService:JSONDecode(resp.Body)
        local p = data.userPresences and data.userPresences[1]
        if p then
            local pt = p.userPresenceType
            if pt == 0 then
                Log("⚫ <b>Offline</b>", T.Text3); TargetStatus.Text = "⚫ Offline"; TargetStatus.TextColor3 = T.Text4; SetStatus("Offline", T.Text4)
            elseif pt == 1 then
                Log("🟢 <b>Online</b> (Web)", T.Green); TargetStatus.Text = "🟢 Website"; TargetStatus.TextColor3 = T.Green; SetStatus("Online, not in-game", T.Yellow)
            elseif pt == 2 then
                local gn = p.lastLocation or "Unknown"
                Log("🎮 In: <b>"..gn.."</b>", T.Green)
                Log("   Place: "..tostring(p.placeId).." | Job: "..tostring(p.gameId), T.Cyan)
                TargetStatus.Text = "🎮 "..gn; TargetStatus.TextColor3 = T.Green
                SetStatus("Found! Ready", T.Green)
                lastPlace = p.placeId; lastJob = p.gameId
                Notify("🎮 Target found in: "..gn, T.Green, 4)
                return p.placeId, p.gameId
            elseif pt == 3 then
                Log("🎬 <b>Studio</b>", T.Yellow); TargetStatus.Text = "🎬 Studio"; TargetStatus.TextColor3 = T.Yellow; SetStatus("In Studio", T.Yellow)
            end
        end
    else
        Log("❌ API "..tostring(resp.StatusCode), T.Red)
        if resp.StatusCode == 401 then Log("🔒 Cookie invalid", T.Red); SetStatus("Auth fail", T.Red) end
    end
    return nil, nil
end

local function DoJoin()
    if lastPlace and lastJob then
        Log("🚀 Teleporting…", T.Green); SetStatus("Teleporting…", T.Primary)
        Notify("🚀 Joining target server…", T.Green, 3)
        local ok = pcall(function() TeleportService:TeleportToPlaceInstance(lastPlace, lastJob, LocalPlayer) end)
        if not ok then
            Log("⚠ Fallback to PlaceId", T.Yellow)
            pcall(function() TeleportService:Teleport(lastPlace, LocalPlayer) end)
        end
    else
        Log("⚠ Track first!", T.Yellow); SetStatus("No data", T.Yellow)
    end
end

--// ═══════════════════ BROWSE LOGIC ═══════════════════════════════
local function ClearResults()
    for _, c in ipairs(ResultsContainer:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
end

local function CreateUserCard(parent, userData, presenceInfo, idx)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,48); card.BackgroundColor3 = T.Surface
    card.BorderSizePixel = 0; card.ZIndex = 52; card.LayoutOrder = idx
    card.Parent = parent; Corner(card, 8); Stroke(card, T.Border, 1, 0.7)

    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0,30,0,30); av.Position = UDim2.new(0,8,0.5,-15)
    av.BackgroundColor3 = T.Surface3; av.ZIndex = 53; av.Parent = card; Corner(av, 15)
    pcall(function() av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..userData.id.."&width=150&height=150&format=png" end)

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(0.55,-48,0,13); nm.Position = UDim2.new(0,44,0,8)
    nm.BackgroundTransparency = 1; nm.Text = userData.displayName or userData.name
    nm.TextColor3 = T.Text; nm.TextSize = IsMobile and 10 or 11
    nm.Font = Enum.Font.GothamBold; nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.TextTruncate = Enum.TextTruncate.AtEnd
    nm.ZIndex = 53; nm.Parent = card

    local un = Instance.new("TextLabel")
    un.Size = UDim2.new(0.55,-48,0,10); un.Position = UDim2.new(0,44,0,23)
    un.BackgroundTransparency = 1; un.Text = "@"..(userData.name or "").." • "..userData.id
    un.TextColor3 = T.Text4; un.TextSize = IsMobile and 7 or 8
    un.Font = Enum.Font.Gotham; un.TextXAlignment = Enum.TextXAlignment.Left
    un.TextTruncate = Enum.TextTruncate.AtEnd
    un.ZIndex = 53; un.Parent = card

    local inGame = presenceInfo and presenceInfo.userPresenceType == 2 and presenceInfo.placeId and presenceInfo.gameId

    if inGame then
        local jb = Instance.new("TextButton")
        jb.Size = UDim2.new(0,44,0,22); jb.Position = UDim2.new(1,-52,0.5,-11)
        jb.BackgroundColor3 = T.Green; jb.Text = ""; jb.AutoButtonColor = false
        jb.ZIndex = 54; jb.ClipsDescendants = true; jb.Parent = card; Corner(jb, 6)

        local jLbl = Instance.new("TextLabel")
        jLbl.Size = UDim2.new(1,0,1,0); jLbl.BackgroundTransparency = 1
        jLbl.Text = "JOIN"; jLbl.TextColor3 = T.Text; jLbl.TextSize = IsMobile and 8 or 9
        jLbl.Font = Enum.Font.GothamBlack; jLbl.ZIndex = 55; jLbl.Parent = jb

        jb.MouseButton1Click:Connect(function()
            Ripple(jb); lastPlace = presenceInfo.placeId; lastJob = presenceInfo.gameId
            Log("🚀 Joining <b>"..(userData.name or "").."</b>…", T.Green); DoJoin()
        end)
    else
        local tb = Instance.new("TextButton")
        tb.Size = UDim2.new(0,44,0,22); tb.Position = UDim2.new(1,-52,0.5,-11)
        tb.BackgroundColor3 = T.Surface3; tb.Text = ""; tb.AutoButtonColor = false
        tb.ZIndex = 54; tb.ClipsDescendants = true; tb.Parent = card; Corner(tb, 6)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1,0,1,0); tLbl.BackgroundTransparency = 1
        tLbl.Text = "TRACK"; tLbl.TextColor3 = T.Text2; tLbl.TextSize = IsMobile and 8 or 9
        tLbl.Font = Enum.Font.GothamBold; tLbl.ZIndex = 55; tLbl.Parent = tb

        tb.MouseButton1Click:Connect(function()
            Ripple(tb); UserIdBox.Text = tostring(userData.id)
            SaveData.lastUserId = tostring(userData.id); QueueSave()
            LookupUserId(userData.id); ActivateTrack()
            Log("🎯 → <b>"..(userData.name or "").."</b>", T.Primary)
        end)
    end

    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = T.Surface2}, 0.12):Play() end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = T.Surface}, 0.12):Play() end)
end

local function SearchUsers(keyword)
    ClearResults(); NoResults.Visible = false
    Log("👥 Search: <b>"..keyword.."</b>", T.Blue); SetStatus("Searching…", T.Blue)

    -- Save to history
    if not SaveData.searchHistory then SaveData.searchHistory = {} end
    for i, v in ipairs(SaveData.searchHistory) do if v == keyword then table.remove(SaveData.searchHistory, i); break end end
    table.insert(SaveData.searchHistory, 1, keyword)
    if #SaveData.searchHistory > 8 then table.remove(SaveData.searchHistory) end
    QueueSave(); RefreshHistory()

    local ok, resp = pcall(function()
        return request({
            Url = "https://users.roblox.com/v1/users/search?keyword="..HttpService:UrlEncode(keyword).."&limit=10",
            Method = "GET", Headers = {["Content-Type"]="application/json"}
        })
    end)

    if ok and resp.Success then
        local data = HttpService:JSONDecode(resp.Body)
        local users = data.data
        if users and #users > 0 then
            Log("✅ <b>"..#users.."</b> found", T.Green); SetStatus(#users.." results", T.Green)

            local cookie = CookieBox.Text
            local presenceData = {}
            if cookie ~= "" then
                local uids = {}; for _, u in ipairs(users) do table.insert(uids, u.id) end
                local pOk, pResp = pcall(function()
                    return request({
                        Url = "https://presence.roblox.com/v1/presence/users",
                        Method = "POST",
                        Headers = {["Content-Type"]="application/json", ["Cookie"]=".ROBLOSECURITY="..cookie},
                        Body = HttpService:JSONEncode({userIds = uids})
                    })
                end)
                if pOk and pResp.Success then
                    local pd = HttpService:JSONDecode(pResp.Body)
                    if pd.userPresences then for _, pr in ipairs(pd.userPresences) do presenceData[pr.userId] = pr end end
                end
            end

            for idx, u in ipairs(users) do
                CreateUserCard(ResultsContainer, u, presenceData[u.id], idx)
            end
        else
            NoResults.Text = "Không tìm thấy"; NoResults.Visible = true
        end
    else
        NoResults.Text = "Search error"; NoResults.Visible = true; Log("❌ Search failed", T.Red)
    end
end

local function BrowseServer()
    ClearResults(); NoResults.Visible = false
    Log("👥 Server players…", T.Blue)
    local cookie = CookieBox.Text
    local pList = {}; local uids = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(uids, p.UserId)
            pList[p.UserId] = {id = p.UserId, name = p.Name, displayName = p.DisplayName}
        end
    end
    if #uids == 0 then NoResults.Text = "Empty server"; NoResults.Visible = true; return end

    local presenceData = {}
    if cookie ~= "" then
        pcall(function()
            local r = request({
                Url = "https://presence.roblox.com/v1/presence/users", Method = "POST",
                Headers = {["Content-Type"]="application/json", ["Cookie"]=".ROBLOSECURITY="..cookie},
                Body = HttpService:JSONEncode({userIds = uids})
            })
            if r.Success then
                local pd = HttpService:JSONDecode(r.Body)
                if pd.userPresences then for _, pr in ipairs(pd.userPresences) do presenceData[pr.userId] = pr end end
            end
        end)
    end

    for idx, uid in ipairs(uids) do
        CreateUserCard(ResultsContainer, pList[uid], presenceData[uid], idx)
    end
    SetStatus(#uids.." players", T.Green)
end

--// ═══════════════════ PROFILE SYSTEM ═════════════════════════════
local function RefreshProfiles()
    for _, c in ipairs(ProfileListFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    if not SaveData.profiles then SaveData.profiles = {} end

    local idx = 0
    for name, data in pairs(SaveData.profiles) do
        idx = idx + 1
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,30); row.BackgroundColor3 = T.Surface
        row.BorderSizePixel = 0; row.ZIndex = 52; row.LayoutOrder = idx
        row.Parent = ProfileListFrame; Corner(row, 6)

        local pName = Instance.new("TextLabel")
        pName.Size = UDim2.new(1,-80,1,0); pName.Position = UDim2.new(0,10,0,0)
        pName.BackgroundTransparency = 1
        pName.Text = "📁 "..name.." → "..(data.userId or "?")
        pName.TextColor3 = T.Text2; pName.TextSize = IsMobile and 9 or 10
        pName.Font = Enum.Font.GothamMedium; pName.TextXAlignment = Enum.TextXAlignment.Left
        pName.TextTruncate = Enum.TextTruncate.AtEnd
        pName.ZIndex = 53; pName.Parent = row

        local useBtn = Instance.new("TextButton")
        useBtn.Size = UDim2.new(0,32,0,20); useBtn.Position = UDim2.new(1,-72,0.5,-10)
        useBtn.BackgroundColor3 = T.Primary; useBtn.Text = ""
        useBtn.AutoButtonColor = false; useBtn.ZIndex = 53; useBtn.Parent = row; Corner(useBtn, 5)

        local uLbl = Instance.new("TextLabel")
        uLbl.Size = UDim2.new(1,0,1,0); uLbl.BackgroundTransparency = 1
        uLbl.Text = "Use"; uLbl.TextColor3 = T.Text; uLbl.TextSize = 8
        uLbl.Font = Enum.Font.GothamBold; uLbl.ZIndex = 54; uLbl.Parent = useBtn

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0,28,0,20); delBtn.Position = UDim2.new(1,-36,0.5,-10)
        delBtn.BackgroundColor3 = T.RedDim; delBtn.BackgroundTransparency = 0.5
        delBtn.Text = ""; delBtn.AutoButtonColor = false; delBtn.ZIndex = 53
        delBtn.Parent = row; Corner(delBtn, 5)

        local dLbl = Instance.new("TextLabel")
        dLbl.Size = UDim2.new(1,0,1,0); dLbl.BackgroundTransparency = 1
        dLbl.Text = "✕"; dLbl.TextColor3 = T.Red; dLbl.TextSize = 10
        dLbl.Font = Enum.Font.GothamBold; dLbl.ZIndex = 54; dLbl.Parent = delBtn

        useBtn.MouseButton1Click:Connect(function()
            Ripple(useBtn)
            UserIdBox.Text = data.userId or ""
            CookieBox.Text = data.cookie or ""
            SaveData.lastUserId = data.userId or ""
            SaveData.cookie = data.cookie or ""
            SaveData.activeProfile = name
            ProfileLbl.Text = "📁 "..name
            QueueSave()
            if data.userId and data.userId ~= "" then LookupUserId(tonumber(data.userId)) end
            Log("📁 Loaded profile: <b>"..name.."</b>", T.Primary)
            Notify("📁 Profile loaded: "..name, T.Primary)
        end)

        delBtn.MouseButton1Click:Connect(function()
            Ripple(delBtn)
            SaveData.profiles[name] = nil; QueueSave()
            RefreshProfiles()
            Log("🗑 Deleted profile: <b>"..name.."</b>", T.Red)
        end)

        row.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = T.Surface2}, 0.12):Play() end)
        row.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = T.Surface}, 0.12):Play() end)
    end
end

--// ═══════════════════ BUTTON CONNECTIONS ═════════════════════════
-- Auto save on input change
UserIdBox.FocusLost:Connect(function()
    local id = UserIdBox.Text
    SaveData.lastUserId = id; QueueSave()
    if id ~= "" and tonumber(id) then LookupUserId(tonumber(id)) else TargetCard.Visible = false end
end)

CookieBox.FocusLost:Connect(function()
    SaveData.cookie = CookieBox.Text; QueueSave()
    Log("💾 Cookie saved", T.Text3)
end)

ClearCookieBtn.MouseButton1Click:Connect(function()
    CookieBox.Text = ""; SaveData.cookie = ""; QueueSave()
    Log("🗑 Cookie cleared", T.Red)
    Notify("Cookie cleared", T.Red, 2)
end)

TrackBtn.MouseButton1Click:Connect(function()
    local uid = UserIdBox.Text; local ck = CookieBox.Text
    if uid == "" or not tonumber(uid) then Log("⚠ Valid User ID needed", T.Yellow); return end
    if ck == "" then Log("⚠ Cookie needed", T.Yellow); return end
    LookupUserId(tonumber(uid)); GetPresence(tonumber(uid), ck)
end)

JoinBtn.MouseButton1Click:Connect(function()
    if not lastPlace then Log("⚠ Track first!", T.Yellow); return end
    DoJoin()
end)

AutoBtn.MouseButton1Click:Connect(function()
    autoMode = not autoMode
    if autoMode then
        Log("⚡ Auto-track <b>ON</b>", T.Accent); SetStatus("Auto…", T.Accent)
        AutoBtnLbl.Text = "⏹  DỪNG THEO DÕI"
        spawn(function()
            while autoMode do
                local uid = UserIdBox.Text; local ck = CookieBox.Text
                if uid ~= "" and ck ~= "" and tonumber(uid) then
                    local p, j = GetPresence(tonumber(uid), ck)
                    if p and j then
                        Log("✅ Found! Auto-join…", T.Green)
                        task.wait(1.5); DoJoin(); autoMode = false; break
                    end
                end
                for i = SaveData.autoTrackInterval, 1, -1 do
                    if not autoMode then break end
                    SetStatus("Retry "..i.."s…", T.Accent); task.wait(1)
                end
            end
            AutoBtnLbl.Text = "⚡  TỰ ĐỘNG THEO"
            if not autoMode then SetStatus("Ready", T.Green) end
        end)
    else
        autoMode = false
        AutoBtnLbl.Text = "⚡  TỰ ĐỘNG THEO"
        Log("⏹ Auto <b>OFF</b>", T.Text3); SetStatus("Ready", T.Green)
    end
end)

SearchBtn.MouseButton1Click:Connect(function()
    local kw = SearchBox.Text
    if kw == "" then BrowseServer() else SearchUsers(kw) end
end)

-- Profile buttons
SaveProfileBtn.MouseButton1Click:Connect(function()
    Ripple(SaveProfileBtn)
    local uid = UserIdBox.Text
    if uid == "" then Log("⚠ Enter User ID first", T.Yellow); return end
    local profileName = SaveData.lastUsername ~= "" and SaveData.lastUsername or ("User_"..uid)
    if not SaveData.profiles then SaveData.profiles = {} end
    SaveData.profiles[profileName] = {
        userId = uid,
        cookie = CookieBox.Text,
        savedAt = os.date("%Y-%m-%d %H:%M")
    }
    SaveData.activeProfile = profileName
    ProfileLbl.Text = "📁 "..profileName
    QueueSave(); RefreshProfiles()
    Log("💾 Saved profile: <b>"..profileName.."</b>", T.Green)
    Notify("💾 Profile saved: "..profileName, T.Green)
end)

LoadProfileBtn.MouseButton1Click:Connect(function()
    Ripple(LoadProfileBtn); RefreshProfiles()
    Log("📁 Refreshed profile list", T.Text2)
end)

ClearLogBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(LogContainer:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    logN = 0; Log("Log cleared", T.Text3)
end)

-- Settings buttons
ExportBtn.MouseButton1Click:Connect(function()
    Ripple(ExportBtn)
    local exportData = HttpService:JSONEncode(SaveData)
    if setclipboard then
        setclipboard(exportData)
        Log("📤 Data copied to clipboard!", T.Green)
        Notify("📤 Data exported to clipboard", T.Green)
    else
        Log("📤 Export not supported (no clipboard)", T.Yellow)
    end
end)

ImportBtn.MouseButton1Click:Connect(function()
    Ripple(ImportBtn)
    local raw = ImportBox.Text
    if raw == "" then Log("⚠ Paste data first", T.Yellow); return end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok and data then
        for k, v in pairs(data) do SaveData[k] = v end
        WriteSaveData()
        -- Apply loaded data
        UserIdBox.Text = SaveData.lastUserId or ""
        CookieBox.Text = SaveData.cookie or ""
        if SaveData.lastUserId and SaveData.lastUserId ~= "" and tonumber(SaveData.lastUserId) then
            LookupUserId(tonumber(SaveData.lastUserId))
        end
        RefreshProfiles(); RefreshHistory()
        Log("📥 Data imported!", T.Green)
        Notify("📥 Data imported successfully", T.Green)
    else
        Log("❌ Invalid import data", T.Red)
    end
end)

ResetBtn.MouseButton1Click:Connect(function()
    Ripple(ResetBtn)
    Storage:Delete(SAVE_FILE)
    SaveData = {
        cookie = "", lastUserId = "", lastUsername = "",
        windowPos = {x=0.5, y=0.5}, fabPos = {x=12, y=0.45},
        activeTab = "Track", autoTrackInterval = 12,
        profiles = {}, activeProfile = "Default",
        searchHistory = {}, settings = {autoSave=true, showNotifications=true, compactMode=false, saveWindowPos=true}
    }
    UserIdBox.Text = ""; CookieBox.Text = ""
    TargetCard.Visible = false; RefreshProfiles(); RefreshHistory()
    Log("⚠ All data reset!", T.Red)
    Notify("⚠ All data has been reset", T.Red)
end)

--// ═══════════════════ OPEN / CLOSE ═══════════════════════════════
local isOpen = false

local function Open()
    isOpen = true; Main.Visible = true
    Main.Size = UDim2.new(0, W, 0, 0); Main.BackgroundTransparency = 0.3
    Tween(Main, {Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
    Tween(Fab, {Position = UDim2.new(0, -50, Fab.Position.Y.Scale, Fab.Position.Y.Offset)}, 0.25):Play()
end

local function Close()
    isOpen = false; autoMode = false
    AutoBtnLbl.Text = "⚡  TỰ ĐỘNG THEO"
    local tw = Tween(Main, {Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 0.3}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tw:Play(); tw.Completed:Connect(function() if not isOpen then Main.Visible = false end end)
    Tween(Fab, {Position = UDim2.new(0, 12, Fab.Position.Y.Scale, Fab.Position.Y.Offset)}, 0.25):Play()
end

Fab.MouseButton1Click:Connect(function() Ripple(Fab); if isOpen then Close() else Open() end end)
CloseBtn.MouseButton1Click:Connect(function() Close() end)
MinBtn.MouseButton1Click:Connect(function() Close() end)

--// ═══════════════════ RESTORE SAVED STATE ════════════════════════
task.defer(function()
    -- Restore inputs
    if SaveData.lastUserId and SaveData.lastUserId ~= "" then
        UserIdBox.Text = SaveData.lastUserId
        if tonumber(SaveData.lastUserId) then
            LookupUserId(tonumber(SaveData.lastUserId))
        end
    end

    if SaveData.cookie and SaveData.cookie ~= "" then
        CookieBox.Text = SaveData.cookie
    end

    -- Restore active tab
    if SaveData.activeTab then
        local tabActivators = {Track = ActivateTrack, Browse = ActivateBrowse, Log = ActivateLog, ["⚙"] = ActivateSettings}
        if tabActivators[SaveData.activeTab] then
            tabActivators[SaveData.activeTab]()
        end
    end

    -- Restore profiles & history
    RefreshProfiles()
    RefreshHistory()

    -- Update profile label
    if SaveData.activeProfile then
        ProfileLbl.Text = "📁 " .. SaveData.activeProfile
    end

    if Storage:HasFileSystem() then
        Log("💾 Data restored from file", T.Green)
        Notify("💾 Previous session restored", T.Green, 3)
    else
        Log("⚠ No filesystem — data won't persist", T.Yellow)
    end
end)

--// ═══════════════════ INIT LOGS ═════════════════════════════════
Log("⌘ <b>Stalker Join v3.1</b>", T.Primary)
Log("Platform: "..(IsMobile and "📱" or "💻").." | FS: "..(Storage:HasFileSystem() and "✓" or "✗"), T.Text3)
Log("──────────────────────────", T.Text4)

print("[Stalker v3.1] Loaded with persistent storage!")