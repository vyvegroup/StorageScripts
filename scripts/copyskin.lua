-- Copy Skin Script V3 - FULL ACCESSORIES
-- Hỗ trợ tất cả loại accessory, nhiều accessory cùng lúc
-- Works on Executors - Mobile Friendly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local WearRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear")
local ChangeBodyColorRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChangeBodyColor")

-- Xóa GUI cũ
if game:GetService("CoreGui"):FindFirstChild("CopySkinGui") then
	game:GetService("CoreGui"):FindFirstChild("CopySkinGui"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CopySkinGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- ============================================
-- TOGGLE BUTTON
-- ============================================

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
ToggleButton.Text = "👤"
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.ZIndex = 100
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 25)
local ts = Instance.new("UIStroke", ToggleButton)
ts.Color = Color3.fromRGB(50, 120, 200)
ts.Thickness = 2

local draggingToggle = false
local dragStartToggle, startPosToggle, dragMoved

ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingToggle = true
		dragMoved = false
		dragStartToggle = input.Position
		startPosToggle = ToggleButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingToggle and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStartToggle
		if delta.Magnitude > 5 then dragMoved = true end
		ToggleButton.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingToggle = false
	end
end)

-- ============================================
-- MAIN FRAME
-- ============================================

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 540)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -270)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local ms = Instance.new("UIStroke", MainFrame)
ms.Color = Color3.fromRGB(85, 170, 255)
ms.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 51
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 51
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎭 COPY SKIN V3"
TitleLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 52
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 52
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Drag Main
local draggingMain = false
local dragStartMain, startPosMain

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMain = true
		dragStartMain = input.Position
		startPosMain = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingMain and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStartMain
		MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMain = false
	end
end)

-- Content
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -55)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 51
ContentFrame.Parent = MainFrame

-- Search
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, 0, 0, 38)
SearchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SearchFrame.BorderSizePixel = 0
SearchFrame.ZIndex = 52
SearchFrame.Parent = ContentFrame
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -15, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "🔍 Tìm kiếm người chơi..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 53
SearchBox.Parent = SearchFrame

-- Label
local DropdownLabel = Instance.new("TextLabel")
DropdownLabel.Size = UDim2.new(1, 0, 0, 22)
DropdownLabel.Position = UDim2.new(0, 0, 0, 43)
DropdownLabel.BackgroundTransparency = 1
DropdownLabel.Text = "📋 Chọn người chơi:"
DropdownLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
DropdownLabel.TextSize = 13
DropdownLabel.Font = Enum.Font.GothamSemibold
DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
DropdownLabel.ZIndex = 52
DropdownLabel.Parent = ContentFrame

-- Player List
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, 0, 0, 160)
PlayerListFrame.Position = UDim2.new(0, 0, 0, 67)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 4
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(85, 170, 255)
PlayerListFrame.ZIndex = 52
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.Parent = ContentFrame
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 8)

local PlayerListLayout = Instance.new("UIListLayout", PlayerListFrame)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 3)

local plPad = Instance.new("UIPadding", PlayerListFrame)
plPad.PaddingTop = UDim.new(0, 5)
plPad.PaddingLeft = UDim.new(0, 5)
plPad.PaddingRight = UDim.new(0, 5)

-- Selected
local SelectedFrame = Instance.new("Frame")
SelectedFrame.Size = UDim2.new(1, 0, 0, 35)
SelectedFrame.Position = UDim2.new(0, 0, 0, 233)
SelectedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SelectedFrame.BorderSizePixel = 0
SelectedFrame.ZIndex = 52
SelectedFrame.Parent = ContentFrame
Instance.new("UICorner", SelectedFrame).CornerRadius = UDim.new(0, 8)

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1, -10, 1, 0)
SelectedLabel.Position = UDim2.new(0, 10, 0, 0)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "✨ Chưa chọn ai"
SelectedLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
SelectedLabel.TextSize = 13
SelectedLabel.Font = Enum.Font.GothamSemibold
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.ZIndex = 53
SelectedLabel.Parent = SelectedFrame

-- Copy Button
local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(1, 0, 0, 45)
CopyButton.Position = UDim2.new(0, 0, 0, 275)
CopyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
CopyButton.Text = "🎭 COPY SKIN"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 16
CopyButton.Font = Enum.Font.GothamBold
CopyButton.BorderSizePixel = 0
CopyButton.ZIndex = 52
CopyButton.Parent = ContentFrame
Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 10)

-- Status
local StatusFrame = Instance.new("ScrollingFrame")
StatusFrame.Size = UDim2.new(1, 0, 0, 140)
StatusFrame.Position = UDim2.new(0, 0, 0, 327)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusFrame.BorderSizePixel = 0
StatusFrame.ScrollBarThickness = 3
StatusFrame.ScrollBarImageColor3 = Color3.fromRGB(85, 170, 255)
StatusFrame.ZIndex = 52
StatusFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
StatusFrame.Parent = ContentFrame
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 8)

