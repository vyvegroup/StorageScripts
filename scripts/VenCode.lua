--[[
    SMART TOGGLE SYSTEM v2.0
    Clean Modern UI - Inspired by Material You / Apple HIG
    Works on Mobile Executors
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- State
local isLooping = false
local loopConnection = nil
local userCode = ""
local editorOpen = true
local buttonVisible = false

-- Design Tokens (Apple/Google Material You inspired)
local Theme = {
    -- Surfaces
    SurfacePrimary = Color3.fromRGB(255, 255, 255),
    SurfaceSecondary = Color3.fromRGB(245, 245, 247),
    SurfaceTertiary = Color3.fromRGB(238, 238, 240),
    SurfaceElevated = Color3.fromRGB(255, 255, 255),
    
    -- Text
    TextPrimary = Color3.fromRGB(28, 28, 30),
    TextSecondary = Color3.fromRGB(99, 99, 102),
    TextTertiary = Color3.fromRGB(142, 142, 147),
    TextOnAccent = Color3.fromRGB(255, 255, 255),
    
    -- Accent
    Accent = Color3.fromRGB(0, 122, 255), -- iOS Blue
    AccentHover = Color3.fromRGB(0, 100, 220),
    AccentGreen = Color3.fromRGB(52, 199, 89),
    AccentRed = Color3.fromRGB(255, 59, 48),
    AccentOrange = Color3.fromRGB(255, 149, 0),
    
    -- Code Editor
    CodeBackground = Color3.fromRGB(30, 30, 32),
    CodeText = Color3.fromRGB(212, 212, 216),
    CodeLineNum = Color3.fromRGB(90, 90, 94),
    CodeCursor = Color3.fromRGB(0, 122, 255),
    CodeSelection = Color3.fromRGB(50, 80, 140),
    
    -- Borders & Shadows
    Border = Color3.fromRGB(220, 220, 224),
    BorderLight = Color3.fromRGB(235, 235, 238),
    Shadow = Color3.fromRGB(0, 0, 0),
    
    -- Toggle
    ToggleOff = Color3.fromRGB(220, 220, 224),
    ToggleOn = Color3.fromRGB(52, 199, 89),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    
    -- Radius
    RadiusXL = UDim.new(0, 20),
    RadiusLG = UDim.new(0, 16),
    RadiusMD = UDim.new(0, 12),
    RadiusSM = UDim.new(0, 8),
    RadiusXS = UDim.new(0, 6),
    RadiusFull = UDim.new(0, 999),
    
    -- Font
    FontBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
    FontMedium = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
    FontRegular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
    FontMono = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular),
    FontMonoBold = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
}

-- Smooth Tween Helper
local function tween(obj, props, duration, style, direction)
    local t = TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    ), props)
    t:Play()
    return t
end

-- Drop Shadow Creator
local function addShadow(parent, radius, offset, spread, opacity)
    -- Simple shadow using ImageLabel approach
    -- For clean look, we use a subtle border instead
    local shadow = Instance.new("Frame")
    shadow.Name = "ShadowBorder"
    shadow.Size = UDim2.new(1, spread or 2, 1, spread or 2)
    shadow.Position = UDim2.new(0, -(spread or 2)/2, 0, (offset or 1))
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 1 - (opacity or 0.08)
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = radius or Theme.RadiusMD
    shadowCorner.Parent = shadow
    
    return shadow
end

-- Pill Badge Creator
local function createBadge(parent, text, color)
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 0, 0, 20)
    badge.AutomaticSize = Enum.AutomaticSize.X
    badge.BackgroundColor3 = color
    badge.BackgroundTransparency = 0.88
    badge.BorderSizePixel = 0
    badge.Parent = parent
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = Theme.RadiusFull
    badgeCorner.Parent = badge
    
    local badgePad = Instance.new("UIPadding")
    badgePad.PaddingLeft = UDim.new(0, 8)
    badgePad.PaddingRight = UDim.new(0, 8)
    badgePad.Parent = badge
    
    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(0, 0, 1, 0)
    badgeText.AutomaticSize = Enum.AutomaticSize.X
    badgeText.BackgroundTransparency = 1
    badgeText.FontFace = Theme.FontBold
    badgeText.TextSize = 11
    badgeText.TextColor3 = color
    badgeText.Text = text
    badgeText.Parent = badge
    
    return badge
