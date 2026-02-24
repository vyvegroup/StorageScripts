--[[
    ╔══════════════════════════════════════════╗
    ║         FLAVOR UI LIBRARY v2.0           ║
    ║   Modern · Clean · Mobile-First Design   ║
    ╚══════════════════════════════════════════╝
    
    Inspired by:
    • Apple Human Interface Guidelines
    • Google Material You / Material Design 3
    • Microsoft Fluent Design System 2
    
    Features:
    • Smooth spring animations
    • Compact mobile layout
    • Haptic-like micro interactions
    • Adaptive rounded corners
    • SF-style typography hierarchy
    • Backdrop blur simulation
    • Drag to reposition
    • Collapse / Expand
]]

local FlavorUI = {}
FlavorUI.__index = FlavorUI

-- ═══════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════
-- DESIGN TOKENS (Apple / Material You inspired)
-- ═══════════════════════════════════════
local Tokens = {
    -- Color Palette — Neutral, warm, professional
    Colors = {
        -- Surfaces
        SurfacePrimary    = Color3.fromRGB(255, 255, 255),
        SurfaceSecondary  = Color3.fromRGB(245, 245, 247),
        SurfaceTertiary   = Color3.fromRGB(238, 238, 240),
        SurfaceElevated   = Color3.fromRGB(255, 255, 255),
        
        -- Backgrounds
        BackgroundScrim   = Color3.fromRGB(120, 120, 128),
        BackgroundDim     = Color3.fromRGB(0, 0, 0),
        
        -- Text
        TextPrimary       = Color3.fromRGB(28, 28, 30),
        TextSecondary     = Color3.fromRGB(99, 99, 102),
        TextTertiary      = Color3.fromRGB(142, 142, 147),
        TextOnAccent      = Color3.fromRGB(255, 255, 255),
        
        -- Accent (Apple Blue)
        Accent            = Color3.fromRGB(0, 122, 255),
        AccentHover       = Color3.fromRGB(0, 106, 220),
        AccentPressed     = Color3.fromRGB(0, 90, 190),
        AccentSoft        = Color3.fromRGB(230, 241, 255),
        
        -- Semantic
        Success           = Color3.fromRGB(52, 199, 89),
        Warning           = Color3.fromRGB(255, 149, 0),
        Error             = Color3.fromRGB(255, 59, 48),
        
        -- Borders & Separators
        Separator         = Color3.fromRGB(220, 220, 224),
        SeparatorLight    = Color3.fromRGB(235, 235, 237),
        Border            = Color3.fromRGB(210, 210, 215),
        
        -- Toggle
        ToggleOff         = Color3.fromRGB(210, 210, 215),
        ToggleKnob        = Color3.fromRGB(255, 255, 255),
        
        -- Slider
        SliderTrack       = Color3.fromRGB(225, 225, 228),
        SliderFill        = Color3.fromRGB(0, 122, 255),
        
        -- Input
        InputBackground   = Color3.fromRGB(240, 240, 242),
        InputBorder       = Color3.fromRGB(210, 210, 215),
        InputFocusBorder  = Color3.fromRGB(0, 122, 255),
        
        -- Shadow simulation
        Shadow            = Color3.fromRGB(0, 0, 0),
    },
    
    -- Corner Radius — Apple-style generous rounding
    Radius = {
        None   = UDim.new(0, 0),
        Small  = UDim.new(0, 6),
        Medium = UDim.new(0, 10),
        Large  = UDim.new(0, 14),
        XLarge = UDim.new(0, 18),
        Full   = UDim.new(0, 999),
    },
    
    -- Typography Scale
    Font = {
        Title      = Enum.Font.GothamBold,
        Headline   = Enum.Font.GothamBold,
        Body       = Enum.Font.GothamMedium,
        Caption    = Enum.Font.Gotham,
        Label      = Enum.Font.GothamSemibold,
    },
    
    Size = {
        TitleText     = 15,
        HeadlineText  = 12,
        BodyText      = 11,
        CaptionText   = 10,
        LabelText     = 10,
    },
    
    -- Spacing
    Spacing = {
        XS = 4,
        S  = 6,
        M  = 10,
        L  = 14,
        XL = 18,
    },
    
    -- Component Heights (compact for mobile)
    Height = {
        Button     = 34,
        Toggle     = 26,
        Slider     = 34,
        Input      = 34,
        Dropdown   = 34,
        TabBar     = 32,
        Header     = 40,
        Row        = 38,
    },
    
    -- Animation
    Anim = {
        Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        Spring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
    },
}

-- ═══════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════
local Util = {}

function Util.create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

function Util.tween(instance, info, goals)
    local t = TweenService:Create(instance, info, goals)
    t:Play()
    return t
end

function Util.addCorner(parent, radius)
    return Util.create("UICorner", {
        CornerRadius = radius or Tokens.Radius.Medium,
        Parent = parent,
    })
end

function Util.addPadding(parent, top, right, bottom, left)
    return Util.create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        Parent = parent,
    })
end

function Util.addStroke(parent, color, thickness, transparency)
    return Util.create("UIStroke", {
        Color = color or Tokens.Colors.Separator,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function Util.addShadow(parent, offset, size, transparency)
    -- Simulated shadow using ImageLabel
    local shadow = Util.create("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, offset or 2),
        Size = UDim2.new(1, size or 6, 1, size or 6),
        BackgroundColor3 = Tokens.Colors.Shadow,
        BackgroundTransparency = transparency or 0.92,
        BorderSizePixel = 0,
        ZIndex = parent.ZIndex - 1,
        Parent = parent,
    })
    Util.addCorner(shadow, Tokens.Radius.XLarge)
    return shadow
end

function Util.addListLayout(parent, padding, direction, hAlign, vAlign, sortOrder)
    return Util.create("UIListLayout", {
        Padding = UDim.new(0, padding or Tokens.Spacing.S),
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center,
        VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Util.ripple(button, x, y)
    local ripple = Util.create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Tokens.Colors.TextPrimary,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 5,
        Parent = button,
    })
    Util.addCorner(ripple, Tokens.Radius.Full)
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    local expandTween = Util.tween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    })
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

