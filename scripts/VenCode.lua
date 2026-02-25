--[[
    SMART TOGGLE SYSTEM v3.0
    Compact Mobile UI - Apple/Material Design
    Works on Mobile Executors
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isLooping = false
local userCode = ""
local loopDelay = 0.5

-- Theme
local T = {
    Bg = Color3.fromRGB(255,255,255),
    Bg2 = Color3.fromRGB(245,245,247),
    Bg3 = Color3.fromRGB(238,238,240),
    Tx1 = Color3.fromRGB(28,28,30),
    Tx2 = Color3.fromRGB(99,99,102),
    Tx3 = Color3.fromRGB(142,142,147),
    TxW = Color3.fromRGB(255,255,255),
    Blue = Color3.fromRGB(0,122,255),
    Green = Color3.fromRGB(52,199,89),
    Red = Color3.fromRGB(255,59,48),
    Border = Color3.fromRGB(225,225,228),
    CodeBg = Color3.fromRGB(30,30,32),
    CodeTx = Color3.fromRGB(212,212,216),
    SwitchOff = Color3.fromRGB(220,220,224),
}

local function tw(obj, props, dur, style)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Cleanup old
if PlayerGui:FindFirstChild("SmartToggle") then
    PlayerGui.SmartToggle:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "SmartToggle"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local viewport = workspace.CurrentCamera.ViewportSize

-- ==========================================
-- TOAST
-- ==========================================
local Toast = Instance.new("Frame")
Toast.AnchorPoint = Vector2.new(0.5,0)
Toast.Position = UDim2.new(0.5,0,0,-44)
Toast.Size = UDim2.new(0,200,0,34)
Toast.BackgroundColor3 = T.CodeBg
Toast.BorderSizePixel = 0
Toast.ZIndex = 100
Toast.Parent = Gui
Instance.new("UICorner",Toast).CornerRadius = UDim.new(0,17)

local ToastTx = Instance.new("TextLabel")
ToastTx.Size = UDim2.new(1,-16,1,0)
ToastTx.Position = UDim2.new(0,8,0,0)
ToastTx.BackgroundTransparency = 1
ToastTx.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
ToastTx.TextSize = 12
ToastTx.TextColor3 = T.TxW
ToastTx.TextTruncate = Enum.TextTruncate.AtEnd
ToastTx.ZIndex = 101
ToastTx.Parent = Toast

local function toast(msg, dur)
    ToastTx.Text = msg
    Toast.Size = UDim2.new(0, math.min(#msg*7+32, viewport.X-40), 0, 34)
    tw(Toast, {Position=UDim2.new(0.5,0,0,50)}, 0.35, Enum.EasingStyle.Back)
    task.delay(dur or 2, function()
        tw(Toast, {Position=UDim2.new(0.5,0,0,-44)}, 0.3)
    end)
end

-- ==========================================
-- EDITOR (compact, chiếm 70% màn hình)
-- ==========================================
local Backdrop = Instance.new("TextButton")
Backdrop.Size = UDim2.new(1,0,1,0)
Backdrop.BackgroundColor3 = Color3.new(0,0,0)
Backdrop.BackgroundTransparency = 1
Backdrop.Text = ""
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 10
Backdrop.AutoButtonColor = false
Backdrop.Visible = false
Backdrop.Parent = Gui

local edW = math.min(viewport.X - 32, 320)
local edH = math.min(viewport.Y * 0.55, 340)

local Editor = Instance.new("Frame")
Editor.Name = "Editor"
Editor.AnchorPoint = Vector2.new(0.5,0.5)
Editor.Position = UDim2.new(0.5,0,0.5,0)
Editor.Size = UDim2.new(0,edW,0,edH)
Editor.BackgroundColor3 = T.Bg
Editor.BorderSizePixel = 0
Editor.ZIndex = 11
Editor.Visible = false
Editor.Parent = Gui
Instance.new("UICorner",Editor).CornerRadius = UDim.new(0,16)

local edStroke = Instance.new("UIStroke")
edStroke.Color = T.Border
edStroke.Thickness = 1
edStroke.Transparency = 0.3
edStroke.Parent = Editor

-- Header 40px
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundTransparency = 1
Header.ZIndex = 12
Header.Parent = Editor

local Title = Instance.new("TextLabel")
Title.Position = UDim2.new(0,14,0,0)
Title.Size = UDim2.new(1,-80,1,0)
Title.BackgroundTransparency = 1
Title.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold)
Title.TextSize = 15
Title.TextColor3 = T.Tx1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Code Editor"
Title.ZIndex = 13
Title.Parent = Header

-- Close X
local CloseBtn = Instance.new("TextButton")
CloseBtn.AnchorPoint = Vector2.new(1,0.5)
CloseBtn.Position = UDim2.new(1,-8,0.5,0)
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.BackgroundColor3 = T.Bg3
CloseBtn.BorderSizePixel = 0
CloseBtn.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = T.Tx2
CloseBtn.Text = "✕"
CloseBtn.ZIndex = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,14)

-- Divider
local Div = Instance.new("Frame")
Div.Position = UDim2.new(0,12,1,-1)
Div.Size = UDim2.new(1,-24,0,1)
Div.BackgroundColor3 = T.Border
Div.BackgroundTransparency = 0.3
Div.BorderSizePixel = 0
Div.ZIndex = 12
Div.Parent = Header

-- Code Area
local CodeWrap = Instance.new("Frame")
CodeWrap.Position = UDim2.new(0,12,0,46)
CodeWrap.Size = UDim2.new(1,-24,1,-120)
CodeWrap.BackgroundColor3 = T.CodeBg
CodeWrap.BorderSizePixel = 0
CodeWrap.ClipsDescendants = true
CodeWrap.ZIndex = 12
CodeWrap.Parent = Editor
Instance.new("UICorner",CodeWrap).CornerRadius = UDim.new(0,10)

local codeStroke = Instance.new("UIStroke")
codeStroke.Color = Color3.fromRGB(55,55,60)
codeStroke.Thickness = 1
codeStroke.Parent = CodeWrap

local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Size = UDim2.new(1,0,1,0)
CodeScroll.BackgroundTransparency = 1
CodeScroll.BorderSizePixel = 0
CodeScroll.ScrollBarThickness = 2
CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,85)
CodeScroll.CanvasSize = UDim2.new(0,0,0,0)
CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CodeScroll.ZIndex = 13
CodeScroll.Parent = CodeWrap

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(1,0,0,0)
CodeInput.AutomaticSize = Enum.AutomaticSize.Y
CodeInput.BackgroundTransparency = 1
CodeInput.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json",Enum.FontWeight.Regular)
CodeInput.TextSize = 12
CodeInput.TextColor3 = T.CodeTx
CodeInput.PlaceholderText = "-- paste code here"
CodeInput.PlaceholderColor3 = Color3.fromRGB(75,75,80)
CodeInput.Text = ""
CodeInput.TextXAlignment = Enum.TextXAlignment.Left
CodeInput.TextYAlignment = Enum.TextYAlignment.Top
CodeInput.ClearTextOnFocus = false
CodeInput.MultiLine = true
CodeInput.TextWrapped = true
CodeInput.ZIndex = 14
CodeInput.Parent = CodeScroll

local codePad = Instance.new("UIPadding")
codePad.PaddingLeft = UDim.new(0,10)
codePad.PaddingRight = UDim.new(0,10)
codePad.PaddingTop = UDim.new(0,8)
codePad.PaddingBottom = UDim.new(0,8)
codePad.Parent = CodeInput

-- Bottom Controls
local BotArea = Instance.new("Frame")
BotArea.Position = UDim2.new(0,0,1,-68)
BotArea.Size = UDim2.new(1,0,0,68)
BotArea.BackgroundTransparency = 1
BotArea.ZIndex = 12
BotArea.Parent = Editor

-- Delay row
local DelayRow = Instance.new("Frame")
DelayRow.Position = UDim2.new(0,12,0,0)
DelayRow.Size = UDim2.new(1,-24,0,28)
DelayRow.BackgroundTransparency = 1
DelayRow.ZIndex = 12
DelayRow.Parent = BotArea

local DelayLbl = Instance.new("TextLabel")
DelayLbl.Size = UDim2.new(0.6,0,1,0)
DelayLbl.BackgroundTransparency = 1
DelayLbl.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
DelayLbl.TextSize = 12
DelayLbl.TextColor3 = T.Tx2
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left
DelayLbl.Text = "Loop delay (sec)"
DelayLbl.ZIndex = 13
DelayLbl.Parent = DelayRow

local DelayBox = Instance.new("Frame")
DelayBox.AnchorPoint = Vector2.new(1,0.5)
DelayBox.Position = UDim2.new(1,0,0.5,0)
DelayBox.Size = UDim2.new(0,56,0,26)
DelayBox.BackgroundColor3 = T.Bg2
DelayBox.BorderSizePixel = 0
DelayBox.ZIndex = 13
DelayBox.Parent = DelayRow
Instance.new("UICorner",DelayBox).CornerRadius = UDim.new(0,6)

local DelayIn = Instance.new("TextBox")
DelayIn.Size = UDim2.new(1,0,1,0)
DelayIn.BackgroundTransparency = 1
DelayIn.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json",Enum.FontWeight.Medium)
DelayIn.TextSize = 12
DelayIn.TextColor3 = T.Tx1
DelayIn.Text = "0.5"
DelayIn.ClearTextOnFocus = true
DelayIn.ZIndex = 14
DelayIn.Parent = DelayBox

-- Buttons row
local BtnRow = Instance.new("Frame")
BtnRow.Position = UDim2.new(0,12,0,32)
BtnRow.Size = UDim2.new(1,-24,0,32)
BtnRow.BackgroundTransparency = 1
BtnRow.ZIndex = 12
BtnRow.Parent = BotArea

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
BtnLayout.Padding = UDim.new(0,8)
BtnLayout.Parent = BtnRow

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0,70,0,30)
RunBtn.BackgroundColor3 = T.Bg2
RunBtn.BorderSizePixel = 0
RunBtn.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
RunBtn.TextSize = 12
RunBtn.TextColor3 = T.Tx1
RunBtn.Text = "Run Once"
RunBtn.ZIndex = 13
RunBtn.AutoButtonColor = false
RunBtn.LayoutOrder = 1
RunBtn.Parent = BtnRow
Instance.new("UICorner",RunBtn).CornerRadius = UDim.new(0,8)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0,90,0,30)
SaveBtn.BackgroundColor3 = T.Blue
SaveBtn.BorderSizePixel = 0
SaveBtn.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold)
SaveBtn.TextSize = 12
SaveBtn.TextColor3 = T.TxW
SaveBtn.Text = "Create Toggle"
SaveBtn.ZIndex = 13
SaveBtn.AutoButtonColor = false
SaveBtn.LayoutOrder = 2
SaveBtn.Parent = BtnRow
Instance.new("UICorner",SaveBtn).CornerRadius = UDim.new(0,8)