end

-- ==========================================
-- MAIN SCREEN GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmartToggleSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ==========================================
-- EDITOR UI
-- ==========================================

-- Backdrop (blur effect)
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 0.4
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 10
Backdrop.Parent = ScreenGui

-- Editor Container
local EditorContainer = Instance.new("Frame")
EditorContainer.Name = "EditorContainer"
EditorContainer.AnchorPoint = Vector2.new(0.5, 0.5)
EditorContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
EditorContainer.Size = UDim2.new(0, 340, 0, 460)
EditorContainer.BackgroundColor3 = Theme.SurfacePrimary
EditorContainer.BorderSizePixel = 0
EditorContainer.ZIndex = 11
EditorContainer.Parent = ScreenGui

-- Clamp size for very small screens
if workspace.CurrentCamera.ViewportSize.X < 380 then
    EditorContainer.Size = UDim2.new(1, -24, 0, 440)
end

local editorCorner = Instance.new("UICorner")
editorCorner.CornerRadius = Theme.RadiusXL
editorCorner.Parent = EditorContainer

-- Subtle border
local editorStroke = Instance.new("UIStroke")
editorStroke.Color = Theme.BorderLight
editorStroke.Thickness = 1
editorStroke.Transparency = 0.3
editorStroke.Parent = EditorContainer

-- ==========================================
-- EDITOR HEADER
-- ==========================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundTransparency = 1
Header.BorderSizePixel = 0
Header.ZIndex = 12
Header.Parent = EditorContainer

local HeaderPadding = Instance.new("UIPadding")
HeaderPadding.PaddingLeft = UDim.new(0, 20)
HeaderPadding.PaddingRight = UDim.new(0, 16)
HeaderPadding.PaddingTop = UDim.new(0, 4)
HeaderPadding.Parent = Header

-- Header Title Area
local HeaderLeft = Instance.new("Frame")
HeaderLeft.Size = UDim2.new(1, -44, 1, 0)
HeaderLeft.BackgroundTransparency = 1
HeaderLeft.ZIndex = 12
HeaderLeft.Parent = Header

local HeaderLayout = Instance.new("UIListLayout")
HeaderLayout.FillDirection = Enum.FillDirection.Vertical
HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderLayout.Padding = UDim.new(0, 1)
HeaderLayout.Parent = HeaderLeft

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 22)
TitleLabel.BackgroundTransparency = 1
TitleLabel.FontFace = Theme.FontBold
TitleLabel.TextSize = 17
TitleLabel.TextColor3 = Theme.TextPrimary
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Code Editor"
TitleLabel.ZIndex = 12
TitleLabel.Parent = HeaderLeft

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "Subtitle"
SubtitleLabel.Size = UDim2.new(1, 0, 0, 16)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.FontFace = Theme.FontRegular
SubtitleLabel.TextSize = 12
SubtitleLabel.TextColor3 = Theme.TextTertiary
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Text = "Paste your code to loop execute"
SubtitleLabel.ZIndex = 12
SubtitleLabel.Parent = HeaderLeft

-- Close button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, 0, 0.5, 0)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.BackgroundColor3 = Theme.SurfaceTertiary
CloseBtn.BackgroundTransparency = 0
CloseBtn.BorderSizePixel = 0
CloseBtn.FontFace = Theme.FontMedium
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Theme.TextSecondary
CloseBtn.Text = "✕"
CloseBtn.ZIndex = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = Theme.RadiusFull
closeBtnCorner.Parent = CloseBtn

-- Header divider
local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "Divider"
HeaderDivider.AnchorPoint = Vector2.new(0.5, 0)
HeaderDivider.Position = UDim2.new(0.5, 0, 1, 0)
HeaderDivider.Size = UDim2.new(1, -32, 0, 1)
HeaderDivider.BackgroundColor3 = Theme.BorderLight
HeaderDivider.BackgroundTransparency = 0.2
HeaderDivider.BorderSizePixel = 0
HeaderDivider.ZIndex = 12
HeaderDivider.Parent = Header