function Util.pressEffect(frame, scaleDown)
    scaleDown = scaleDown or 0.97
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Util.tween(frame, Tokens.Anim.Fast, {
                Size = UDim2.new(
                    frame.Size.X.Scale * scaleDown, 
                    frame.Size.X.Offset * scaleDown, 
                    frame.Size.Y.Scale * scaleDown, 
                    frame.Size.Y.Offset * scaleDown
                )
            })
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Util.tween(frame, Tokens.Anim.Spring, {
                Size = frame.Size
            })
        end
    end)
end

-- ═══════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════
local NotificationHolder

local function ensureNotificationHolder()
    if NotificationHolder and NotificationHolder.Parent then return end
    
    local screenGui = Util.create("ScreenGui", {
        Name = "FlavorNotifications",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = Player:WaitForChild("PlayerGui") end
    
    NotificationHolder = Util.create("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 8),
        Size = UDim2.new(0, 280, 1, -16),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    Util.addListLayout(NotificationHolder, 6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
end

function FlavorUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3
    local notifType = config.Type or "Info" -- Info, Success, Warning, Error
    
    ensureNotificationHolder()
    
    local accentColor = Tokens.Colors.Accent
    if notifType == "Success" then accentColor = Tokens.Colors.Success
    elseif notifType == "Warning" then accentColor = Tokens.Colors.Warning
    elseif notifType == "Error" then accentColor = Tokens.Colors.Error end
    
    local notifFrame = Util.create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotificationHolder,
    })
    Util.addCorner(notifFrame, Tokens.Radius.Large)
    Util.addStroke(notifFrame, Tokens.Colors.SeparatorLight, 1, 0.3)
    
    -- Accent bar on left
    Util.create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = notifFrame,
    })
    
    local contentFrame = Util.create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Parent = notifFrame,
    })
    Util.addPadding(contentFrame, 8, 8, 8, 4)
    Util.addListLayout(contentFrame, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left)
    
    Util.create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = title,
        Font = Tokens.Font.Label,
        TextSize = Tokens.Size.LabelText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = contentFrame,
    })
    
    if message ~= "" then
        Util.create("TextLabel", {
            Name = "Message",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = message,
            Font = Tokens.Font.Caption,
            TextSize = Tokens.Size.CaptionText,
            TextColor3 = Tokens.Colors.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = contentFrame,
        })
    end
    
    -- Animate in
    notifFrame.Position = UDim2.new(0, 0, 0, -10)
    notifFrame.BackgroundTransparency = 1
    Util.tween(notifFrame, Tokens.Anim.Smooth, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.02,
    })
    
    -- Auto dismiss
    task.delay(duration, function()
        if notifFrame and notifFrame.Parent then
            local t = Util.tween(notifFrame, Tokens.Anim.Normal, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, -10),
            })
            -- Fade children
            for _, desc in ipairs(notifFrame:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    Util.tween(desc, Tokens.Anim.Fast, {TextTransparency = 1})
                elseif desc:IsA("Frame") then
                    Util.tween(desc, Tokens.Anim.Fast, {BackgroundTransparency = 1})
                elseif desc:IsA("UIStroke") then
                    Util.tween(desc, Tokens.Anim.Fast, {Transparency = 1})
                end
            end
            t.Completed:Wait()
            notifFrame:Destroy()
        end
    end)
end

-- ═══════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════
local Window = {}
Window.__index = Window

function FlavorUI.new(config)
    config = config or {}
    local self = setmetatable({}, Window)
    
    self.Title = config.Title or "Flavor UI"
    self.Size = config.Size or UDim2.new(0, 300, 0, 380)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Collapsed = false
    self.Visible = true
    self.Theme = "Light"
    
    self:_build()
    return self
end