-- ==========================================
-- FLOATING PILL TOGGLE (compact)
-- ==========================================
local Pill = Instance.new("Frame")
Pill.Name = "Pill"
Pill.AnchorPoint = Vector2.new(0.5,0.5)
Pill.Position = UDim2.new(0.5,0,0.9,0)
Pill.Size = UDim2.new(0,152,0,38)
Pill.BackgroundColor3 = T.Bg
Pill.BorderSizePixel = 0
Pill.ZIndex = 5
Pill.Visible = false
Pill.Parent = Gui
Instance.new("UICorner",Pill).CornerRadius = UDim.new(0,19)

local pillStroke = Instance.new("UIStroke")
pillStroke.Color = T.Border
pillStroke.Thickness = 1
pillStroke.Transparency = 0.15
pillStroke.Parent = Pill

local PillInner = Instance.new("Frame")
PillInner.Size = UDim2.new(1,0,1,0)
PillInner.BackgroundTransparency = 1
PillInner.ZIndex = 6
PillInner.Parent = Pill

local pillPad = Instance.new("UIPadding")
pillPad.PaddingLeft = UDim.new(0,10)
pillPad.PaddingRight = UDim.new(0,6)
pillPad.Parent = PillInner

local PillLayout = Instance.new("UIListLayout")
PillLayout.FillDirection = Enum.FillDirection.Horizontal
PillLayout.VerticalAlignment = Enum.VerticalAlignment.Center
PillLayout.Padding = UDim.new(0,8)
PillLayout.Parent = PillInner