-- ==========================================
-- CODE EDITOR AREA
-- ==========================================
local CodeSection = Instance.new("Frame")
CodeSection.Name = "CodeSection"
CodeSection.Position = UDim2.new(0, 0, 0, 60)
CodeSection.Size = UDim2.new(1, 0, 1, -138)
CodeSection.BackgroundTransparency = 1
CodeSection.ZIndex = 11
CodeSection.Parent = EditorContainer

local CodeSectionPadding = Instance.new("UIPadding")
CodeSectionPadding.PaddingLeft = UDim.new(0, 16)
CodeSectionPadding.PaddingRight = UDim.new(0, 16)
CodeSectionPadding.PaddingTop = UDim.new(0, 8)
CodeSectionPadding.PaddingBottom = UDim.new(0, 4)
CodeSectionPadding.Parent = CodeSection

-- Label above editor
local CodeLabel = Instance.new("TextLabel")
CodeLabel.Name = "CodeLabel"
CodeLabel.Size = UDim2.new(1, 0, 0, 20)
CodeLabel.BackgroundTransparency = 1
CodeLabel.FontFace = Theme.FontMedium
CodeLabel.TextSize = 12
CodeLabel.TextColor3 = Theme.TextSecondary
CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
CodeLabel.Text = "CODE"
CodeLabel.ZIndex = 12
CodeLabel.Parent = CodeSection

-- Code input container (dark)
local CodeContainer = Instance.new("Frame")
CodeContainer.Name = "CodeContainer"
CodeContainer.Position = UDim2.new(0, 0, 0, 24)
CodeContainer.Size = UDim2.new(1, 0, 1, -24)
CodeContainer.BackgroundColor3 = Theme.CodeBackground
CodeContainer.BorderSizePixel = 0
CodeContainer.ZIndex = 11
CodeContainer.ClipsDescendants = true
CodeContainer.Parent = CodeSection

local codeContainerCorner = Instance.new("UICorner")
codeContainerCorner.CornerRadius = Theme.RadiusMD
codeContainerCorner.Parent = CodeContainer

local codeContainerStroke = Instance.new("UIStroke")
codeContainerStroke.Color = Color3.fromRGB(55, 55, 60)
codeContainerStroke.Thickness = 1
codeContainerStroke.Parent = CodeContainer

-- ScrollingFrame for code
local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Name = "CodeScroll"
CodeScroll.Size = UDim2.new(1, 0, 1, 0)
CodeScroll.BackgroundTransparency = 1
CodeScroll.BorderSizePixel = 0
CodeScroll.ScrollBarThickness = 3
CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
CodeScroll.ScrollBarImageTransparency = 0.3
CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CodeScroll.ZIndex = 12
CodeScroll.Parent = CodeContainer

-- Code TextBox
local CodeInput = Instance.new("TextBox")
CodeInput.Name = "CodeInput"
CodeInput.Size = UDim2.new(1, 0, 0, 0)
CodeInput.AutomaticSize = Enum.AutomaticSize.Y
CodeInput.BackgroundTransparency = 1
CodeInput.FontFace = Theme.FontMono
CodeInput.TextSize = 13
CodeInput.TextColor3 = Theme.CodeText
CodeInput.PlaceholderText = '-- Paste your code here\nprint("Hello World")'
CodeInput.PlaceholderColor3 = Color3.fromRGB(75, 75, 80)
CodeInput.Text = ""
CodeInput.TextXAlignment = Enum.TextXAlignment.Left
CodeInput.TextYAlignment = Enum.TextYAlignment.Top
CodeInput.ClearTextOnFocus = false
CodeInput.MultiLine = true
CodeInput.TextWrapped = true
CodeInput.ZIndex = 13
CodeInput.Parent = CodeScroll

local codeInputPadding = Instance.new("UIPadding")
codeInputPadding.PaddingLeft = UDim.new(0, 14)
codeInputPadding.PaddingRight = UDim.new(0, 14)
codeInputPadding.PaddingTop = UDim.new(0, 12)
codeInputPadding.PaddingBottom = UDim.new(0, 12)
codeInputPadding.Parent = CodeInput