function Window:_build()
    -- ScreenGui
    self.ScreenGui = Util.create("ScreenGui", {
        Name = "FlavorUI_" .. self.Title,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    -- Main container
    self.MainFrame = Util.create("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = self.Size,
        BackgroundColor3 = Tokens.Colors.SurfacePrimary,
        BackgroundTransparency = 0.01,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    Util.addCorner(self.MainFrame, Tokens.Radius.XLarge)
    Util.addStroke(self.MainFrame, Tokens.Colors.Separator, 1, 0.5)
    
    -- Shadow layers
    for i = 1, 3 do
        local shadowLayer = Util.create("Frame", {
            Name = "ShadowLayer" .. i,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, i * 2),
            Size = UDim2.new(1, i * 8, 1, i * 8),
            BackgroundColor3 = Tokens.Colors.Shadow,
            BackgroundTransparency = 0.93 + (i * 0.02),
            BorderSizePixel = 0,
            ZIndex = -i,
            Parent = self.MainFrame,
        })
        Util.addCorner(shadowLayer, UDim.new(0, 18 + i * 2))
    end
    
    -- === HEADER ===
    self.Header = Util.create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, Tokens.Height.Header),
        BackgroundColor3 = Tokens.Colors.SurfacePrimary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
    })
    
    -- Drag handle (Apple-style pill)
    local dragPill = Util.create("Frame", {
        Name = "DragPill",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 6),
        Size = UDim2.new(0, 36, 0, 4),
        BackgroundColor3 = Tokens.Colors.SeparatorLight,
        BorderSizePixel = 0,
        Parent = self.Header,
    })
    Util.addCorner(dragPill, Tokens.Radius.Full)
    
    -- Title
    self.TitleLabel = Util.create("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.new(1, -90, 0, 18),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Tokens.Font.Headline,
        TextSize = Tokens.Size.HeadlineText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.Header,
    })
    
    -- Close button (Apple × style)
    local closeBtn = Util.create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 2),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Tokens.Colors.SurfaceTertiary,
        BorderSizePixel = 0,
        Text = "✕",
        Font = Tokens.Font.Caption,
        TextSize = 10,
        TextColor3 = Tokens.Colors.TextTertiary,
        AutoButtonColor = false,
        Parent = self.Header,
    })
    Util.addCorner(closeBtn, Tokens.Radius.Full)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    closeBtn.MouseEnter:Connect(function()
        Util.tween(closeBtn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.Error, TextColor3 = Tokens.Colors.TextOnAccent})
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.tween(closeBtn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.SurfaceTertiary, TextColor3 = Tokens.Colors.TextTertiary})
    end)
    
    -- Minimize button
    local minBtn = Util.create("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -36, 0.5, 2),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Tokens.Colors.SurfaceTertiary,
        BorderSizePixel = 0,
        Text = "—",
        Font = Tokens.Font.Caption,
        TextSize = 10,
        TextColor3 = Tokens.Colors.TextTertiary,
        AutoButtonColor = false,
        Parent = self.Header,
    })
    Util.addCorner(minBtn, Tokens.Radius.Full)
    
    minBtn.MouseButton1Click:Connect(function()
        self:Collapse()
    end)
    minBtn.MouseEnter:Connect(function()
        Util.tween(minBtn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.Warning, TextColor3 = Tokens.Colors.TextOnAccent})
    end)
    minBtn.MouseLeave:Connect(function()
        Util.tween(minBtn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.SurfaceTertiary, TextColor3 = Tokens.Colors.TextTertiary})
    end)
    
    -- Header separator
    Util.create("Frame", {
        Name = "HeaderSep",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, -20, 0, 1),
        BackgroundColor3 = Tokens.Colors.SeparatorLight,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = self.Header,
    })
    
    -- === TAB BAR ===
    self.TabBarContainer = Util.create("Frame", {
        Name = "TabBarContainer",
        Position = UDim2.new(0, 0, 0, Tokens.Height.Header),
        Size = UDim2.new(1, 0, 0, Tokens.Height.TabBar + 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.MainFrame,
    })
    
    self.TabBarScroll = Util.create("ScrollingFrame", {
        Name = "TabBarScroll",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.X,
        CanvasSize = UDim2.new(0, 0, 1, 0),
        Parent = self.TabBarContainer,
    })
    Util.addPadding(self.TabBarScroll, 4, 10, 4, 10)
    
    self.TabBarLayout = Util.addListLayout(
        self.TabBarScroll, 4, 
        Enum.FillDirection.Horizontal, 
        Enum.HorizontalAlignment.Left, 
        Enum.VerticalAlignment.Center
    )
    
    -- Tab bar bottom separator
    Util.create("Frame", {
        Name = "TabBarSep",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, -20, 0, 1),
        BackgroundColor3 = Tokens.Colors.SeparatorLight,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = self.TabBarContainer,
    })
    
    -- === CONTENT AREA ===
    local contentY = Tokens.Height.Header + Tokens.Height.TabBar + 8
    self.ContentContainer = Util.create("Frame", {
        Name = "ContentContainer",
        Position = UDim2.new(0, 0, 0, contentY),
        Size = UDim2.new(1, 0, 1, -contentY),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.MainFrame,
    })
    
    -- === DRAG FUNCTIONALITY ===
    self:_setupDrag()
    
    -- === OPEN ANIMATION ===
    self.MainFrame.Size = UDim2.new(0, self.Size.X.Offset * 0.9, 0, self.Size.Y.Offset * 0.9)
    self.MainFrame.BackgroundTransparency = 0.5
    Util.tween(self.MainFrame, Tokens.Anim.Spring, {
        Size = self.Size,
        BackgroundTransparency = 0.01,
    })
end

function Window:_setupDrag()
    local dragging = false
    local dragStart, startPos
    
    self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            -- Subtle scale feedback
            Util.tween(self.MainFrame, Tokens.Anim.Fast, {})
        end
    end)
    
    self.Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            Util.tween(self.MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = newPos
            })
        end
    end)
end

function Window:Collapse()
    self.Collapsed = not self.Collapsed
    if self.Collapsed then
        self._savedSize = self.MainFrame.Size
        Util.tween(self.MainFrame, Tokens.Anim.Smooth, {
            Size = UDim2.new(0, self.Size.X.Offset, 0, Tokens.Height.Header),
        })
    else
        Util.tween(self.MainFrame, Tokens.Anim.Spring, {
            Size = self._savedSize or self.Size,
        })
    end
end

function Window:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self.ScreenGui.Enabled = true
        self.MainFrame.BackgroundTransparency = 1
        self.MainFrame.Size = UDim2.new(0, self.Size.X.Offset * 0.9, 0, self.Size.Y.Offset * 0.9)
        Util.tween(self.MainFrame, Tokens.Anim.Spring, {
            Size = self.Size,
            BackgroundTransparency = 0.01,
        })
        -- Fade in all children
        for _, desc in ipairs(self.MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                Util.tween(desc, Tokens.Anim.Normal, {TextTransparency = 0})
            end
        end
    else
        Util.tween(self.MainFrame, Tokens.Anim.Normal, {
            Size = UDim2.new(0, self.Size.X.Offset * 0.9, 0, self.Size.Y.Offset * 0.9),
            BackgroundTransparency = 1,
        }).Completed:Connect(function()
            self.ScreenGui.Enabled = false
        end)
    end
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- ═══════════════════════════════════════
-- TAB CLASS
-- ═══════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Window:AddTab(config)
    config = config or {}
    local tab = setmetatable({}, Tab)
    tab.Name = config.Name or "Tab"
    tab.Icon = config.Icon or ""
    tab.Window = self
    tab.Sections = {}
    tab.LayoutOrder = #self.Tabs + 1
    
    -- Tab button in tab bar
    local displayText = tab.Icon ~= "" and (tab.Icon .. "  " .. tab.Name) or tab.Name
    
    tab.Button = Util.create("TextButton", {
        Name = "Tab_" .. tab.Name,
        Size = UDim2.new(0, 0, 0, Tokens.Height.TabBar - 6),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Tokens.Colors.SurfaceTertiary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = displayText,
        Font = Tokens.Font.Label,
        TextSize = Tokens.Size.LabelText,
        TextColor3 = Tokens.Colors.TextTertiary,
        AutoButtonColor = false,
        LayoutOrder = tab.LayoutOrder,
        Parent = self.TabBarScroll,
    })
    Util.addCorner(tab.Button, Tokens.Radius.Medium)
    Util.addPadding(tab.Button, 0, 10, 0, 10)
    
    -- Tab content page
    tab.Page = Util.create("ScrollingFrame", {
        Name = "Page_" .. tab.Name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Tokens.Colors.TextTertiary,
        ScrollBarImageTransparency = 0.5,
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.ContentContainer,
    })
    Util.addPadding(tab.Page, 8, 12, 12, 12)
    Util.addListLayout(tab.Page, Tokens.Spacing.M)
    
    -- Tab button click
    tab.Button.MouseButton1Click:Connect(function()
        self:_switchTab(tab)
    end)
    
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Util.tween(tab.Button, Tokens.Anim.Fast, {
                BackgroundTransparency = 0.5,
                TextColor3 = Tokens.Colors.TextSecondary,
            })
        end
    end)
    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Util.tween(tab.Button, Tokens.Anim.Fast, {
                BackgroundTransparency = 1,
                TextColor3 = Tokens.Colors.TextTertiary,
            })
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:_switchTab(tab)
    end
    
    return tab