-- Dot
local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0,7,0,7)
Dot.BackgroundColor3 = T.Tx3
Dot.BorderSizePixel = 0
Dot.ZIndex = 7
Dot.LayoutOrder = 1
Dot.Parent = PillInner
Instance.new("UICorner",Dot).CornerRadius = UDim.new(0,9)

-- Label
local PillLabel = Instance.new("TextLabel")
PillLabel.Size = UDim2.new(0,38,0,18)
PillLabel.BackgroundTransparency = 1
PillLabel.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
PillLabel.TextSize = 12
PillLabel.TextColor3 = T.Tx2
PillLabel.Text = "Loop"
PillLabel.TextXAlignment = Enum.TextXAlignment.Left
PillLabel.ZIndex = 7
PillLabel.LayoutOrder = 2
PillLabel.Parent = PillInner

-- iOS Switch
local Switch = Instance.new("Frame")
Switch.Size = UDim2.new(0,40,0,24)
Switch.BackgroundColor3 = T.SwitchOff
Switch.BorderSizePixel = 0
Switch.ZIndex = 7
Switch.LayoutOrder = 3
Switch.Parent = PillInner
Instance.new("UICorner",Switch).CornerRadius = UDim.new(0,12)

local Knob = Instance.new("Frame")
Knob.AnchorPoint = Vector2.new(0,0.5)
Knob.Position = UDim2.new(0,2,0.5,0)
Knob.Size = UDim2.new(0,20,0,20)
Knob.BackgroundColor3 = T.TxW
Knob.BorderSizePixel = 0
Knob.ZIndex = 8
Knob.Parent = Switch
Instance.new("UICorner",Knob).CornerRadius = UDim.new(0,10)