-- ==========================================
-- SETTINGS ROW (Delay)
-- ==========================================
local SettingsRow = Instance.new("Frame")
SettingsRow.Name = "SettingsRow"
SettingsRow.Position = UDim2.new(0, 0, 1, -78)
SettingsRow.Size = UDim2.new(1, 0, 0, 36)
SettingsRow.BackgroundTransparency = 1
SettingsRow.ZIndex = 11
SettingsRow.Parent = EditorContainer

local settingsPadding = Instance.new("UIPadding")
settingsPadding.PaddingLeft = UDim.new(0, 16)
settingsPadding.PaddingRight = UDim.new(0, 16)
settingsPadding.Parent = SettingsRow

-- Delay Label
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Name = "DelayLabel"
DelayLabel.Size = UDim2.new(0.5, 0, 1, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.FontFace = Theme.FontMedium
DelayLabel.TextSize = 14
DelayLabel.TextColor3 = Theme.TextPrimary
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Text = "⏱ Loop Delay (sec)"
DelayLabel.ZIndex = 12
DelayLabel.Parent = SettingsRow

-- Delay Input
local DelayInputFrame = Instance.new("Frame")
DelayInputFrame.Name = "DelayFrame"
DelayInputFrame.AnchorPoint = Vector2.new(1, 0.5)
DelayInputFrame.Position = UDim2.new(1, 0, 0.5, 0)
DelayInputFrame.Size = UDim2.new(0, 72, 0, 32)
DelayInputFrame.BackgroundColor3 = Theme.SurfaceSecondary
DelayInputFrame.BorderSizePixel = 0
DelayInputFrame.ZIndex = 12
DelayInputFrame.Parent = SettingsRow

local delayFrameCorner = Instance.new("UICorner")
delayFrameCorner.CornerRadius = Theme.RadiusSM
delayFrameCorner.Parent = DelayInputFrame

local delayFrameStroke = Instance.new("UIStroke")
delayFrameStroke.Color = Theme.Border
delayFrameStroke.Thickness = 1
delayFrameStroke.Transparency = 0.4
delayFrameStroke.Parent = DelayInputFrame

local DelayInput = Instance.new("TextBox")
DelayInput.Name = "DelayInput"
DelayInput.Size = UDim2.new(1, 0, 1, 0)
DelayInput.BackgroundTransparency = 1
DelayInput.FontFace = Theme.FontMonoBold
DelayInput.TextSize = 14
DelayInput.TextColor3 = Theme.TextPrimary
DelayInput.PlaceholderText = "0.5"
DelayInput.PlaceholderColor3 = Theme.TextTertiary
DelayInput.Text = "0.5"
DelayInput.ClearTextOnFocus = true
DelayInput.ZIndex = 13
DelayInput.Parent = DelayInputFrame

-- ==========================================
-- BOTTOM BUTTON BAR
-- ==========================================
local BottomBar = Instance.new("Frame")
BottomBar.Name = "BottomBar"
BottomBar.Position = UDim2.new(0, 0, 1, -42)
BottomBar.Size = UDim2.new(1, 0, 0, 42)
BottomBar.BackgroundTransparency = 1
BottomBar.ZIndex = 11
BottomBar.Parent = EditorContainer

local bottomPadding = Instance.new("UIPadding")
bottomPadding.PaddingLeft = UDim.new(0, 16)
bottomPadding.PaddingRight = UDim.new(0, 16)
bottomPadding.PaddingBottom = UDim.new(0, 6)
bottomPadding.Parent = BottomBar

local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ButtonLayout.Padding = UDim.new(0, 8)
ButtonLayout.Parent = BottomBar

-- Run Once Button
local RunOnceBtn = Instance.new("TextButton")
RunOnceBtn.Name = "RunOnce"
RunOnceBtn.Size = UDim2.new(0, 90, 0, 36)
RunOnceBtn.BackgroundColor3 = Theme.SurfaceSecondary
RunOnceBtn.BorderSizePixel = 0
RunOnceBtn.FontFace = Theme.FontMedium
RunOnceBtn.TextSize = 13
RunOnceBtn.TextColor3 = Theme.TextPrimary
RunOnceBtn.Text = "Run Once"
RunOnceBtn.ZIndex = 12
RunOnceBtn.AutoButtonColor = false
RunOnceBtn.LayoutOrder = 1
RunOnceBtn.Parent = BottomBar

local runOnceCorner = Instance.new("UICorner")
runOnceCorner.CornerRadius = Theme.RadiusSM
runOnceCorner.Parent = RunOnceBtn

-- Confirm Button
local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Name = "Confirm"
ConfirmBtn.Size = UDim2.new(0, 120, 0, 36)
ConfirmBtn.BackgroundColor3 = Theme.Accent
ConfirmBtn.BorderSizePixel = 0
ConfirmBtn.FontFace = Theme.FontBold
ConfirmBtn.TextSize = 13
ConfirmBtn.TextColor3 = Theme.TextOnAccent
ConfirmBtn.Text = "Create Toggle"
ConfirmBtn.ZIndex = 12
ConfirmBtn.AutoButtonColor = false
ConfirmBtn.LayoutOrder = 2
ConfirmBtn.Parent = BottomBar

local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = Theme.RadiusSM
confirmCorner.Parent = ConfirmBtn

-- ==========================================
-- FLOATING TOGGLE BUTTON (initially hidden)
-- ==========================================
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleContainer.Position = UDim2.new(0.5, 0, 0.85, 0)
ToggleContainer.Size = UDim2.new(0, 0, 0, 0) -- starts hidden
ToggleContainer.BackgroundColor3 = Theme.SurfaceElevated
ToggleContainer.BorderSizePixel = 0
ToggleContainer.ZIndex = 5
ToggleContainer.Visible = false
ToggleContainer.Parent = ScreenGui

local toggleContainerCorner = Instance.new("UICorner")
toggleContainerCorner.CornerRadius = Theme.RadiusLG
toggleContainerCorner.Parent = ToggleContainer

local toggleContainerStroke = Instance.new("UIStroke")
toggleContainerStroke.Color = Theme.BorderLight
toggleContainerStroke.Thickness = 1
toggleContainerStroke.Transparency = 0.2
toggleContainerStroke.Parent = ToggleContainer

-- Inner layout
local ToggleInner = Instance.new("Frame")
ToggleInner.Name = "Inner"
ToggleInner.Size = UDim2.new(1, 0, 1, 0)
ToggleInner.BackgroundTransparency = 1
ToggleInner.ZIndex = 6
ToggleInner.Parent = ToggleContainer

local toggleInnerPadding = Instance.new("UIPadding")
toggleInnerPadding.PaddingLeft = UDim.new(0, 14)
toggleInnerPadding.PaddingRight = UDim.new(0, 10)
toggleInnerPadding.Parent = ToggleInner

local ToggleInnerLayout = Instance.new("UIListLayout")
ToggleInnerLayout.FillDirection = Enum.FillDirection.Horizontal
ToggleInnerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ToggleInnerLayout.Padding = UDim.new(0, 10)
ToggleInnerLayout.Parent = ToggleInner

-- Status dot
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.BackgroundColor3 = Theme.TextTertiary
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 7
StatusDot.LayoutOrder = 1
StatusDot.Parent = ToggleInner

local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = Theme.RadiusFull
statusDotCorner.Parent = StatusDot

-- Label
local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Name = "Label"
ToggleLabel.Size = UDim2.new(0, 56, 0, 20)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.FontFace = Theme.FontMedium
ToggleLabel.TextSize = 13
ToggleLabel.TextColor3 = Theme.TextSecondary
ToggleLabel.Text = "Loop"
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.ZIndex = 7
ToggleLabel.LayoutOrder = 2
ToggleLabel.Parent = ToggleInner

-- iOS-style Toggle Switch
local SwitchFrame = Instance.new("Frame")
SwitchFrame.Name = "Switch"
SwitchFrame.Size = UDim2.new(0, 46, 0, 28)
SwitchFrame.BackgroundColor3 = Theme.ToggleOff
SwitchFrame.BorderSizePixel = 0
SwitchFrame.ZIndex = 7
SwitchFrame.LayoutOrder = 3
SwitchFrame.Parent = ToggleInner

local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = Theme.RadiusFull
switchCorner.Parent = SwitchFrame

-- Switch Knob
local SwitchKnob = Instance.new("Frame")
SwitchKnob.Name = "Knob"
SwitchKnob.AnchorPoint = Vector2.new(0, 0.5)
SwitchKnob.Position = UDim2.new(0, 3, 0.5, 0)
SwitchKnob.Size = UDim2.new(0, 22, 0, 22)
SwitchKnob.BackgroundColor3 = Theme.ToggleKnob
SwitchKnob.BorderSizePixel = 0
SwitchKnob.ZIndex = 8
SwitchKnob.Parent = SwitchFrame

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = Theme.RadiusFull
knobCorner.Parent = SwitchKnob

-- Switch hit area (invisible button)
local SwitchButton = Instance.new("TextButton")
SwitchButton.Name = "SwitchHit"
SwitchButton.Size = UDim2.new(1, 10, 1, 10)
SwitchButton.Position = UDim2.new(0, -5, 0, -5)
SwitchButton.BackgroundTransparency = 1
SwitchButton.Text = ""
SwitchButton.ZIndex = 9
SwitchButton.Parent = SwitchFrame

-- Edit button (small pencil icon)
local EditBtn = Instance.new("TextButton")
EditBtn.Name = "EditBtn"
EditBtn.Size = UDim2.new(0, 28, 0, 28)
EditBtn.BackgroundColor3 = Theme.SurfaceTertiary
EditBtn.BackgroundTransparency = 0
EditBtn.BorderSizePixel = 0
EditBtn.FontFace = Theme.FontRegular
EditBtn.TextSize = 14
EditBtn.TextColor3 = Theme.TextSecondary
EditBtn.Text = "✎"
EditBtn.ZIndex = 7
EditBtn.AutoButtonColor = false
EditBtn.LayoutOrder = 4
EditBtn.Parent = ToggleInner

local editBtnCorner = Instance.new("UICorner")
editBtnCorner.CornerRadius = Theme.RadiusFull
editBtnCorner.Parent = EditBtn

-- ==========================================
-- TOAST NOTIFICATION
-- ==========================================
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "Toast"
ToastContainer.AnchorPoint = Vector2.new(0.5, 0)
ToastContainer.Position = UDim2.new(0.5, 0, 0, -50)
ToastContainer.Size = UDim2.new(0, 240, 0, 40)
ToastContainer.BackgroundColor3 = Theme.CodeBackground
ToastContainer.BackgroundTransparency = 0.05
ToastContainer.BorderSizePixel = 0
ToastContainer.ZIndex = 50
ToastContainer.Parent = ScreenGui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = Theme.RadiusFull
toastCorner.Parent = ToastContainer

local ToastLabel = Instance.new("TextLabel")
ToastLabel.Size = UDim2.new(1, 0, 1, 0)
ToastLabel.BackgroundTransparency = 1
ToastLabel.FontFace = Theme.FontMedium
ToastLabel.TextSize = 13
ToastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ToastLabel.Text = ""
ToastLabel.ZIndex = 51
ToastLabel.Parent = ToastContainer

local function showToast(message, duration)
    ToastLabel.Text = message
    ToastContainer.Position = UDim2.new(0.5, 0, 0, -50)
    tween(ToastContainer, {Position = UDim2.new(0.5, 0, 0, 56)}, 0.4)
    task.delay(duration or 2, function()
        tween(ToastContainer, {Position = UDim2.new(0.5, 0, 0, -50)}, 0.4)
    end)
end

-- ==========================================
-- DRAG SYSTEM (Mobile Friendly)
-- ==========================================
local function makeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local dragThreshold = 5
    local hasMoved = false
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        tween(frame, {Position = newPos}, 0.08, Enum.EasingStyle.Linear)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
            or input.UserInputType == Enum.UserInputType.Touch then
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
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > dragThreshold then
                hasMoved = true
            end
            update(input)
        end
    end)
    
    return function() return hasMoved end