end

function Window:_switchTab(tab)
    if self.ActiveTab == tab then return end
    
    -- Deactivate old
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        Util.tween(self.ActiveTab.Button, Tokens.Anim.Fast, {
            BackgroundTransparency = 1,
            TextColor3 = Tokens.Colors.TextTertiary,
        })
    end
    
    -- Activate new
    self.ActiveTab = tab
    tab.Page.Visible = true
    Util.tween(tab.Button, Tokens.Anim.Normal, {
        BackgroundColor3 = Tokens.Colors.Accent,
        BackgroundTransparency = 0,
        TextColor3 = Tokens.Colors.TextOnAccent,
    })
    
    -- Subtle page fade in
    for _, child in ipairs(tab.Page:GetChildren()) do
        if child:IsA("Frame") then
            child.BackgroundTransparency = 1
            Util.tween(child, Tokens.Anim.Smooth, {
                BackgroundTransparency = 0,
            })
        end
    end
end

-- ═══════════════════════════════════════
-- SECTION
-- ═══════════════════════════════════════
local Section = {}
Section.__index = Section

function Tab:AddSection(config)
    config = config or {}
    local section = setmetatable({}, Section)
    section.Name = config.Name or ""
    section.Tab = self
    section.LayoutOrder = #self.Sections + 1
    
    section.Frame = Util.create("Frame", {
        Name = "Section_" .. section.Name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = section.LayoutOrder,
        Parent = self.Page,
    })
    Util.addCorner(section.Frame, Tokens.Radius.Large)
    Util.addStroke(section.Frame, Tokens.Colors.SeparatorLight, 1, 0.4)
    
    local innerContainer = Util.create("Frame", {
        Name = "Inner",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = section.Frame,
    })
    Util.addPadding(innerContainer, 6, 10, 8, 10)
    
    section.ContentLayout = Util.addListLayout(innerContainer, 1)
    section.ContentFrame = innerContainer
    
    -- Section header
    if section.Name ~= "" then
        Util.create("TextLabel", {
            Name = "SectionHeader",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = string.upper(section.Name),
            Font = Tokens.Font.Caption,
            TextSize = 9,
            TextColor3 = Tokens.Colors.TextTertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
            Parent = innerContainer,
        })
    end
    
    table.insert(self.Sections, section)
    return section
end

-- ═══════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════

-- Helper: create a row container (Apple Settings style)
local function createRow(parent, height, layoutOrder)
    local row = Util.create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, height or Tokens.Height.Row),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    return row
end

local function addRowSeparator(parent, layoutOrder)
    local sep = Util.create("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Tokens.Colors.SeparatorLight,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    return sep
end

-- ═══════════════════════════════════════
-- BUTTON
-- ═══════════════════════════════════════
function Section:AddButton(config)
    config = config or {}
    local name = config.Name or "Button"
    local description = config.Description or ""
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = createRow(self.ContentFrame, Tokens.Height.Row, layoutOrder)
    
    -- Label
    local labelFrame = Util.create("Frame", {
        Name = "LabelFrame",
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    if description ~= "" then
        Util.create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0.55, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Tokens.Font.Body,
            TextSize = Tokens.Size.BodyText,
            TextColor3 = Tokens.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = labelFrame,
        })
        Util.create("TextLabel", {
            Name = "Desc",
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0.45, 0),
            BackgroundTransparency = 1,
            Text = description,
            Font = Tokens.Font.Caption,
            TextSize = Tokens.Size.CaptionText - 1,
            TextColor3 = Tokens.Colors.TextTertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = labelFrame,
        })
    else
        Util.create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Tokens.Font.Body,
            TextSize = Tokens.Size.BodyText,
            TextColor3 = Tokens.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = labelFrame,
        })
    end
    
    -- Chevron / action indicator
    local chevron = Util.create("TextLabel", {
        Name = "Chevron",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "›",
        Font = Tokens.Font.Body,
        TextSize = 16,
        TextColor3 = Tokens.Colors.TextTertiary,
        Parent = row,
    })
    
    -- Click area
    local clickArea = Util.create("TextButton", {
        Name = "ClickArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Tokens.Colors.TextPrimary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = row,
    })
    
    clickArea.MouseButton1Click:Connect(function()
        -- Press feedback
        Util.tween(row, Tokens.Anim.Fast, {BackgroundTransparency = 0.92})
        task.delay(0.15, function()
            Util.tween(row, Tokens.Anim.Normal, {BackgroundTransparency = 1})
        end)
        callback()
    end)
    
    clickArea.MouseEnter:Connect(function()
        Util.tween(row, Tokens.Anim.Fast, {BackgroundTransparency = 0.95})
    end)
    clickArea.MouseLeave:Connect(function()
        Util.tween(row, Tokens.Anim.Fast, {BackgroundTransparency = 1})
    end)
    
    return {
        SetName = function(_, newName)
            labelFrame:FindFirstChild("Label").Text = newName
        end,
    }
end