local StatusLayout = Instance.new("UIListLayout", StatusFrame)
StatusLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatusLayout.Padding = UDim.new(0, 2)

local stPad = Instance.new("UIPadding", StatusFrame)
stPad.PaddingTop = UDim.new(0, 5)
stPad.PaddingLeft = UDim.new(0, 8)
stPad.PaddingRight = UDim.new(0, 8)

-- ============================================
-- STATUS FUNCTIONS
-- ============================================

local statusCount = 0

local function AddStatus(text, color)
	color = color or Color3.fromRGB(180, 180, 200)
	statusCount += 1
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextSize = 11
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.LayoutOrder = statusCount
	label.ZIndex = 53
	label.Parent = StatusFrame
	task.defer(function()
		StatusFrame.CanvasSize = UDim2.new(0, 0, 0, StatusLayout.AbsoluteContentSize.Y + 10)
		StatusFrame.CanvasPosition = Vector2.new(0, math.max(0, StatusLayout.AbsoluteContentSize.Y - StatusFrame.AbsoluteSize.Y))
	end)
end

local function ClearStatus()
	for _, c in pairs(StatusFrame:GetChildren()) do
		if c:IsA("TextLabel") then c:Destroy() end
	end
	statusCount = 0
end

-- ============================================
-- VARIABLES
-- ============================================

local SelectedPlayer = nil
local menuOpen = false
local isCopying = false

-- Toggle
ToggleButton.MouseButton1Click:Connect(function()
	if dragMoved then return end
	menuOpen = not menuOpen
	MainFrame.Visible = menuOpen
end)

CloseBtn.MouseButton1Click:Connect(function()
	menuOpen = false
	MainFrame.Visible = false
end)

-- ============================================
-- PLAYER LIST
-- ============================================

local function CreatePlayerButton(player)
	if player == LocalPlayer then return end

	local btn = Instance.new("TextButton")
	btn.Name = "P_" .. player.Name
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
	btn.BorderSizePixel = 0
	btn.ZIndex = 53
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = PlayerListFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 25, 0, 25)
	avatar.Position = UDim2.new(0, 8, 0.5, -12)
	avatar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	avatar.ZIndex = 54
	avatar.Parent = btn
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 12)
	pcall(function()
		avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -75, 1, 0)
	nameLabel.Position = UDim2.new(0, 40, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 54
	nameLabel.Parent = btn

	local selectDot = Instance.new("Frame")
	selectDot.Name = "SelectDot"
	selectDot.Size = UDim2.new(0, 10, 0, 10)
	selectDot.Position = UDim2.new(1, -20, 0.5, -5)
	selectDot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
	selectDot.ZIndex = 54
	selectDot.Parent = btn
	Instance.new("UICorner", selectDot).CornerRadius = UDim.new(0, 5)

	btn.MouseButton1Click:Connect(function()
		SelectedPlayer = player
		for _, child in pairs(PlayerListFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
				local dot = child:FindFirstChild("SelectDot")
				if dot then dot.BackgroundColor3 = Color3.fromRGB(80, 80, 100) end
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(55, 85, 130)
		selectDot.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
		SelectedLabel.Text = "✨ " .. player.DisplayName .. " (@" .. player.Name .. ")"
	end)
end

local function RefreshPlayerList(filter)
	filter = string.lower(filter or "")
	for _, c in pairs(PlayerListFrame:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local n = string.lower(player.Name)
			local d = string.lower(player.DisplayName)
			if filter == "" or string.find(n, filter) or string.find(d, filter) then
				CreatePlayerButton(player)
			end
		end
	end
	task.wait(0.1)
	PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
end

RefreshPlayerList()

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	RefreshPlayerList(SearchBox.Text)
end)

Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList(SearchBox.Text) end)
Players.PlayerRemoving:Connect(function(p)
	if SelectedPlayer == p then
		SelectedPlayer = nil
		SelectedLabel.Text = "✨ Chưa chọn ai"
	end
	task.wait(0.5)
	RefreshPlayerList(SearchBox.Text)
end)

-- ============================================
-- ACCESSORY TYPE MAP (ĐẦY ĐỦ TẤT CẢ LOẠI)
-- ============================================

local AccessoryTypeNames = {
	[Enum.AccessoryType.Hat] = "🎩 Hat",
	[Enum.AccessoryType.Hair] = "💇 Hair",
	[Enum.AccessoryType.Face] = "🥽 FaceAcc",
	[Enum.AccessoryType.Neck] = "📿 Neck",
	[Enum.AccessoryType.Shoulder] = "🦺 Shoulder",
	[Enum.AccessoryType.Front] = "🎽 Front",
	[Enum.AccessoryType.Back] = "🎒 Back",
	[Enum.AccessoryType.Waist] = "🩲 Waist",
	[Enum.AccessoryType.Unknown] = "❓ Unknown",
}

-- Thêm các loại mới nếu tồn tại
pcall(function() AccessoryTypeNames[Enum.AccessoryType.TShirt] = "👕 TShirtAcc" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Jacket] = "🧥 Jacket" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Sweater] = "🧶 Sweater" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Shorts] = "🩳 Shorts" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Pants] = "👖 PantsAcc" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Skirt] = "👗 Skirt" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.DressSkirt] = "👗 DressSkirt" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.RightShoe] = "👟 RightShoe" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.LeftShoe] = "👟 LeftShoe" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Eyebrow] = "🤨 Eyebrow" end)
pcall(function() AccessoryTypeNames[Enum.AccessoryType.Eyelash] = "👁 Eyelash" end)