end

local getHasMoved = makeDraggable(ToggleContainer)

-- ==========================================
-- BUTTON HOVER/PRESS EFFECTS
-- ==========================================
local function addButtonEffect(btn, hoverColor, pressColor)
    local originalColor = btn.BackgroundColor3
    
    btn.MouseEnter:Connect(function()
        if hoverColor then
            tween(btn, {BackgroundColor3 = hoverColor}, 0.15)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = originalColor}, 0.15)
    end)
    
    btn.MouseButton1Down:Connect(function()
        tween(btn, {Size = btn.Size - UDim2.new(0, 2, 0, 1)}, 0.1)
        if pressColor then
            tween(btn, {BackgroundColor3 = pressColor}, 0.05)
        end
    end)
    
    btn.MouseButton1Up:Connect(function()
        tween(btn, {Size = btn.Size + UDim2.new(0, 2, 0, 1)}, 0.15)
        tween(btn, {BackgroundColor3 = originalColor}, 0.15)
    end)
end

addButtonEffect(ConfirmBtn, Theme.AccentHover, Theme.AccentHover)
addButtonEffect(RunOnceBtn, Theme.SurfaceTertiary, Theme.Border)
addButtonEffect(CloseBtn, Theme.Border, Theme.Border)
addButtonEffect(EditBtn, Theme.Border, Theme.Border)