-- ═══════════════════════════════════════
-- TOGGLE (iOS-style switch)
-- ═══════════════════════════════════════
function Section:AddToggle(config)
    config = config or {}
    local name = config.Name or "Toggle"
    local description = config.Description or ""
    local default = config.Default or false
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = createRow(self.ContentFrame, Tokens.Height.Row, layoutOrder)
    local toggled = default
    
    -- Label
    local labelFrame = Util.create("Frame", {
        Name = "LabelFrame",
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    if description ~= "" then
        Util.create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0.55, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Tokens.Font.Body,
            TextSize = Tokens.Size.BodyText,
            TextColor3 = Tokens.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = labelFrame,
        })
        Util.create("TextLabel", {
            Name = "Desc",
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0.45, 0),
            BackgroundTransparency = 1,
            Text = description,
            Font = Tokens.Font.Caption,
            TextSize = Tokens.Size.CaptionText - 1,
            TextColor3 = Tokens.Colors.TextTertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = labelFrame,
        })
    else
        Util.create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Tokens.Font.Body,
            TextSize = Tokens.Size.BodyText,
            TextColor3 = Tokens.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = labelFrame,
        })
    end
    
    -- iOS Toggle Switch
    local toggleWidth = 42
    local toggleHeight = Tokens.Height.Toggle
    local knobSize = toggleHeight - 4
    
    local toggleFrame = Util.create("TextButton", {
        Name = "ToggleSwitch",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, toggleWidth, 0, toggleHeight),
        BackgroundColor3 = toggled and Tokens.Colors.Accent or Tokens.Colors.ToggleOff,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    Util.addCorner(toggleFrame, Tokens.Radius.Full)
    
    local knob = Util.create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = toggled 
            and UDim2.new(1, -(knobSize + 2), 0.5, 0)
            or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, knobSize, 0, knobSize),
        BackgroundColor3 = Tokens.Colors.ToggleKnob,
        BorderSizePixel = 0,
        Parent = toggleFrame,
    })
    Util.addCorner(knob, Tokens.Radius.Full)
    
    -- Knob shadow
    Util.create("Frame", {
        Name = "KnobShadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 1),
        Size = UDim2.new(1, 2, 1, 2),
        BackgroundColor3 = Tokens.Colors.Shadow,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = knob.ZIndex - 1,
        Parent = knob,
    })
    Util.addCorner(knob:FindFirstChild("KnobShadow"), Tokens.Radius.Full)
    
    local function updateToggle()
        if toggled then
            Util.tween(toggleFrame, Tokens.Anim.Smooth, {
                BackgroundColor3 = Tokens.Colors.Accent,
            })
            Util.tween(knob, Tokens.Anim.Spring, {
                Position = UDim2.new(1, -(knobSize + 2), 0.5, 0),
            })
        else
            Util.tween(toggleFrame, Tokens.Anim.Smooth, {
                BackgroundColor3 = Tokens.Colors.ToggleOff,
            })
            Util.tween(knob, Tokens.Anim.Spring, {
                Position = UDim2.new(0, 2, 0.5, 0),
            })
        end
    end
    
    toggleFrame.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        callback(toggled)
    end)
    
    if default then
        callback(true)
    end
    
    return {
        Set = function(_, value)
            toggled = value
            updateToggle()
            callback(toggled)
        end,
        Get = function()
            return toggled
        end,
    }
end

-- ═══════════════════════════════════════
-- SLIDER (Material You style)
-- ═══════════════════════════════════════
function Section:AddSlider(config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local suffix = config.Suffix or ""
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = Util.create("Frame", {
        Name = "SliderRow",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder,
        Parent = self.ContentFrame,
    })
    
    local value = default
    
    -- Top row: label + value
    Util.create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = name,
        Font = Tokens.Font.Body,
        TextSize = Tokens.Size.BodyText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    local valueLabel = Util.create("TextLabel", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = tostring(value) .. suffix,
        Font = Tokens.Font.Label,
        TextSize = Tokens.Size.LabelText,
        TextColor3 = Tokens.Colors.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    
    -- Slider track
    local trackHeight = 4
    local thumbSize = 18
    
    local trackContainer = Util.create("Frame", {
        Name = "TrackContainer",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 26),
        Size = UDim2.new(1, -4, 0, 20),
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    local track = Util.create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, trackHeight),
        BackgroundColor3 = Tokens.Colors.SliderTrack,
        BorderSizePixel = 0,
        Parent = trackContainer,
    })
    Util.addCorner(track, Tokens.Radius.Full)
    
    local fill = Util.create("Frame", {
        Name = "Fill",
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Tokens.Colors.SliderFill,
        BorderSizePixel = 0,
        Parent = track,
    })
    Util.addCorner(fill, Tokens.Radius.Full)
    
    -- Thumb
    local thumb = Util.create("Frame", {
        Name = "Thumb",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.new(0, thumbSize, 0, thumbSize),
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = trackContainer,
    })
    Util.addCorner(thumb, Tokens.Radius.Full)
    Util.addStroke(thumb, Tokens.Colors.Accent, 2, 0)
    
    -- Thumb shadow
    Util.create("Frame", {
        Name = "ThumbShadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 1),
        Size = UDim2.new(1, 4, 1, 4),
        BackgroundColor3 = Tokens.Colors.Shadow,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = thumb,
    })
    Util.addCorner(thumb:FindFirstChild("ThumbShadow"), Tokens.Radius.Full)
    
    -- Interaction
    local dragging = false
    
    local function updateSlider(input)
        local relX = (input.Position.X - trackContainer.AbsolutePosition.X) / trackContainer.AbsoluteSize.X
        relX = math.clamp(relX, 0, 1)
        
        local rawValue = min + (max - min) * relX
        value = math.floor(rawValue / increment + 0.5) * increment
        value = math.clamp(value, min, max)
        
        local percent = (value - min) / (max - min)
        
        Util.tween(fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)})
        Util.tween(thumb, TweenInfo.new(0.05), {Position = UDim2.new(percent, 0, 0.5, 0)})
        valueLabel.Text = tostring(value) .. suffix
        
        callback(value)
    end
    
    local inputArea = Util.create("TextButton", {
        Name = "InputArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
        Parent = trackContainer,
    })
    
    inputArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            -- Thumb grow effect
            Util.tween(thumb, Tokens.Anim.Fast, {
                Size = UDim2.new(0, thumbSize + 4, 0, thumbSize + 4),
            })
            updateSlider(input)
        end
    end)
    
    inputArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Util.tween(thumb, Tokens.Anim.Spring, {
                Size = UDim2.new(0, thumbSize, 0, thumbSize),
            })
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateSlider(input)
        end
    end)
    
    return {
        Set = function(_, newValue)
            value = math.clamp(newValue, min, max)
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, 0, 0.5, 0)
            valueLabel.Text = tostring(value) .. suffix
            callback(value)
        end,
        Get = function()
            return value
        end,
    }