local SwitchHit = Instance.new("TextButton")
SwitchHit.Size = UDim2.new(1,8,1,8)
SwitchHit.Position = UDim2.new(0,-4,0,-4)
SwitchHit.BackgroundTransparency = 1
SwitchHit.Text = ""
SwitchHit.ZIndex = 9
SwitchHit.Parent = Switch

-- Edit btn
local EditBtn = Instance.new("TextButton")
EditBtn.Size = UDim2.new(0,26,0,26)
EditBtn.BackgroundColor3 = T.Bg3
EditBtn.BorderSizePixel = 0
EditBtn.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Regular)
EditBtn.TextSize = 13
EditBtn.TextColor3 = T.Tx2
EditBtn.Text = "✎"
EditBtn.ZIndex = 7
EditBtn.AutoButtonColor = false
EditBtn.LayoutOrder = 4
EditBtn.Parent = PillInner
Instance.new("UICorner",EditBtn).CornerRadius = UDim.new(0,13)

-- ==========================================
-- DRAG SYSTEM
-- ==========================================
local dragging, dragStart, startPos, hasMoved

local function setupDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 4 then hasMoved = true end
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

setupDrag(Pill)

-- ==========================================
-- EDITOR OPEN/CLOSE
-- ==========================================
local editorOpen = true

local function openEditor()
    editorOpen = true
    CodeInput.Text = userCode
    Backdrop.Visible = true
    Editor.Visible = true
    Backdrop.BackgroundTransparency = 1
    Editor.BackgroundTransparency = 0.5
    local s = UDim2.new(0, edW * 0.85, 0, edH * 0.85)
    Editor.Size = s
    tw(Backdrop, {BackgroundTransparency=0.35}, 0.25)
    tw(Editor, {BackgroundTransparency=0, Size=UDim2.new(0,edW,0,edH)}, 0.3, Enum.EasingStyle.Back)
end

local function closeEditor()
    editorOpen = false
    tw(Backdrop, {BackgroundTransparency=1}, 0.2)
    local t = tw(Editor, {BackgroundTransparency=0.5, Size=UDim2.new(0,edW*0.9,0,edH*0.9)}, 0.2, Enum.EasingStyle.Quint)
    t.Completed:Connect(function()
        Backdrop.Visible = false
        Editor.Visible = false
    end)
end

local function showPill()
    Pill.Visible = true
    Pill.Size = UDim2.new(0,0,0,0)
    Pill.BackgroundTransparency = 1
    tw(Pill, {Size=UDim2.new(0,152,0,38), BackgroundTransparency=0}, 0.35, Enum.EasingStyle.Back)
end

local function hidePill()
    local t = tw(Pill, {Size=UDim2.new(0,0,0,0), BackgroundTransparency=1}, 0.25)
    t.Completed:Connect(function() Pill.Visible = false end)
end