-- ==========================================
-- EDITOR OPEN/CLOSE ANIMATIONS
-- ==========================================
local function openEditor()
    editorOpen = true
    Backdrop.Visible = true
    EditorContainer.Visible = true
    
    -- Reset code input to current code
    CodeInput.Text = userCode
    
    -- Animate in
    Backdrop.BackgroundTransparency = 1
    EditorContainer.Size = UDim2.new(0, 300, 0, 400)
    EditorContainer.BackgroundTransparency = 0.3
    
    tween(Backdrop, {BackgroundTransparency = 0.4}, 0.3)
    
    local targetSize = UDim2.new(0, 340, 0, 460)
    if workspace.CurrentCamera.ViewportSize.X < 380 then
        targetSize = UDim2.new(1, -24, 0, 440)
    end
    
    tween(EditorContainer, {
        Size = targetSize,
        BackgroundTransparency = 0
    }, 0.35, Enum.EasingStyle.Back)
end

local function closeEditor()
    editorOpen = false
    
    tween(Backdrop, {BackgroundTransparency = 1}, 0.25)
    local t = tween(EditorContainer, {
        Size = UDim2.new(0, 300, 0, 380),
        BackgroundTransparency = 0.5
    }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    
    t.Completed:Connect(function()
        Backdrop.Visible = false
        EditorContainer.Visible = false
    end)
end

-- ==========================================
-- TOGGLE BUTTON SHOW/HIDE
-- ==========================================
local function showToggleButton()
    if buttonVisible then return end
    buttonVisible = true
    ToggleContainer.Visible = true
    ToggleContainer.Size = UDim2.new(0, 0, 0, 0)
    ToggleContainer.BackgroundTransparency = 1
    
    tween(ToggleContainer, {
        Size = UDim2.new(0, 200, 0, 44),
        BackgroundTransparency = 0
    }, 0.4, Enum.EasingStyle.Back)
end

local function hideToggleButton()
    buttonVisible = false
    local t = tween(ToggleContainer, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    t.Completed:Connect(function()
        ToggleContainer.Visible = false
    end)
end

-- ==========================================
-- TOGGLE SWITCH LOGIC
-- ==========================================
local function setToggleState(state)
    isLooping = state
    
    if state then
        -- ON
        tween(SwitchFrame, {BackgroundColor3 = Theme.ToggleOn}, 0.25)
        tween(SwitchKnob, {Position = UDim2.new(0, 21, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
        tween(StatusDot, {BackgroundColor3 = Theme.AccentGreen}, 0.2)
        ToggleLabel.Text = "Running"
        ToggleLabel.TextColor3 = Theme.AccentGreen
        
        -- Start loop
        local delay = tonumber(DelayInput.Text) or 0.5
        delay = math.max(delay, 0.05) -- Minimum 50ms
        
        loopConnection = task.spawn(function()
            while isLooping do
                local success, err = pcall(function()
                    loadstring(userCode)()
                end)
                if not success then
                    showToast("⚠ Error: " .. tostring(err):sub(1, 40), 3)
                    setToggleState(false)
                    break
                end
                task.wait(delay)
            end
        end)
    else
        -- OFF
        tween(SwitchFrame, {BackgroundColor3 = Theme.ToggleOff}, 0.25)
        tween(SwitchKnob, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
        tween(StatusDot, {BackgroundColor3 = Theme.TextTertiary}, 0.2)
        ToggleLabel.Text = "Loop"
        ToggleLabel.TextColor3 = Theme.TextSecondary
        
        -- Stop loop
        isLooping = false
    end
end

-- ==========================================
-- EVENT CONNECTIONS
-- ==========================================

-- Close Editor
CloseBtn.MouseButton1Click:Connect(function()
    if userCode ~= "" then
        closeEditor()
        showToggleButton()
    else
        closeEditor()
    end
end)

-- Backdrop tap to close
Backdrop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
        if userCode ~= "" then
            closeEditor()
            showToggleButton()
        end
    end
end)

-- Run Once
RunOnceBtn.MouseButton1Click:Connect(function()
    local code = CodeInput.Text
    if code == "" then
        showToast("⚠ No code entered", 2)
        return
    end
    
    -- Flash effect
    local origColor = RunOnceBtn.BackgroundColor3
    tween(RunOnceBtn, {BackgroundColor3 = Theme.AccentGreen}, 0.1)
    
    local success, err = pcall(function()
        loadstring(code)()
    end)
    
    task.delay(0.3, function()
        tween(RunOnceBtn, {BackgroundColor3 = origColor}, 0.2)
    end)
    
    if success then
        showToast("✓ Executed successfully", 1.5)
    else
        showToast("⚠ " .. tostring(err):sub(1, 50), 3)
    end
end)

-- Confirm / Create Toggle
ConfirmBtn.MouseButton1Click:Connect(function()
    local code = CodeInput.Text
    if code == "" or code:match("^%s*$") then
        showToast("⚠ Please paste some code first", 2)
        -- Shake animation
        local origPos = EditorContainer.Position
        for i = 1, 3 do
            tween(EditorContainer, {Position = origPos + UDim2.new(0, 6, 0, 0)}, 0.04, Enum.EasingStyle.Linear)
            task.wait(0.04)
            tween(EditorContainer, {Position = origPos + UDim2.new(0, -6, 0, 0)}, 0.04, Enum.EasingStyle.Linear)
            task.wait(0.04)
        end
        tween(EditorContainer, {Position = origPos}, 0.06)
        return
    end
    
    userCode = code
    closeEditor()
    
    task.delay(0.4, function()
        showToggleButton()
        showToast("✓ Toggle created! Drag to move", 2.5)
    end)
end)

-- Switch Toggle
SwitchButton.MouseButton1Click:Connect(function()
    if not getHasMoved() then
        setToggleState(not isLooping)
    end
end)

-- Edit Button
EditBtn.MouseButton1Click:Connect(function()
    if isLooping then
        setToggleState(false)
    end
    hideToggleButton()
    task.delay(0.35, function()
        openEditor()
    end)
end)

-- Code Input focus effect
CodeInput.Focused:Connect(function()
    tween(codeContainerStroke, {Color = Theme.Accent, Transparency = 0}, 0.2)
end)

CodeInput.FocusLost:Connect(function()
    tween(codeContainerStroke, {Color = Color3.fromRGB(55, 55, 60), Transparency = 0}, 0.2)
end)

-- Delay Input validation
DelayInput.FocusLost:Connect(function()
    local val = tonumber(DelayInput.Text)
    if not val or val < 0.05 then
        DelayInput.Text = "0.5"
        showToast("⚠ Min delay: 0.05s", 1.5)
    end
end)

-- ==========================================
-- ENTRANCE ANIMATION
-- ==========================================
Backdrop.BackgroundTransparency = 1
EditorContainer.BackgroundTransparency = 1
EditorContainer.Size = UDim2.new(0, 280, 0, 380)

task.delay(0.2, function()
    tween(Backdrop, {BackgroundTransparency = 0.4}, 0.4)
    
    local targetSize = UDim2.new(0, 340, 0, 460)
    if workspace.CurrentCamera.ViewportSize.X < 380 then
        targetSize = UDim2.new(1, -24, 0, 440)
    end
    
    tween(EditorContainer, {
        BackgroundTransparency = 0,
        Size = targetSize
    }, 0.5, Enum.EasingStyle.Back)
end)

-- ==========================================
-- CLEANUP ON CHARACTER RESET
-- ==========================================
LocalPlayer.CharacterAdded:Connect(function()
    isLooping = false
end)

print("[SmartToggle] System loaded successfully")