end

-- ═══════════════════════════════════════
-- TEXT INPUT (Fluent-style)
-- ═══════════════════════════════════════
function Section:AddInput(config)
    config = config or {}
    local name = config.Name or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local default = config.Default or ""
    local numeric = config.Numeric or false
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = Util.create("Frame", {
        Name = "InputRow",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder,
        Parent = self.ContentFrame,
    })
    
    Util.create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = name,
        Font = Tokens.Font.Body,
        TextSize = Tokens.Size.BodyText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    local inputFrame = Util.create("Frame", {
        Name = "InputFrame",
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Tokens.Colors.InputBackground,
        BorderSizePixel = 0,
        Parent = row,
    })
    Util.addCorner(inputFrame, Tokens.Radius.Medium)
    local inputStroke = Util.addStroke(inputFrame, Tokens.Colors.InputBorder, 1, 0.5)
    
    local textBox = Util.create("TextBox", {
        Name = "TextBox",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Tokens.Colors.TextTertiary,
        Font = Tokens.Font.Caption,
        TextSize = Tokens.Size.BodyText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        Parent = inputFrame,
    })
    
    textBox.Focused:Connect(function()
        Util.tween(inputStroke, Tokens.Anim.Fast, {
            Color = Tokens.Colors.InputFocusBorder,
            Transparency = 0,
            Thickness = 1.5,
        })
        Util.tween(inputFrame, Tokens.Anim.Fast, {
            BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        })
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        Util.tween(inputStroke, Tokens.Anim.Fast, {
            Color = Tokens.Colors.InputBorder,
            Transparency = 0.5,
            Thickness = 1,
        })
        Util.tween(inputFrame, Tokens.Anim.Fast, {
            BackgroundColor3 = Tokens.Colors.InputBackground,
        })
        
        local text = textBox.Text
        if numeric then
            text = tonumber(text) or 0
            textBox.Text = tostring(text)
        end
        callback(text)
    end)
    
    return {
        Set = function(_, newText)
            textBox.Text = tostring(newText)
            callback(newText)
        end,
        Get = function()
            return textBox.Text
        end,
    }
end

-- ═══════════════════════════════════════
-- DROPDOWN (Apple-style picker)
-- ═══════════════════════════════════════
function Section:AddDropdown(config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local default = config.Default or options[1]
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = Util.create("Frame", {
        Name = "DropdownRow",
        Size = UDim2.new(1, 0, 0, Tokens.Height.Row),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder,
        ClipsDescendants = false,
        Parent = self.ContentFrame,
    })
    
    local selected = default
    local isOpen = false
    
    Util.create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Tokens.Font.Body,
        TextSize = Tokens.Size.BodyText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    -- Selected value display
    local selectBtn = Util.create("TextButton", {
        Name = "SelectBtn",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.45, 0, 0, 26),
        BackgroundColor3 = Tokens.Colors.SurfaceTertiary,
        BorderSizePixel = 0,
        Text = selected .. "  ▾",
        Font = Tokens.Font.Caption,
        TextSize = Tokens.Size.CaptionText,
        TextColor3 = Tokens.Colors.Accent,
        AutoButtonColor = false,
        Parent = row,
    })
    Util.addCorner(selectBtn, Tokens.Radius.Medium)
    
    -- Dropdown menu
    local dropdownMenu = Util.create("Frame", {
        Name = "DropdownMenu",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 1, 4),
        Size = UDim2.new(0.55, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        ClipsDescendants = true,
        Parent = row,
    })
    Util.addCorner(dropdownMenu, Tokens.Radius.Medium)
    Util.addStroke(dropdownMenu, Tokens.Colors.Separator, 1, 0.3)
    
    local menuLayout = Util.addListLayout(dropdownMenu, 0)
    Util.addPadding(dropdownMenu, 2, 0, 2, 0)
    
    -- Populate options
    local function populateOptions()
        for _, child in ipairs(dropdownMenu:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for i, option in ipairs(options) do
            local optBtn = Util.create("TextButton", {
                Name = "Option_" .. option,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Tokens.Colors.SurfaceElevated,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Text = option == selected and ("✓  " .. option) or ("     " .. option),
                Font = option == selected and Tokens.Font.Label or Tokens.Font.Caption,
                TextSize = Tokens.Size.CaptionText,
                TextColor3 = option == selected and Tokens.Colors.Accent or Tokens.Colors.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 51,
                Parent = dropdownMenu,
            })
            Util.addPadding(optBtn, 0, 8, 0, 8)
            
            optBtn.MouseEnter:Connect(function()
                Util.tween(optBtn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.SurfaceSecondary})
            end)
            optBtn.MouseLeave:Connect(function()
                Util.tween(optBtn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.SurfaceElevated})
            end)
            optBtn.MouseButton1Click:Connect(function()
                selected = option
                selectBtn.Text = selected .. "  ▾"
                isOpen = false
                dropdownMenu.Visible = false
                populateOptions()
                callback(selected)
            end)
        end
    end
    populateOptions()
    
    selectBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownMenu.Visible = isOpen
        if isOpen then
            -- Ensure dropdown is on top
            dropdownMenu.ZIndex = 50
            for _, desc in ipairs(dropdownMenu:GetDescendants()) do
                if desc:IsA("TextButton") then desc.ZIndex = 51 end
            end
        end
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if isOpen and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            task.delay(0.1, function()
                if isOpen then
                    local pos = input.Position
                    local absPos = dropdownMenu.AbsolutePosition
                    local absSize = dropdownMenu.AbsoluteSize
                    if pos.X < absPos.X or pos.X > absPos.X + absSize.X 
                        or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
                        isOpen = false
                        dropdownMenu.Visible = false
                    end
                end
            end)
        end
    end)
    
    callback(selected)
    
    return {
        Set = function(_, value)
            selected = value
            selectBtn.Text = selected .. "  ▾"
            populateOptions()
            callback(selected)
        end,
        Get = function()
            return selected
        end,
        UpdateOptions = function(_, newOptions)
            options = newOptions
            populateOptions()
        end,
    }
end