-- ============================================
-- DEEP SCAN - LẤY TẤT CẢ IDs TỪ MỘT PLAYER
-- ============================================

local function DeepScanItems(player)
	local allIds = {}
	local bodyColorName = nil
	local idSet = {} -- Tránh trùng lặp

	local function AddId(id, source)
		if id and id ~= 0 and not idSet[id] then
			idSet[id] = true
			table.insert(allIds, {id = id, source = source})
			return true
		end
		return false
	end

	local function ExtractId(str)
		if not str or str == "" then return nil end
		return tonumber(string.match(tostring(str), "%d+"))
	end

	local character = player.Character
	if not character then
		AddStatus("⚠ Character không tồn tại!", Color3.fromRGB(255, 100, 100))
		return allIds, bodyColorName
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		AddStatus("⚠ Humanoid không tồn tại!", Color3.fromRGB(255, 100, 100))
		return allIds, bodyColorName
	end

	-- ========================================
	-- 1. MÀU DA
	-- ========================================
	AddStatus("🎨 [1/6] Scan màu da...", Color3.fromRGB(150, 200, 255))

	local bodyColors = character:FindFirstChildOfClass("BodyColors")
	if bodyColors then
		bodyColorName = BrickColor.new(bodyColors.TorsoColor3).Name
		AddStatus("  🎨 TorsoColor: " .. bodyColorName, Color3.fromRGB(255, 200, 150))

		-- Log tất cả body colors chi tiết
		local colorParts = {
			{"HeadColor", bodyColors.HeadColor3},
			{"TorsoColor", bodyColors.TorsoColor3},
			{"LeftArmColor", bodyColors.LeftArmColor3},
			{"RightArmColor", bodyColors.RightArmColor3},
			{"LeftLegColor", bodyColors.LeftLegColor3},
			{"RightLegColor", bodyColors.RightLegColor3},
		}
		for _, cp in ipairs(colorParts) do
			AddStatus("    " .. cp[1] .. ": " .. BrickColor.new(cp[2]).Name, Color3.fromRGB(200, 180, 150))
		end
	else
		pcall(function()
			local part = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
			if part then
				bodyColorName = BrickColor.new(part.Color).Name
				AddStatus("  🎨 Màu da (part): " .. bodyColorName, Color3.fromRGB(255, 200, 150))
			end
		end)
	end

	if not bodyColorName then
		pcall(function()
			local desc = humanoid:GetAppliedDescription()
			if desc then
				local headCol = desc.HeadColor
				if headCol and headCol ~= Color3.new(0, 0, 0) then
					bodyColorName = BrickColor.new(headCol).Name
					AddStatus("  🎨 Màu da (desc): " .. bodyColorName, Color3.fromRGB(255, 200, 150))
				end
			end
		end)
	end

	-- ========================================
	-- 2. HUMANOID DESCRIPTION - ĐẦY ĐỦ
	-- ========================================
	AddStatus("📋 [2/6] Scan HumanoidDescription...", Color3.fromRGB(150, 200, 255))

	local desc = nil
	pcall(function()
		desc = humanoid:GetAppliedDescription()
	end)

	if desc then
		-- Clothing IDs
		local clothingMap = {
			{prop = "Shirt", emoji = "👕"},
			{prop = "Pants", emoji = "👖"},
			{prop = "GraphicTShirt", emoji = "👕"},
		}
		for _, info in ipairs(clothingMap) do
			pcall(function()
				local val = desc[info.prop]
				if val and val ~= 0 then
					if AddId(val, info.prop) then
						AddStatus("  " .. info.emoji .. " " .. info.prop .. ": " .. val, Color3.fromRGB(180, 255, 180))
					end
				end
			end)
		end

		-- Body Part IDs
		local bodyMap = {
			{prop = "Head", emoji = "🗣"},
			{prop = "Face", emoji = "😊"},
			{prop = "Torso", emoji = "🫁"},
			{prop = "LeftArm", emoji = "💪"},
			{prop = "RightArm", emoji = "💪"},
			{prop = "LeftLeg", emoji = "🦵"},
			{prop = "RightLeg", emoji = "🦵"},
		}
		for _, info in ipairs(bodyMap) do
			pcall(function()
				local val = desc[info.prop]
				if val and val ~= 0 then
					if AddId(val, info.prop) then
						AddStatus("  " .. info.emoji .. " " .. info.prop .. ": " .. val, Color3.fromRGB(180, 255, 180))
					end
				end
			end)
		end

		-- TẤT CẢ ACCESSORY PROPERTIES (bao gồm nhiều ID phân cách bởi dấu phẩy)
		local accDescProps = {
			{prop = "HatAccessory", emoji = "🎩"},
			{prop = "HairAccessory", emoji = "💇"},
			{prop = "FaceAccessory", emoji = "🥽"},
			{prop = "NeckAccessory", emoji = "📿"},
			{prop = "ShouldersAccessory", emoji = "🦺"},
			{prop = "FrontAccessory", emoji = "🎽"},
			{prop = "BackAccessory", emoji = "🎒"},
			{prop = "WaistAccessory", emoji = "🩲"},
		}

		for _, info in ipairs(accDescProps) do
			pcall(function()
				local val = desc[info.prop]
				if val and val ~= "" then
					local ids = string.split(tostring(val), ",")
					for _, rawId in ipairs(ids) do
						local numId = tonumber(string.gsub(rawId, "%s+", ""))
						if numId and numId ~= 0 then
							if AddId(numId, info.prop) then
								AddStatus("  " .. info.emoji .. " " .. info.prop .. ": " .. numId, Color3.fromRGB(255, 220, 150))
							end
						end
					end
				end
			end)
		end

		-- LAYERED CLOTHING ACCESSORIES (Mới)
		pcall(function()
			local layeredProps = {
				"TShirtAccessory", "JacketAccessory", "SweaterAccessory",
				"ShortsAccessory", "PantsAccessory", "SkirtAccessory",
				"DressSkirtAccessory", "RightShoeAccessory", "LeftShoeAccessory",
				"EyebrowAccessory", "EyelashAccessory", "MoodAnimation",
			}
			for _, prop in ipairs(layeredProps) do
				pcall(function()
					local val = desc[prop]
					if val then
						-- Có thể là number hoặc string
						if type(val) == "number" and val ~= 0 then
							if AddId(val, prop) then
								AddStatus("  🧥 " .. prop .. ": " .. val, Color3.fromRGB(255, 180, 220))
							end
						elseif type(val) == "string" and val ~= "" then
							for _, rawId in ipairs(string.split(val, ",")) do
								local numId = tonumber(string.gsub(rawId, "%s+", ""))
								if numId and numId ~= 0 then
									if AddId(numId, prop) then
										AddStatus("  🧥 " .. prop .. ": " .. numId, Color3.fromRGB(255, 180, 220))
									end
								end
							end
						end
					end
				end)
			end
		end)

		-- ANIMATIONS
		local animProps = {
			"IdleAnimation", "WalkAnimation", "RunAnimation",
			"JumpAnimation", "FallAnimation", "ClimbAnimation",
			"SwimAnimation", "MoodAnimation",
		}
		for _, prop in ipairs(animProps) do
			pcall(function()
				local val = desc[prop]
				if val and val ~= 0 then
					if AddId(val, prop) then
						AddStatus("  🏃 " .. prop .. ": " .. val, Color3.fromRGB(200, 180, 255))
					end
				end
			end)
		end

		-- EMOTES
		pcall(function()
			local emotes = desc:GetEmotes()
			for emoteName, emoteIds in pairs(emotes) do
				for _, emoteId in ipairs(emoteIds) do
					if AddId(emoteId, "Emote:" .. emoteName) then
						AddStatus("  💃 Emote " .. emoteName .. ": " .. emoteId, Color3.fromRGB(255, 150, 255))
					end
				end
			end
		end)

		-- EQUIPPED EMOTES
		pcall(function()
			local equipped = desc:GetEquippedEmotes()
			for _, emoteInfo in ipairs(equipped) do
				if emoteInfo.Slot and emoteInfo.Name then
					AddStatus("    📌 Emote Slot " .. emoteInfo.Slot .. ": " .. emoteInfo.Name, Color3.fromRGB(220, 150, 255))
				end
			end
		end)

		-- ACCESS LOCKING THINGS VIA GETACCESSORIES
		pcall(function()
			local descAccessories = desc:GetAccessories(true) -- includeRigidAccessories
			for _, accInfo in ipairs(descAccessories) do
				if accInfo.AssetId and accInfo.AssetId ~= 0 then
					local typeName = "Unknown"
					if accInfo.AccessoryType then
						typeName = AccessoryTypeNames[accInfo.AccessoryType] or tostring(accInfo.AccessoryType)
					end
					if AddId(accInfo.AssetId, "DescAcc:" .. typeName) then
						AddStatus("  🎀 DescAccessory " .. typeName .. ": " .. accInfo.AssetId, Color3.fromRGB(255, 200, 100))
					end
					-- Log thêm order nếu có
					if accInfo.Order then
						AddStatus("    📌 Order: " .. accInfo.Order, Color3.fromRGB(180, 180, 200))
					end
					if accInfo.IsLayered then
						AddStatus("    📌 IsLayered: true", Color3.fromRGB(180, 180, 200))
					end
				end
			end
		end)
	else
		AddStatus("  ⚠ Không đọc được Description", Color3.fromRGB(255, 200, 100))
	end

	-- ========================================
	-- 3. SCAN TẤT CẢ ACCESSORIES TRÊN CHARACTER (TRỰC TIẾP)
	-- ========================================
	AddStatus("🎀 [3/6] Scan accessories trên character...", Color3.fromRGB(150, 200, 255))

	local accessoryCount = 0
	for _, obj in pairs(character:GetChildren()) do
		if obj:IsA("Accessory") then
			accessoryCount += 1
			local accTypeName = "❓ Unknown"

			-- Lấy AccessoryType
			pcall(function()
				if obj.AccessoryType then
					accTypeName = AccessoryTypeNames[obj.AccessoryType] or tostring(obj.AccessoryType)
				end
			end)

			local handle = obj:FindFirstChild("Handle")
			if handle then
				-- SpecialMesh
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				if mesh then
					if mesh.MeshId and mesh.MeshId ~= "" then
						local id = ExtractId(mesh.MeshId)
						if id and AddId(id, "CharAcc_Mesh:" .. obj.Name) then
							AddStatus("  🎀 " .. accTypeName .. " [" .. obj.Name .. "] MeshId: " .. id, Color3.fromRGB(255, 200, 150))
						end
					end
					if mesh.TextureId and mesh.TextureId ~= "" then
						local texId = ExtractId(mesh.TextureId)
						if texId then
							AddStatus("    🖼 TextureId: " .. texId, Color3.fromRGB(180, 180, 200))
						end
					end
				end

				-- MeshPart (Layered Clothing)
				if handle:IsA("MeshPart") then
					if handle.MeshId and handle.MeshId ~= "" then
						local id = ExtractId(handle.MeshId)
						if id and AddId(id, "CharAcc_MeshPart:" .. obj.Name) then
							AddStatus("  🧥 " .. accTypeName .. " [" .. obj.Name .. "] MeshPart: " .. id, Color3.fromRGB(255, 180, 220))
						end
					end
					if handle.TextureID and handle.TextureID ~= "" then
						local texId = ExtractId(handle.TextureID)
						if texId then
							AddStatus("    🖼 TextureID: " .. texId, Color3.fromRGB(180, 180, 200))
						end
					end
				end

				-- WrapLayer (Layered Clothing data)
				for _, child in pairs(handle:GetChildren()) do
					if child:IsA("WrapLayer") then
						AddStatus("    🧥 WrapLayer found: " .. child.Name, Color3.fromRGB(220, 180, 255))
						pcall(function()
							if child.CageMeshId and child.CageMeshId ~= "" then
								local cId = ExtractId(child.CageMeshId)
								if cId then AddStatus("      CageMesh: " .. cId, Color3.fromRGB(180, 180, 200)) end
							end
						end)
					end
					if child:IsA("WrapTarget") then
						AddStatus("    🧥 WrapTarget found: " .. child.Name, Color3.fromRGB(220, 180, 255))
					end
				end

				-- Tìm thêm StringValue hoặc IntValue chứa asset ID
				for _, child in pairs(handle:GetChildren()) do
					if child:IsA("IntValue") or child:IsA("NumberValue") then
						if child.Value > 100 then
							if AddId(child.Value, "AccValue:" .. obj.Name .. "." .. child.Name) then
								AddStatus("  📦 " .. obj.Name .. "." .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
							end
						end
					end
				end
			end

			-- Tìm assetId trong Accessory object trực tiếp
			for _, child in pairs(obj:GetChildren()) do
				if child:IsA("IntValue") or child:IsA("NumberValue") then
					if child.Value > 100 then
						if AddId(child.Value, "AccDirect:" .. obj.Name .. "." .. child.Name) then
							AddStatus("  📦 " .. obj.Name .. "." .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
						end
					end
				end
			end
		end
	end

	AddStatus("  📊 Tổng accessories trên char: " .. accessoryCount, Color3.fromRGB(200, 200, 220))

	-- ========================================
	-- 4. SCAN CLOTHING TRỰC TIẾP
	-- ========================================
	AddStatus("👕 [4/6] Scan clothing objects...", Color3.fromRGB(150, 200, 255))

	for _, obj in pairs(character:GetChildren()) do
		if obj:IsA("Shirt") and obj.ShirtTemplate ~= "" then
			local id = ExtractId(obj.ShirtTemplate)
			if id and AddId(id, "ShirtTemplate") then
				AddStatus("  👕 Shirt: " .. id, Color3.fromRGB(180, 255, 180))
			end
		end
		if obj:IsA("Pants") and obj.PantsTemplate ~= "" then
			local id = ExtractId(obj.PantsTemplate)
			if id and AddId(id, "PantsTemplate") then
				AddStatus("  👖 Pants: " .. id, Color3.fromRGB(180, 255, 180))
			end
		end
		if obj:IsA("ShirtGraphic") then
			pcall(function()
				if obj.Graphic and obj.Graphic ~= "" then
					local id = ExtractId(obj.Graphic)
					if id and AddId(id, "TShirtGraphic") then
						AddStatus("  👕 T-Shirt: " .. id, Color3.fromRGB(180, 255, 180))
					end
				end
			end)
		end
	end

	-- Face Decal
	local head = character:FindFirstChild("Head")
	if head then
		for _, child in pairs(head:GetChildren()) do
			if child:IsA("Decal") and child.Name == "face" then
				local id = ExtractId(child.Texture)
				if id and AddId(id, "FaceDecal") then
					AddStatus("  😊 Face Decal: " .. id, Color3.fromRGB(255, 220, 150))
				end
			end
		end
	end

	-- ========================================
	-- 5. SCAN BODY PARTS (MeshPart IDs)
	-- ========================================
	AddStatus("🦴 [5/6] Scan body parts...", Color3.fromRGB(150, 200, 255))

	local bodyPartNames = {
		"Head", "UpperTorso", "LowerTorso",
		"LeftUpperArm", "LeftLowerArm", "LeftHand",
		"RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
		"RightUpperLeg", "RightLowerLeg", "RightFoot",
		-- R6
		"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
	}

	for _, partName in ipairs(bodyPartNames) do
		local part = character:FindFirstChild(partName)
		if part then
			if part:IsA("MeshPart") and part.MeshId ~= "" then
				local id = ExtractId(part.MeshId)
				if id and AddId(id, "BodyPart:" .. partName) then
					AddStatus("  🦴 " .. partName .. ": " .. id, Color3.fromRGB(180, 220, 255))
				end
			end
			-- SpecialMesh trong part
			local sm = part:FindFirstChildOfClass("SpecialMesh")
			if sm and sm.MeshId ~= "" then
				local id = ExtractId(sm.MeshId)
				if id and AddId(id, "BodyPartMesh:" .. partName) then
					AddStatus("  🦴 " .. partName .. " Mesh: " .. id, Color3.fromRGB(180, 220, 255))
				end
			end
		end
	end

	-- ========================================
	-- 6. SCAN DATA VALUES
	-- ========================================
	AddStatus("📦 [6/6] Scan data values...", Color3.fromRGB(150, 200, 255))

	-- Character values
	for _, child in pairs(character:GetDescendants()) do
		if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 1000 and child.Name ~= "Health" and child.Name ~= "WalkSpeed" and child.Name ~= "JumpPower" and child.Name ~= "JumpHeight" and child.Name ~= "MaxHealth" then
			if AddId(child.Value, "CharValue:" .. child.Name) then
				AddStatus("  📦 " .. child:GetFullName():gsub(character:GetFullName() .. ".", "") .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
			end
		end
	end

	-- Player data folders
	pcall(function()
		local folderNames = {"Data", "PlayerData", "Stats", "Inventory", "Outfit", "Cosmetics", "Equipment", "Wardrobe", "Clothes", "Skins", "Equipped", "Wearing"}
		for _, folderName in ipairs(folderNames) do
			local folder = player:FindFirstChild(folderName)
			if folder then
				AddStatus("  📂 Found: " .. folderName, Color3.fromRGB(180, 200, 255))
				for _, child in pairs(folder:GetDescendants()) do
					if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 1000 then
						if AddId(child.Value, "PlayerData:" .. folderName .. "." .. child.Name) then
							AddStatus("    📦 " .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
						end
					end
				end
			end
		end
	end)

	return allIds, bodyColorName
end

-- ============================================
-- LẤY ITEMS ĐANG MẶC CỦA MÌNH
-- ============================================

local function GetMyCurrentItems()
	local myIds = {}
	local idSet = {}

	local function AddMyId(id)
		if id and id ~= 0 and not idSet[id] then
			idSet[id] = true
			table.insert(myIds, id)
		end
	end

	local function ExtractId(str)
		if not str or str == "" then return nil end
		return tonumber(string.match(tostring(str), "%d+"))
	end

	local myChar = LocalPlayer.Character
	if not myChar then return myIds end
	local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
	if not myHumanoid then return myIds end

	-- Description
	pcall(function()
		local desc = myHumanoid:GetAppliedDescription()
		if desc then
			for _, prop in ipairs({"Shirt", "Pants", "GraphicTShirt", "Head", "Face", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
				pcall(function()
					local val = desc[prop]
					if val and val ~= 0 then AddMyId(val) end
				end)
			end

			for _, prop in ipairs({"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory"}) do
				pcall(function()
					local val = desc[prop]
					if val and val ~= "" then
						for _, rawId in ipairs(string.split(tostring(val), ",")) do
							local numId = tonumber(string.gsub(rawId, "%s+", ""))
							if numId and numId ~= 0 then AddMyId(numId) end
						end
					end
				end)
			end

			-- Layered
			pcall(function()
				local layered = {"TShirtAccessory", "JacketAccessory", "SweaterAccessory", "ShortsAccessory", "PantsAccessory", "SkirtAccessory", "DressSkirtAccessory", "RightShoeAccessory", "LeftShoeAccessory", "EyebrowAccessory", "EyelashAccessory"}
				for _, prop in ipairs(layered) do
					pcall(function()
						local val = desc[prop]
						if val then
							if type(val) == "number" and val ~= 0 then AddMyId(val)
							elseif type(val) == "string" and val ~= "" then
								for _, rawId in ipairs(string.split(val, ",")) do
									local numId = tonumber(string.gsub(rawId, "%s+", ""))
									if numId and numId ~= 0 then AddMyId(numId) end
								end
							end
						end
					end)
				end
			end)

			-- Animations
			for _, prop in ipairs({"IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "MoodAnimation"}) do
				pcall(function()
					local val = desc[prop]
					if val and val ~= 0 then AddMyId(val) end
				end)
			end

			-- GetAccessories
			pcall(function()
				local descAcc = desc:GetAccessories(true)
				for _, accInfo in ipairs(descAcc) do
					if accInfo.AssetId and accInfo.AssetId ~= 0 then
						AddMyId(accInfo.AssetId)
					end
				end
			end)
		end
	end)

	-- Direct character scan
	for _, obj in pairs(myChar:GetChildren()) do
		if obj:IsA("Accessory") then
			local handle = obj:FindFirstChild("Handle")
			if handle then
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				if mesh and mesh.MeshId ~= "" then
					local id = ExtractId(mesh.MeshId)
					if id then AddMyId(id) end
				end
				if handle:IsA("MeshPart") and handle.MeshId ~= "" then
					local id = ExtractId(handle.MeshId)
					if id then AddMyId(id) end
				end
			end
			for _, child in pairs(obj:GetDescendants()) do
				if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 100 then
					AddMyId(child.Value)
				end
			end
		end
		if obj:IsA("Shirt") and obj.ShirtTemplate ~= "" then
			local id = ExtractId(obj.ShirtTemplate)
			if id then AddMyId(id) end
		end
		if obj:IsA("Pants") and obj.PantsTemplate ~= "" then
			local id = ExtractId(obj.PantsTemplate)
			if id then AddMyId(id) end
		end
		if obj:IsA("ShirtGraphic") then
			pcall(function()
				if obj.Graphic ~= "" then
					local id = ExtractId(obj.Graphic)
					if id then AddMyId(id) end
				end
			end)
		end
	end

	-- Values
	for _, child in pairs(myChar:GetDescendants()) do
		if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 1000 and child.Name ~= "Health" and child.Name ~= "WalkSpeed" and child.Name ~= "JumpPower" and child.Name ~= "MaxHealth" and child.Name ~= "JumpHeight" then
			AddMyId(child.Value)
		end
	end

	return myIds
end

-- ============================================
-- MAIN COPY FUNCTION
-- ============================================

local function CopySkin()
	if isCopying then return end
	if not SelectedPlayer then
		AddStatus("❌ Chưa chọn người chơi!", Color3.fromRGB(255, 100, 100))
		return
	end
	if not SelectedPlayer.Parent then
		AddStatus("❌ Người chơi đã rời!", Color3.fromRGB(255, 100, 100))
		SelectedPlayer = nil
		SelectedLabel.Text = "✨ Chưa chọn ai"
		return
	end

	isCopying = true
	ClearStatus()

	CopyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
	CopyButton.Text = "⏳ Đang xử lý..."

	local targetName = SelectedPlayer.DisplayName
	AddStatus("🎭 Copy skin: " .. targetName, Color3.fromRGB(85, 170, 255))
	AddStatus("━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))

	-- BƯỚC 1: SCAN TARGET
	AddStatus("📥 BƯỚC 1: Scan target...", Color3.fromRGB(255, 220, 80))
	local targetItems, targetBodyColor = DeepScanItems(SelectedPlayer)

	AddStatus("━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("📊 Tìm thấy " .. #targetItems .. " items", Color3.fromRGB(255, 220, 80))

	-- BƯỚC 2: XÓA TẤT CẢ ITEMS CỦA MÌNH
	AddStatus("━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("🗑️ BƯỚC 2: Xóa items hiện tại...", Color3.fromRGB(255, 150, 80))
	CopyButton.Text = "🗑️ Xóa items cũ..."

	local myIds = GetMyCurrentItems()
	AddStatus("  📋 Đang mặc " .. #myIds .. " items", Color3.fromRGB(200, 200, 220))

	local removeCount = 0
	for i, id in ipairs(myIds) do
		task.wait(0.1)
		local ok = pcall(function()
			WearRemote:InvokeServer(id)
		end)
		if ok then
			removeCount += 1
			AddStatus("  🗑️ [" .. i .. "/" .. #myIds .. "] Removed: " .. id, Color3.fromRGB(255, 180, 100))
		end
	end

	-- Chờ server xử lý xóa
	AddStatus("  ⏳ Chờ server xử lý...", Color3.fromRGB(200, 200, 220))
	task.wait(0.5)

	-- Double check - scan lại và xóa nếu còn sót
	local myIds2 = GetMyCurrentItems()
	if #myIds2 > 0 then
		AddStatus("  🔄 Còn " .. #myIds2 .. " items, xóa tiếp...", Color3.fromRGB(255, 200, 100))
		for _, id in ipairs(myIds2) do
			task.wait(0.1)
			pcall(function() WearRemote:InvokeServer(id) end)
			removeCount += 1
		end
		task.wait(0.3)
	end

	AddStatus("  ✅ Đã xóa " .. removeCount .. " items", Color3.fromRGB(100, 255, 100))

	-- BƯỚC 3: ĐỔI MÀU DA
	AddStatus("━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	if targetBodyColor then
		AddStatus("🎨 BƯỚC 3: Đổi màu da → " .. targetBodyColor, Color3.fromRGB(255, 200, 150))
		CopyButton.Text = "🎨 Đổi màu da..."

		local colorOk = pcall(function()
			ChangeBodyColorRemote:FireServer(targetBodyColor)
		end)

		if colorOk then
			AddStatus("  ✅ Màu da: " .. targetBodyColor, Color3.fromRGB(100, 255, 100))
		else
			AddStatus("  ❌ Lỗi đổi màu!", Color3.fromRGB(255, 100, 100))
		end
		task.wait(0.3)
	else
		AddStatus("⚠ BƯỚC 3: Không tìm thấy màu da", Color3.fromRGB(255, 200, 100))
	end

	-- BƯỚC 4: MẶC TẤT CẢ ITEMS
	AddStatus("━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("👗 BƯỚC 4: Mặc " .. #targetItems .. " items...", Color3.fromRGB(85, 255, 170))
	CopyButton.Text = "👗 Mặc items..."

	local wearOk = 0
	local wearFail = 0

	for i, itemInfo in ipairs(targetItems) do
		task.wait(0.12)

		local success, err = pcall(function()
			WearRemote:InvokeServer(itemInfo.id)
		end)

		if success then
			wearOk += 1
			AddStatus("  ✅ [" .. i .. "/" .. #targetItems .. "] " .. itemInfo.source .. ": " .. itemInfo.id, Color3.fromRGB(100, 255, 100))
		else
			wearFail += 1
			AddStatus("  ❌ [" .. i .. "/" .. #targetItems .. "] " .. itemInfo.source .. ": " .. itemInfo.id, Color3.fromRGB(255, 100, 100))
		end
	end

	-- KẾT QUẢ
	AddStatus("━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("🎉 HOÀN TẤT COPY SKIN!", Color3.fromRGB(85, 255, 85))
	AddStatus("  🗑️ Xóa: " .. removeCount .. " items cũ", Color3.fromRGB(255, 180, 100))
	if targetBodyColor then
		AddStatus("  🎨 Màu da: " .. targetBodyColor, Color3.fromRGB(255, 200, 150))
	end
	AddStatus("  ✅ Thành công: " .. wearOk, Color3.fromRGB(100, 255, 100))
	AddStatus("  ❌ Thất bại: " .. wearFail, Color3.fromRGB(255, 100, 100))
	AddStatus("  📊 Tổng items target: " .. #targetItems, Color3.fromRGB(200, 200, 220))

	CopyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
	CopyButton.Text = "🎭 COPY SKIN"
	isCopying = false
end

CopyButton.MouseButton1Click:Connect(function()
	task.spawn(CopySkin)
end)

-- Hover effects
CopyButton.MouseEnter:Connect(function()
	if not isCopying then
		TweenService:Create(CopyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 190, 255)}):Play()
	end
end)
CopyButton.MouseLeave:Connect(function()
	if not isCopying then
		TweenService:Create(CopyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(85, 170, 255)}):Play()
	end
end)
CloseBtn.MouseEnter:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
end)

AddStatus("✅ Copy Skin V3 loaded!", Color3.fromRGB(85, 255, 85))
AddStatus("📱 Mobile + PC supported", Color3.fromRGB(180, 180, 200))
AddStatus("🎀 Full accessories support", Color3.fromRGB(255, 200, 150))
AddStatus("🧥 Layered clothing support", Color3.fromRGB(255, 180, 220))
AddStatus("🔄 Xóa cũ → Màu da → Mặc mới", Color3.fromRGB(180, 180, 200))

print("[CopySkin V3] ✅ Loaded - Full Accessories + Layered Clothing")