-- ==========================================
-- TOGGLE LOGIC
-- ==========================================
local function setToggle(state)
    isLooping = state
    if state then
        tw(Switch, {BackgroundColor3=T.Green}, 0.2)
        tw(Knob, {Position=UDim2.new(0,18,0.5,0)}, 0.2, Enum.EasingStyle.Back)
        tw(Dot, {BackgroundColor3=T.Green}, 0.15)
        PillLabel.Text = "On"
        PillLabel.TextColor3 = T.Green

        local delay = tonumber(DelayIn.Text) or 0.5
        delay = math.max(delay, 0.05)

        task.spawn(function()
            while isLooping do
                local ok, err = pcall(function()
                    loadstring(userCode)()
                end)
                if not ok then
                    toast("⚠ "..tostring(err):sub(1,40), 2.5)
                    setToggle(false)
                    break
                end
                task.wait(delay)
            end
        end)
    else
        isLooping = false
        tw(Switch, {BackgroundColor3=T.SwitchOff}, 0.2)
        tw(Knob, {Position=UDim2.new(0,2,0.5,0)}, 0.2, Enum.EasingStyle.Back)
        tw(Dot, {BackgroundColor3=T.Tx3}, 0.15)
        PillLabel.Text = "Loop"
        PillLabel.TextColor3 = T.Tx2
    end
end

-- ==========================================
-- CONNECTIONS
-- ==========================================

CloseBtn.MouseButton1Click:Connect(function()
    if userCode ~= "" then
        closeEditor()
        task.delay(0.3, showPill)
    else
        closeEditor()
    end
end)

Backdrop.MouseButton1Click:Connect(function()
    if userCode ~= "" then
        closeEditor()
        task.delay(0.3, showPill)
    end
end)

RunBtn.MouseButton1Click:Connect(function()
    local code = CodeInput.Text
    if code == "" then toast("⚠ No code",1.5) return end
    tw(RunBtn, {BackgroundColor3=T.Green}, 0.1)
    task.delay(0.3, function() tw(RunBtn, {BackgroundColor3=T.Bg2}, 0.15) end)
    local ok, err = pcall(function() loadstring(code)() end)
    if ok then toast("✓ Done",1.2) else toast("⚠ "..tostring(err):sub(1,45),2.5) end
end)

SaveBtn.MouseButton1Click:Connect(function()
    local code = CodeInput.Text
    if code=="" or code:match("^%s*$") then
        toast("⚠ Paste code first",1.5)
        local p = Editor.Position
        for i=1,3 do
            tw(Editor,{Position=p+UDim2.new(0,5,0,0)},0.03,Enum.EasingStyle.Linear)
            task.wait(0.03)
            tw(Editor,{Position=p+UDim2.new(0,-5,0,0)},0.03,Enum.EasingStyle.Linear)
            task.wait(0.03)
        end
        tw(Editor,{Position=p},0.05)
        return
    end
    userCode = code
    loopDelay = tonumber(DelayIn.Text) or 0.5
    closeEditor()
    task.delay(0.35, function()
        showPill()
        toast("✓ Toggle ready",1.5)
    end)
end)

SwitchHit.MouseButton1Click:Connect(function()
    if not hasMoved then
        setToggle(not isLooping)
    end
end)

EditBtn.MouseButton1Click:Connect(function()
    if isLooping then setToggle(false) end
    hidePill()
    task.delay(0.3, openEditor)
end)

CodeInput.Focused:Connect(function()
    tw(codeStroke, {Color=T.Blue}, 0.15)
end)
CodeInput.FocusLost:Connect(function()
    tw(codeStroke, {Color=Color3.fromRGB(55,55,60)}, 0.15)
end)

DelayIn.FocusLost:Connect(function()
    local v = tonumber(DelayIn.Text)
    if not v or v < 0.05 then DelayIn.Text="0.5" end
end)

-- ==========================================
-- INITIAL ENTRANCE
-- ==========================================
Backdrop.Visible = true
Editor.Visible = true
Backdrop.BackgroundTransparency = 1
Editor.BackgroundTransparency = 1
Editor.Size = UDim2.new(0, edW*0.8, 0, edH*0.8)

task.delay(0.15, function()
    tw(Backdrop, {BackgroundTransparency=0.35}, 0.3)
    tw(Editor, {BackgroundTransparency=0, Size=UDim2.new(0,edW,0,edH)}, 0.35, Enum.EasingStyle.Back)
end)

LocalPlayer.CharacterAdded:Connect(function() isLooping = false end)