-- ═══════════════════════════════════════
-- KEYBIND
-- ═══════════════════════════════════════
function Section:AddKeybind(config)
    config = config or {}
    local name = config.Name or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = createRow(self.ContentFrame, Tokens.Height.Row, layoutOrder)
    local currentKey = default
    local listening = false
    
    Util.create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Tokens.Font.Body,
        TextSize = Tokens.Size.BodyText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    local keyBtn = Util.create("TextButton", {
        Name = "KeyBtn",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 24),
        BackgroundColor3 = Tokens.Colors.SurfaceTertiary,
        BorderSizePixel = 0,
        Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None",
        Font = Tokens.Font.Caption,
        TextSize = Tokens.Size.CaptionText,
        TextColor3 = Tokens.Colors.TextSecondary,
        AutoButtonColor = false,
        Parent = row,
    })
    Util.addCorner(keyBtn, Tokens.Radius.Small)
    Util.addStroke(keyBtn, Tokens.Colors.Separator, 1, 0.5)
    
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        Util.tween(keyBtn, Tokens.Anim.Fast, {
            BackgroundColor3 = Tokens.Colors.AccentSoft,
            TextColor3 = Tokens.Colors.Accent,
        })
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode
            keyBtn.Text = currentKey.Name
            Util.tween(keyBtn, Tokens.Anim.Fast, {
                BackgroundColor3 = Tokens.Colors.SurfaceTertiary,
                TextColor3 = Tokens.Colors.TextSecondary,
            })
        end
        
        if not listening and input.KeyCode == currentKey and not gameProcessed then
            callback(currentKey)
        end
    end)
    
    return {
        Set = function(_, key)
            currentKey = key
            keyBtn.Text = key.Name
        end,
        Get = function()
            return currentKey
        end,
    }
end

-- ═══════════════════════════════════════
-- COLOR PICKER (Simplified)
-- ═══════════════════════════════════════
function Section:AddColorPicker(config)
    config = config or {}
    local name = config.Name or "Color"
    local default = config.Default or Color3.fromRGB(0, 122, 255)
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    if layoutOrder > 2 then
        addRowSeparator(self.ContentFrame, layoutOrder - 1)
    end
    
    local row = createRow(self.ContentFrame, Tokens.Height.Row, layoutOrder)
    local currentColor = default
    local pickerOpen = false
    
    Util.create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Tokens.Font.Body,
        TextSize = Tokens.Size.BodyText,
        TextColor3 = Tokens.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    -- Color preview swatch
    local swatch = Util.create("TextButton", {
        Name = "Swatch",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    Util.addCorner(swatch, Tokens.Radius.Medium)
    Util.addStroke(swatch, Tokens.Colors.Separator, 1, 0.3)
    
    -- Color picker panel
    local pickerPanel = Util.create("Frame", {
        Name = "PickerPanel",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 1, 4),
        Size = UDim2.new(0, 180, 0, 130),
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = row,
    })
    Util.addCorner(pickerPanel, Tokens.Radius.Large)
    Util.addStroke(pickerPanel, Tokens.Colors.Separator, 1, 0.3)
    Util.addPadding(pickerPanel, 8, 8, 8, 8)
    
    local pickerLayout = Util.addListLayout(pickerPanel, 6)
    
    -- Preset colors (2 rows of popular colors)
    local presets = {
        Color3.fromRGB(255, 59, 48),   -- Red
        Color3.fromRGB(255, 149, 0),   -- Orange
        Color3.fromRGB(255, 204, 0),   -- Yellow
        Color3.fromRGB(52, 199, 89),   -- Green
        Color3.fromRGB(0, 199, 190),   -- Teal
        Color3.fromRGB(0, 122, 255),   -- Blue
        Color3.fromRGB(88, 86, 214),   -- Indigo
        Color3.fromRGB(175, 82, 222),  -- Purple
        Color3.fromRGB(255, 45, 85),   -- Pink
        Color3.fromRGB(162, 132, 94),  -- Brown
        Color3.fromRGB(142, 142, 147), -- Gray
        Color3.fromRGB(28, 28, 30),    -- Black
    }
    
    local presetsGrid = Util.create("Frame", {
        Name = "Presets",
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = pickerPanel,
    })
    
    local gridLayout = Util.create("UIGridLayout", {
        CellSize = UDim2.new(0, 22, 0, 22),
        CellPadding = UDim2.new(0, 5, 0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = presetsGrid,
    })
    
    for _, color in ipairs(presets) do
        local presetBtn = Util.create("TextButton", {
            Name = "Preset",
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 51,
            Parent = presetsGrid,
        })
        Util.addCorner(presetBtn, Tokens.Radius.Small)
        
        presetBtn.MouseButton1Click:Connect(function()
            currentColor = color
            swatch.BackgroundColor3 = color
            callback(color)
            -- Add checkmark visual
            Util.tween(presetBtn, Tokens.Anim.Fast, {Size = UDim2.new(0, 18, 0, 18)})
            task.delay(0.1, function()
                Util.tween(presetBtn, Tokens.Anim.Spring, {Size = UDim2.new(0, 22, 0, 22)})
            end)
        end)
    end
    
    -- Hue slider
    local hueLabel = Util.create("TextLabel", {
        Name = "HueLabel",
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Text = "HUE",
        Font = Tokens.Font.Caption,
        TextSize = 8,
        TextColor3 = Tokens.Colors.TextTertiary,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 51,
        Parent = pickerPanel,
    })
    
    local hueTrack = Util.create("Frame", {
        Name = "HueTrack",
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 3,
        ZIndex = 51,
        Parent = pickerPanel,
    })
    Util.addCorner(hueTrack, Tokens.Radius.Full)
    
    -- Create rainbow gradient on hue track
    local hueGradient = Util.create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueTrack,
    })
    
    local hueThumb = Util.create("Frame", {
        Name = "HueThumb",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 18),
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = hueTrack,
    })
    Util.addCorner(hueThumb, Tokens.Radius.Small)
    Util.addStroke(hueThumb, Tokens.Colors.Separator, 1, 0)
    
    local hueInputArea = Util.create("TextButton", {
        Size = UDim2.new(1, 0, 1, 8),
        Position = UDim2.new(0, 0, 0, -4),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 53,
        Parent = hueTrack,
    })
    
    local hueDragging = false
    
    hueInputArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            local relX = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
            hueThumb.Position = UDim2.new(relX, 0, 0.5, 0)
            currentColor = Color3.fromHSV(relX, 1, 1)
            swatch.BackgroundColor3 = currentColor
            callback(currentColor)
        end
    end)
    
    hueInputArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local relX = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
            hueThumb.Position = UDim2.new(relX, 0, 0.5, 0)
            currentColor = Color3.fromHSV(relX, 1, 1)
            swatch.BackgroundColor3 = currentColor
            callback(currentColor)
        end
    end)
    
    swatch.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        pickerPanel.Visible = pickerOpen
    end)
    
    callback(currentColor)
    
    return {
        Set = function(_, color)
            currentColor = color
            swatch.BackgroundColor3 = color
            callback(color)
        end,
        Get = function()
            return currentColor
        end,
    }
end

-- ═══════════════════════════════════════
-- LABEL (Info text)
-- ═══════════════════════════════════════
function Section:AddLabel(config)
    config = config or {}
    local text = config.Text or "Label"
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    local label = Util.create("TextLabel", {
        Name = "InfoLabel",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text,
        Font = Tokens.Font.Caption,
        TextSize = Tokens.Size.CaptionText,
        TextColor3 = Tokens.Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = layoutOrder,
        Parent = self.ContentFrame,
    })
    
    return {
        Set = function(_, newText)
            label.Text = newText
        end,
    }
end

-- ═══════════════════════════════════════
-- PARAGRAPH (Multi-line info)
-- ═══════════════════════════════════════
function Section:AddParagraph(config)
    config = config or {}
    local title = config.Title or ""
    local content = config.Content or ""
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    local frame = Util.create("Frame", {
        Name = "Paragraph",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = self.ContentFrame,
    })
    Util.addListLayout(frame, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left)
    
    if title ~= "" then
        Util.create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = title,
            Font = Tokens.Font.Label,
            TextSize = Tokens.Size.LabelText,
            TextColor3 = Tokens.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 1,
            Parent = frame,
        })
    end
    
    local contentLabel = Util.create("TextLabel", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = content,
        Font = Tokens.Font.Caption,
        TextSize = Tokens.Size.CaptionText,
        TextColor3 = Tokens.Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 2,
        Parent = frame,
    })
    
    return {
        SetTitle = function(_, newTitle)
            local t = frame:FindFirstChild("Title")
            if t then t.Text = newTitle end
        end,
        SetContent = function(_, newContent)
            contentLabel.Text = newContent
        end,
    }
end

-- ═══════════════════════════════════════
-- MINI TOGGLE BUTTON (Accent Filled)
-- ═══════════════════════════════════════
function Section:AddAccentButton(config)
    config = config or {}
    local name = config.Name or "Action"
    local callback = config.Callback or function() end
    local layoutOrder = (#self.ContentFrame:GetChildren()) * 2
    
    local btnRow = Util.create("Frame", {
        Name = "AccentBtnRow",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = self.ContentFrame,
    })
    
    local btn = Util.create("TextButton", {
        Name = "AccentBtn",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Tokens.Colors.Accent,
        BorderSizePixel = 0,
        Text = name,
        Font = Tokens.Font.Label,
        TextSize = Tokens.Size.LabelText,
        TextColor3 = Tokens.Colors.TextOnAccent,
        AutoButtonColor = false,
        Parent = btnRow,
    })
    Util.addCorner(btn, Tokens.Radius.Medium)
    
    btn.MouseButton1Click:Connect(function()
        -- Press animation
        Util.tween(btn, Tokens.Anim.Fast, {
            BackgroundColor3 = Tokens.Colors.AccentPressed,
            Size = UDim2.new(1, -4, 0, 28),
        })
        task.delay(0.12, function()
            Util.tween(btn, Tokens.Anim.Spring, {
                BackgroundColor3 = Tokens.Colors.Accent,
                Size = UDim2.new(1, 0, 0, 30),
            })
        end)
        callback()
    end)
    
    btn.MouseEnter:Connect(function()
        Util.tween(btn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.AccentHover})
    end)
    btn.MouseLeave:Connect(function()
        Util.tween(btn, Tokens.Anim.Fast, {BackgroundColor3 = Tokens.Colors.Accent})
    end)
    
    return {
        SetName = function(_, newName)
            btn.Text = newName
        end,
    }
end

-- ═══════════════════════════════════════
-- TOGGLE KEYBIND (for mobile: show/hide)
-- ═══════════════════════════════════════
function FlavorUI.CreateToggleButton(window, config)
    config = config or {}
    local position = config.Position or UDim2.new(0, 16, 0.5, 0)
    
    local toggleBtn = Util.create("TextButton", {
        Name = "FlavorToggle",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = position,
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = Tokens.Colors.SurfaceElevated,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = "◆",
        Font = Tokens.Font.Headline,
        TextSize = 14,
        TextColor3 = Tokens.Colors.Accent,
        AutoButtonColor = false,
        Parent = window.ScreenGui,
    })
    Util.addCorner(toggleBtn, Tokens.Radius.Full)
    Util.addStroke(toggleBtn, Tokens.Colors.Separator, 1, 0.5)
    
    -- Shadow for toggle button
    local btnShadow = Util.create("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 2),
        Size = UDim2.new(1, 6, 1, 6),
        BackgroundColor3 = Tokens.Colors.Shadow,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        ZIndex = toggleBtn.ZIndex - 1,
        Parent = toggleBtn,
    })
    Util.addCorner(btnShadow, Tokens.Radius.Full)
    
    -- Draggable toggle button
    local dragToggle = false
    local dragToggleStart, toggleStartPos
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragToggleStart = input.Position
            toggleStartPos = toggleBtn.Position
        end
    end)
    
    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragToggle then
                local delta = input.Position - dragToggleStart
                if delta.Magnitude < 5 then
                    -- It's a tap, not a drag
                    window:Toggle()
                end
            end
            dragToggle = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragToggleStart
            toggleBtn.Position = UDim2.new(
                toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
                toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return toggleBtn
end

-- ═══════════════════════════════════════
-- RETURN LIBRARY
-- ═══════════════════════════════════════
return FlavorUI