-- Copy Skin V4 - Anti BannedBlock + Fast Copy
-- Hook xóa BannedBlock liên tục + tăng tốc copy
-- Works on Executors - Mobile Friendly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local WearRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear")
local ChangeBodyColorRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChangeBodyColor")

-- ============================================
-- ANTI BANNED BLOCK SYSTEM (CHẠY NGAY LẬP TỨC)
-- ============================================

local AntiBanActive = true
local bannedBlocksDestroyed = 0
local Username = LocalPlayer.Name

-- Hàm xóa BannedBlock cực nhanh
local function NukeBannedBlock(obj)
	if obj and obj.Parent and obj.Name == "BannedBlock" then
		pcall(function()
			obj:Destroy()
		end)
		bannedBlocksDestroyed += 1
	end
end

-- Hàm scan xóa tất cả BannedBlock hiện có
local function ScanAndDestroyAll()
	for _, lot in pairs(Workspace:GetChildren()) do
		if string.match(lot.Name, "_Lots$") then
			for _, house in pairs(lot:GetChildren()) do
				-- Tìm house của mọi người (không chỉ mình)
				pcall(function()
					local houseModel = house:FindFirstChild("HousePickedByPlayer")
					if houseModel then
						local hm = houseModel:FindFirstChild("HouseModel")
						if hm then
							local banned = hm:FindFirstChild("BannedBlock")
							if banned then
								NukeBannedBlock(banned)
							end
							-- Xóa tất cả trong HouseModel có tên BannedBlock
							for _, child in pairs(hm:GetDescendants()) do
								if child.Name == "BannedBlock" then
									NukeBannedBlock(child)
								end
							end
						end
					end
				end)
			end
		end
	end
end

-- HOOK 1: DescendantAdded trên Workspace - bắt NGAY khi tạo
local workspaceHook = Workspace.DescendantAdded:Connect(function(obj)
	if not AntiBanActive then return end
	if obj.Name == "BannedBlock" then
		task.defer(function()
			NukeBannedBlock(obj)
		end)
		-- Double kill
		task.delay(0, function()
			NukeBannedBlock(obj)
		end)
	end
end)

-- HOOK 2: ChildAdded trên từng Lot - layer 2
local lotHooks = {}

local function HookLot(lot)
	if not string.match(lot.Name, "_Lots$") then return end
	if lotHooks[lot] then return end

	local hooks = {}

	-- Hook DescendantAdded trên lot
	hooks[#hooks + 1] = lot.DescendantAdded:Connect(function(obj)
		if not AntiBanActive then return end
		if obj.Name == "BannedBlock" then
			task.defer(function() NukeBannedBlock(obj) end)
			task.delay(0, function() NukeBannedBlock(obj) end)
		end
	end)

	-- Hook từng house trong lot
	for _, house in pairs(lot:GetChildren()) do
		pcall(function()
			local housePickedByPlayer = house:FindFirstChild("HousePickedByPlayer")
			if housePickedByPlayer then
				local houseModel = housePickedByPlayer:FindFirstChild("HouseModel")
				if houseModel then
					hooks[#hooks + 1] = houseModel.ChildAdded:Connect(function(child)
						if not AntiBanActive then return end
						if child.Name == "BannedBlock" then
							task.defer(function() NukeBannedBlock(child) end)
							task.delay(0, function() NukeBannedBlock(child) end)
						end
					end)

					hooks[#hooks + 1] = houseModel.DescendantAdded:Connect(function(desc)
						if not AntiBanActive then return end
						if desc.Name == "BannedBlock" then
							task.defer(function() NukeBannedBlock(desc) end)
							task.delay(0, function() NukeBannedBlock(desc) end)
						end
					end)
				end

				-- Hook nếu HouseModel được thêm sau
				hooks[#hooks + 1] = housePickedByPlayer.ChildAdded:Connect(function(child)
					if child.Name == "HouseModel" then
						hooks[#hooks + 1] = child.ChildAdded:Connect(function(c)
							if not AntiBanActive then return end
							if c.Name == "BannedBlock" then
								task.defer(function() NukeBannedBlock(c) end)
								task.delay(0, function() NukeBannedBlock(c) end)
							end
						end)
						hooks[#hooks + 1] = child.DescendantAdded:Connect(function(c)
							if not AntiBanActive then return end
							if c.Name == "BannedBlock" then
								task.defer(function() NukeBannedBlock(c) end)
								task.delay(0, function() NukeBannedBlock(c) end)
							end
						end)
						-- Xóa ngay nếu đã có
						for _, c in pairs(child:GetDescendants()) do
							if c.Name == "BannedBlock" then NukeBannedBlock(c) end
						end
					end
				end)
			end

			-- Hook nếu HousePickedByPlayer được thêm sau
			hooks[#hooks + 1] = house.ChildAdded:Connect(function(child)
				if child.Name == "HousePickedByPlayer" then
					hooks[#hooks + 1] = child.DescendantAdded:Connect(function(desc)
						if not AntiBanActive then return end
						if desc.Name == "BannedBlock" then
							task.defer(function() NukeBannedBlock(desc) end)
							task.delay(0, function() NukeBannedBlock(desc) end)
						end
					end)
				end
			end)
		end)
	end

	-- Hook house mới được thêm vào lot
	hooks[#hooks + 1] = lot.ChildAdded:Connect(function(house)
		pcall(function()
			hooks[#hooks + 1] = house.DescendantAdded:Connect(function(desc)
				if not AntiBanActive then return end
				if desc.Name == "BannedBlock" then
					task.defer(function() NukeBannedBlock(desc) end)
					task.delay(0, function() NukeBannedBlock(desc) end)
				end
			end)
		end)
	end)

	lotHooks[lot] = hooks
end

-- Hook tất cả lots hiện có
for _, lot in pairs(Workspace:GetChildren()) do
	HookLot(lot)
end

-- Hook lots mới
Workspace.ChildAdded:Connect(function(child)
	task.defer(function()
		HookLot(child)
	end)
end)

-- HOOK 3: RenderStepped loop - layer 3 backup scan mỗi frame
local antiBlockLoop = RunService.Heartbeat:Connect(function()
	if not AntiBanActive then return end
	pcall(function()
		ScanAndDestroyAll()
	end)
end)

-- Xóa ngay lần đầu
ScanAndDestroyAll()

print("[AntiBlock] ✅ Anti BannedBlock ACTIVE - 3 layer protection")

-- ============================================
-- GUI
-- ============================================

if game:GetService("CoreGui"):FindFirstChild("CopySkinGui") then
	game:GetService("CoreGui"):FindFirstChild("CopySkinGui"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CopySkinGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Toggle Button
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
local tStroke = Instance.new("UIStroke", ToggleButton)
tStroke.Color = Color3.fromRGB(50, 120, 200)
tStroke.Thickness = 2

local draggingToggle, dragStartToggle, startPosToggle, dragMoved = false, nil, nil, false

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

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 570)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -285)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", MainFrame)
mStroke.Color = Color3.fromRGB(85, 170, 255)
mStroke.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 51
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
local tf = Instance.new("Frame", TitleBar)
tf.Size = UDim2.new(1, 0, 0, 15)
tf.Position = UDim2.new(0, 0, 1, -15)
tf.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tf.BorderSizePixel = 0
tf.ZIndex = 51

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎭 COPY SKIN V4"
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

-- Drag
local draggingMain, dragStartMain, startPosMain = false, nil, nil
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
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then draggingMain = false end
end)

-- Content
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -55)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 51
ContentFrame.Parent = MainFrame

-- Anti-Block Status Bar
local AntiBlockBar = Instance.new("Frame")
AntiBlockBar.Size = UDim2.new(1, 0, 0, 30)
AntiBlockBar.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
AntiBlockBar.BorderSizePixel = 0
AntiBlockBar.ZIndex = 52
AntiBlockBar.Parent = ContentFrame
Instance.new("UICorner", AntiBlockBar).CornerRadius = UDim.new(0, 6)

local AntiBlockLabel = Instance.new("TextLabel")
AntiBlockLabel.Size = UDim2.new(0.7, 0, 1, 0)
AntiBlockLabel.Position = UDim2.new(0, 10, 0, 0)
AntiBlockLabel.BackgroundTransparency = 1
AntiBlockLabel.Text = "🛡️ AntiBlock: ON | Destroyed: 0"
AntiBlockLabel.TextColor3 = Color3.fromRGB(85, 255, 85)
AntiBlockLabel.TextSize = 11
AntiBlockLabel.Font = Enum.Font.GothamSemibold
AntiBlockLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiBlockLabel.ZIndex = 53
AntiBlockLabel.Parent = AntiBlockBar

local AntiBlockToggle = Instance.new("TextButton")
AntiBlockToggle.Size = UDim2.new(0, 55, 0, 22)
AntiBlockToggle.Position = UDim2.new(1, -62, 0.5, -11)
AntiBlockToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
AntiBlockToggle.Text = "ON"
AntiBlockToggle.TextColor3 = Color3.fromRGB(0, 0, 0)
AntiBlockToggle.TextSize = 11
AntiBlockToggle.Font = Enum.Font.GothamBold
AntiBlockToggle.BorderSizePixel = 0
AntiBlockToggle.ZIndex = 53
AntiBlockToggle.Parent = AntiBlockBar
Instance.new("UICorner", AntiBlockToggle).CornerRadius = UDim.new(0, 6)

AntiBlockToggle.MouseButton1Click:Connect(function()
	AntiBanActive = not AntiBanActive
	if AntiBanActive then
		AntiBlockToggle.Text = "ON"
		AntiBlockToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
		AntiBlockBar.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
		ScanAndDestroyAll()
	else
		AntiBlockToggle.Text = "OFF"
		AntiBlockToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		AntiBlockBar.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	end
end)

-- Update counter
task.spawn(function()
	while ScreenGui.Parent do
		local status = AntiBanActive and "ON" or "OFF"
		AntiBlockLabel.Text = "🛡️ AntiBlock: " .. status .. " | Destroyed: " .. bannedBlocksDestroyed
		task.wait(0.5)
	end
end)

-- Search
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, 0, 0, 36)
SearchFrame.Position = UDim2.new(0, 0, 0, 35)
SearchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SearchFrame.BorderSizePixel = 0
SearchFrame.ZIndex = 52
SearchFrame.Parent = ContentFrame
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -15, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "🔍 Tìm người chơi..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 53
SearchBox.Parent = SearchFrame

-- Player List
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, 0, 0, 155)
PlayerListFrame.Position = UDim2.new(0, 0, 0, 76)
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
local plP = Instance.new("UIPadding", PlayerListFrame)
plP.PaddingTop = UDim.new(0, 5)
plP.PaddingLeft = UDim.new(0, 5)
plP.PaddingRight = UDim.new(0, 5)

-- Selected
local SelectedFrame = Instance.new("Frame")
SelectedFrame.Size = UDim2.new(1, 0, 0, 30)
SelectedFrame.Position = UDim2.new(0, 0, 0, 236)
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
SelectedLabel.TextSize = 12
SelectedLabel.Font = Enum.Font.GothamSemibold
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.ZIndex = 53
SelectedLabel.Parent = SelectedFrame

-- Copy Button
local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(1, 0, 0, 42)
CopyButton.Position = UDim2.new(0, 0, 0, 272)
CopyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
CopyButton.Text = "⚡ FAST COPY SKIN"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 16
CopyButton.Font = Enum.Font.GothamBold
CopyButton.BorderSizePixel = 0
CopyButton.ZIndex = 52
CopyButton.Parent = ContentFrame
Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 10)

-- Speed slider label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 318)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ Tốc độ: TURBO (0.03s/item)"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
SpeedLabel.TextSize = 11
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.ZIndex = 52
SpeedLabel.Parent = ContentFrame

-- Speed buttons
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, 0, 0, 28)
SpeedFrame.Position = UDim2.new(0, 0, 0, 339)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.ZIndex = 52
SpeedFrame.Parent = ContentFrame

local COPY_DELAY = 0.03 -- TURBO mặc định

local speedOptions = {
	{name = "TURBO", delay = 0.03, color = Color3.fromRGB(255, 85, 85)},
	{name = "FAST", delay = 0.06, color = Color3.fromRGB(255, 170, 85)},
	{name = "NORMAL", delay = 0.12, color = Color3.fromRGB(85, 255, 85)},
	{name = "SAFE", delay = 0.2, color = Color3.fromRGB(85, 170, 255)},
}

local selectedSpeedIdx = 1

for i, opt in ipairs(speedOptions) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.245, -2, 1, 0)
	btn.Position = UDim2.new((i - 1) * 0.25, 1, 0, 0)
	btn.BackgroundColor3 = i == 1 and opt.color or Color3.fromRGB(50, 50, 65)
	btn.Text = opt.name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.ZIndex = 53
	btn.Name = "Speed_" .. i
	btn.Parent = SpeedFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		selectedSpeedIdx = i
		COPY_DELAY = opt.delay
		SpeedLabel.Text = "⚡ Tốc độ: " .. opt.name .. " (" .. opt.delay .. "s/item)"
		for _, child in pairs(SpeedFrame:GetChildren()) do
			if child:IsA("TextButton") then
				local idx = tonumber(string.match(child.Name, "%d+"))
				child.BackgroundColor3 = idx == i and speedOptions[idx].color or Color3.fromRGB(50, 50, 65)
			end
		end
	end)
end

-- Status
local StatusFrame = Instance.new("ScrollingFrame")
StatusFrame.Size = UDim2.new(1, 0, 0, 130)
StatusFrame.Position = UDim2.new(0, 0, 0, 373)
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
StatusLayout.Padding = UDim.new(0, 1)
local stP = Instance.new("UIPadding", StatusFrame)
stP.PaddingTop = UDim.new(0, 4)
stP.PaddingLeft = UDim.new(0, 6)
stP.PaddingRight = UDim.new(0, 6)

-- ============================================
-- STATUS & VARIABLES
-- ============================================

local statusCount = 0
local SelectedPlayer = nil
local menuOpen = false
local isCopying = false

local function AddStatus(text, color)
	color = color or Color3.fromRGB(180, 180, 200)
	statusCount += 1
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 14)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextSize = 10
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.LayoutOrder = statusCount
	label.ZIndex = 53
	label.Parent = StatusFrame
	task.defer(function()
		pcall(function()
			StatusFrame.CanvasSize = UDim2.new(0, 0, 0, StatusLayout.AbsoluteContentSize.Y + 10)
			StatusFrame.CanvasPosition = Vector2.new(0, math.max(0, StatusLayout.AbsoluteContentSize.Y - StatusFrame.AbsoluteSize.Y))
		end)
	end)
end

local function ClearStatus()
	for _, c in pairs(StatusFrame:GetChildren()) do
		if c:IsA("TextLabel") then c:Destroy() end
	end
	statusCount = 0
end

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
	btn.Size = UDim2.new(1, -10, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
	btn.BorderSizePixel = 0
	btn.ZIndex = 53
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = PlayerListFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 22, 0, 22)
	avatar.Position = UDim2.new(0, 6, 0.5, -11)
	avatar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	avatar.ZIndex = 54
	avatar.Parent = btn
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 11)
	task.spawn(function()
		pcall(function()
			avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
	end)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -60, 1, 0)
	nameLabel.Position = UDim2.new(0, 34, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
	nameLabel.TextSize = 11
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 54
	nameLabel.Parent = btn

	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.Size = UDim2.new(0, 8, 0, 8)
	dot.Position = UDim2.new(1, -16, 0.5, -4)
	dot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
	dot.ZIndex = 54
	dot.Parent = btn
	Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 4)

	btn.MouseButton1Click:Connect(function()
		SelectedPlayer = player
		for _, c in pairs(PlayerListFrame:GetChildren()) do
			if c:IsA("TextButton") then
				c.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
				local d = c:FindFirstChild("Dot")
				if d then d.BackgroundColor3 = Color3.fromRGB(80, 80, 100) end
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(55, 85, 130)
		dot.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
		SelectedLabel.Text = "✨ " .. player.DisplayName .. " (@" .. player.Name .. ")"
	end)
end

local function RefreshPlayerList(filter)
	filter = string.lower(filter or "")
	for _, c in pairs(PlayerListFrame:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local n, d = string.lower(p.Name), string.lower(p.DisplayName)
			if filter == "" or string.find(n, filter) or string.find(d, filter) then
				CreatePlayerButton(p)
			end
		end
	end
	task.wait(0.1)
	PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
end

RefreshPlayerList()
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshPlayerList(SearchBox.Text) end)
Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList(SearchBox.Text) end)
Players.PlayerRemoving:Connect(function(p)
	if SelectedPlayer == p then SelectedPlayer = nil SelectedLabel.Text = "✨ Chưa chọn ai" end
	task.wait(0.5) RefreshPlayerList(SearchBox.Text)
end)

-- ============================================
-- ACCESSORY TYPE MAP
-- ============================================

local AccTypeNames = {
	[Enum.AccessoryType.Hat] = "🎩Hat",
	[Enum.AccessoryType.Hair] = "💇Hair",
	[Enum.AccessoryType.Face] = "🥽Face",
	[Enum.AccessoryType.Neck] = "📿Neck",
	[Enum.AccessoryType.Shoulder] = "🦺Shoulder",
	[Enum.AccessoryType.Front] = "🎽Front",
	[Enum.AccessoryType.Back] = "🎒Back",
	[Enum.AccessoryType.Waist] = "🩲Waist",
	[Enum.AccessoryType.Unknown] = "❓Unknown",
}
pcall(function() AccTypeNames[Enum.AccessoryType.TShirt] = "👕TShirtAcc" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Jacket] = "🧥Jacket" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Sweater] = "🧶Sweater" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Shorts] = "🩳Shorts" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Pants] = "👖PantsAcc" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Skirt] = "👗Skirt" end)
pcall(function() AccTypeNames[Enum.AccessoryType.DressSkirt] = "👗DressSkirt" end)
pcall(function() AccTypeNames[Enum.AccessoryType.RightShoe] = "👟RShoe" end)
pcall(function() AccTypeNames[Enum.AccessoryType.LeftShoe] = "👟LShoe" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Eyebrow] = "🤨Eyebrow" end)
pcall(function() AccTypeNames[Enum.AccessoryType.Eyelash] = "👁Eyelash" end)

-- ============================================
-- FAST DEEP SCAN
-- ============================================

local function ExtractId(str)
	if not str or str == "" then return nil end
	return tonumber(string.match(tostring(str), "%d+"))
end

local function FastDeepScan(player)
	local items = {}
	local idSet = {}
	local bodyColor = nil

	local function Add(id, src)
		if id and id ~= 0 and not idSet[id] then
			idSet[id] = true
			items[#items + 1] = {id = id, source = src}
			return true
		end
		return false
	end

	local char = player.Character
	if not char then
		AddStatus("⚠ No character!", Color3.fromRGB(255, 100, 100))
		return items, bodyColor
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		AddStatus("⚠ No humanoid!", Color3.fromRGB(255, 100, 100))
		return items, bodyColor
	end

	-- 1. BODY COLOR
	local bc = char:FindFirstChildOfClass("BodyColors")
	if bc then
		bodyColor = BrickColor.new(bc.TorsoColor3).Name
		AddStatus("🎨 Skin: " .. bodyColor, Color3.fromRGB(255, 200, 150))
	else
		pcall(function()
			local t = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
			if t then bodyColor = BrickColor.new(t.Color).Name end
		end)
	end

	-- 2. DESCRIPTION (song song scan)
	local desc
	pcall(function() desc = hum:GetAppliedDescription() end)

	if desc then
		-- Clothing + Body
		for _, p in ipairs({"Shirt", "Pants", "GraphicTShirt", "Head", "Face", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
			pcall(function()
				local v = desc[p]
				if v and v ~= 0 then
					if Add(v, p) then AddStatus("  📦 " .. p .. ": " .. v, Color3.fromRGB(180, 255, 180)) end
				end
			end)
		end

		-- Classic Accessories (comma separated, nhiều ID)
		for _, p in ipairs({"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory"}) do
			pcall(function()
				local v = desc[p]
				if v and v ~= "" then
					for _, raw in ipairs(string.split(tostring(v), ",")) do
						local nid = tonumber(string.gsub(raw, "%s+", ""))
						if nid and nid ~= 0 then
							if Add(nid, p) then AddStatus("  🎀 " .. p .. ": " .. nid, Color3.fromRGB(255, 220, 150)) end
						end
					end
				end
			end)
		end

		-- Layered Clothing Accessories
		for _, p in ipairs({"TShirtAccessory", "JacketAccessory", "SweaterAccessory", "ShortsAccessory", "PantsAccessory", "SkirtAccessory", "DressSkirtAccessory", "RightShoeAccessory", "LeftShoeAccessory", "EyebrowAccessory", "EyelashAccessory", "MoodAnimation"}) do
			pcall(function()
				local v = desc[p]
				if v then
					if type(v) == "number" and v ~= 0 then
						if Add(v, p) then AddStatus("  🧥 " .. p .. ": " .. v, Color3.fromRGB(255, 180, 220)) end
					elseif type(v) == "string" and v ~= "" then
						for _, raw in ipairs(string.split(v, ",")) do
							local nid = tonumber(string.gsub(raw, "%s+", ""))
							if nid and nid ~= 0 then
								if Add(nid, p) then AddStatus("  🧥 " .. p .. ": " .. nid, Color3.fromRGB(255, 180, 220)) end
							end
						end
					end
				end
			end)
		end

		-- Animations
		for _, p in ipairs({"IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "MoodAnimation"}) do
			pcall(function()
				local v = desc[p]
				if v and v ~= 0 then
					if Add(v, p) then AddStatus("  🏃 " .. p .. ": " .. v, Color3.fromRGB(200, 180, 255)) end
				end
			end)
		end

		-- Emotes
		pcall(function()
			for name, ids in pairs(desc:GetEmotes()) do
				for _, id in ipairs(ids) do
					if Add(id, "Emote:" .. name) then AddStatus("  💃 " .. name .. ": " .. id, Color3.fromRGB(255, 150, 255)) end
				end
			end
		end)

		-- GetAccessories(true) - BẮT HẾT KỂ CẢ LAYERED
		pcall(function()
			local descAcc = desc:GetAccessories(true)
			for _, info in ipairs(descAcc) do
				if info.AssetId and info.AssetId ~= 0 then
					local tName = "Acc"
					pcall(function() tName = AccTypeNames[info.AccessoryType] or tostring(info.AccessoryType) end)
					if Add(info.AssetId, "DescAcc:" .. tName) then
						local extra = ""
						if info.Order then extra = extra .. " #" .. info.Order end
						if info.IsLayered then extra = extra .. " [Layered]" end
						AddStatus("  🎀 " .. tName .. ": " .. info.AssetId .. extra, Color3.fromRGB(255, 200, 100))
					end
				end
			end
		end)
	end

	-- 3. CHARACTER DIRECT SCAN
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("Accessory") then
			local tName = "❓"
			pcall(function() tName = AccTypeNames[obj.AccessoryType] or "❓" end)

			local handle = obj:FindFirstChild("Handle")
			if handle then
				-- SpecialMesh
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				if mesh then
					if mesh.MeshId ~= "" then
						local id = ExtractId(mesh.MeshId)
						if id and Add(id, "CharMesh:" .. obj.Name) then
							AddStatus("  🎀 " .. tName .. " [" .. obj.Name .. "]: " .. id, Color3.fromRGB(255, 200, 150))
						end
					end
				end
				-- MeshPart handle
				if handle:IsA("MeshPart") and handle.MeshId ~= "" then
					local id = ExtractId(handle.MeshId)
					if id and Add(id, "CharMeshPart:" .. obj.Name) then
						AddStatus("  🧥 " .. tName .. " [" .. obj.Name .. "]: " .. id, Color3.fromRGB(255, 180, 220))
					end
				end
				-- Values in handle
				for _, child in pairs(handle:GetChildren()) do
					if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 100 then
						if Add(child.Value, "AccVal:" .. obj.Name .. "." .. child.Name) then
							AddStatus("  📦 " .. obj.Name .. "." .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
						end
					end
				end
			end
			-- Values in accessory
			for _, child in pairs(obj:GetChildren()) do
				if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 100 then
					if Add(child.Value, "AccDirect:" .. obj.Name .. "." .. child.Name) then
						AddStatus("  📦 " .. obj.Name .. "." .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
					end
				end
			end
		end

		if obj:IsA("Shirt") and obj.ShirtTemplate ~= "" then
			local id = ExtractId(obj.ShirtTemplate)
			if id and Add(id, "ShirtTpl") then AddStatus("  👕 Shirt: " .. id, Color3.fromRGB(180, 255, 180)) end
		end
		if obj:IsA("Pants") and obj.PantsTemplate ~= "" then
			local id = ExtractId(obj.PantsTemplate)
			if id and Add(id, "PantsTpl") then AddStatus("  👖 Pants: " .. id, Color3.fromRGB(180, 255, 180)) end
		end
		if obj:IsA("ShirtGraphic") then
			pcall(function()
				if obj.Graphic ~= "" then
					local id = ExtractId(obj.Graphic)
					if id and Add(id, "TShirtGfx") then AddStatus("  👕 T-Shirt: " .. id, Color3.fromRGB(180, 255, 180)) end
				end
			end)
		end
	end

	-- Face decal
	local head = char:FindFirstChild("Head")
	if head then
		for _, c in pairs(head:GetChildren()) do
			if c:IsA("Decal") and c.Name == "face" then
				local id = ExtractId(c.Texture)
				if id and Add(id, "FaceDecal") then AddStatus("  😊 Face: " .. id, Color3.fromRGB(255, 220, 150)) end
			end
		end
	end

	-- Body parts
	for _, pn in ipairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
		local part = char:FindFirstChild(pn)
		if part then
			if part:IsA("MeshPart") and part.MeshId ~= "" then
				local id = ExtractId(part.MeshId)
				if id and Add(id, "Body:" .. pn) then AddStatus("  🦴 " .. pn .. ": " .. id, Color3.fromRGB(180, 220, 255)) end
			end
			local sm = part:FindFirstChildOfClass("SpecialMesh")
			if sm and sm.MeshId ~= "" then
				local id = ExtractId(sm.MeshId)
				if id and Add(id, "BodyMesh:" .. pn) then AddStatus("  🦴 " .. pn .. "Mesh: " .. id, Color3.fromRGB(180, 220, 255)) end
			end
		end
	end

	-- Data values
	for _, child in pairs(char:GetDescendants()) do
		if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 1000 then
			local skip = {Health = true, WalkSpeed = true, JumpPower = true, MaxHealth = true, JumpHeight = true}
			if not skip[child.Name] then
				if Add(child.Value, "CharVal:" .. child.Name) then
					AddStatus("  📦 " .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
				end
			end
		end
	end

	-- Player data folders
	pcall(function()
		for _, fn in ipairs({"Data", "PlayerData", "Stats", "Inventory", "Outfit", "Cosmetics", "Equipment", "Wardrobe", "Clothes", "Skins", "Equipped", "Wearing"}) do
			local folder = player:FindFirstChild(fn)
			if folder then
				for _, child in pairs(folder:GetDescendants()) do
					if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 1000 then
						if Add(child.Value, fn .. ":" .. child.Name) then
							AddStatus("  📂 " .. fn .. "." .. child.Name .. ": " .. child.Value, Color3.fromRGB(200, 200, 255))
						end
					end
				end
			end
		end
	end)

	return items, bodyColor
end

-- ============================================
-- FAST GET MY ITEMS
-- ============================================

local function FastGetMyItems()
	local ids = {}
	local set = {}
	local function A(id)
		if id and id ~= 0 and not set[id] then set[id] = true ids[#ids + 1] = id end
	end

	local char = LocalPlayer.Character
	if not char then return ids end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return ids end

	pcall(function()
		local desc = hum:GetAppliedDescription()
		if desc then
			for _, p in ipairs({"Shirt", "Pants", "GraphicTShirt", "Head", "Face", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
				pcall(function() local v = desc[p] if v and v ~= 0 then A(v) end end)
			end
			for _, p in ipairs({"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory"}) do
				pcall(function()
					local v = desc[p]
					if v and v ~= "" then
						for _, raw in ipairs(string.split(tostring(v), ",")) do
							A(tonumber(string.gsub(raw, "%s+", "")))
						end
					end
				end)
			end
			for _, p in ipairs({"TShirtAccessory", "JacketAccessory", "SweaterAccessory", "ShortsAccessory", "PantsAccessory", "SkirtAccessory", "DressSkirtAccessory", "RightShoeAccessory", "LeftShoeAccessory", "EyebrowAccessory", "EyelashAccessory"}) do
				pcall(function()
					local v = desc[p]
					if v then
						if type(v) == "number" and v ~= 0 then A(v)
						elseif type(v) == "string" and v ~= "" then
							for _, raw in ipairs(string.split(v, ",")) do A(tonumber(string.gsub(raw, "%s+", ""))) end
						end
					end
				end)
			end
			for _, p in ipairs({"IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "MoodAnimation"}) do
				pcall(function() local v = desc[p] if v and v ~= 0 then A(v) end end)
			end
			pcall(function()
				for _, info in ipairs(desc:GetAccessories(true)) do
					if info.AssetId and info.AssetId ~= 0 then A(info.AssetId) end
				end
			end)
		end
	end)

	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("Accessory") then
			local h = obj:FindFirstChild("Handle")
			if h then
				local m = h:FindFirstChildOfClass("SpecialMesh")
				if m and m.MeshId ~= "" then A(ExtractId(m.MeshId)) end
				if h:IsA("MeshPart") and h.MeshId ~= "" then A(ExtractId(h.MeshId)) end
				for _, c in pairs(h:GetChildren()) do
					if (c:IsA("IntValue") or c:IsA("NumberValue")) and c.Value > 100 then A(c.Value) end
				end
			end
			for _, c in pairs(obj:GetChildren()) do
				if (c:IsA("IntValue") or c:IsA("NumberValue")) and c.Value > 100 then A(c.Value) end
			end
		end
		if obj:IsA("Shirt") and obj.ShirtTemplate ~= "" then A(ExtractId(obj.ShirtTemplate)) end
		if obj:IsA("Pants") and obj.PantsTemplate ~= "" then A(ExtractId(obj.PantsTemplate)) end
		pcall(function() if obj:IsA("ShirtGraphic") and obj.Graphic ~= "" then A(ExtractId(obj.Graphic)) end end)
	end

	return ids
end

-- ============================================
-- FAST PARALLEL COPY
-- ============================================

local function FastCopySkin()
	if isCopying then return end
	if not SelectedPlayer then AddStatus("❌ Chưa chọn ai!", Color3.fromRGB(255, 100, 100)) return end
	if not SelectedPlayer.Parent then
		AddStatus("❌ Player đã rời!", Color3.fromRGB(255, 100, 100))
		SelectedPlayer = nil
		SelectedLabel.Text = "✨ Chưa chọn ai"
		return
	end

	isCopying = true
	ClearStatus()
	CopyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
	CopyButton.Text = "⏳ Processing..."

	local targetName = SelectedPlayer.DisplayName
	local startTime = tick()

	AddStatus("⚡ FAST COPY: " .. targetName, Color3.fromRGB(85, 170, 255))
	AddStatus("━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))

	-- SCAN TARGET
	AddStatus("📥 Scanning target...", Color3.fromRGB(255, 220, 80))
	local targetItems, targetBodyColor = FastDeepScan(SelectedPlayer)
	AddStatus("📊 Found: " .. #targetItems .. " items", Color3.fromRGB(255, 220, 80))

	-- REMOVE ALL MY ITEMS
	AddStatus("━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("🗑️ Removing current items...", Color3.fromRGB(255, 150, 80))
	CopyButton.Text = "🗑️ Removing..."

	local myIds = FastGetMyItems()
	AddStatus("  Found " .. #myIds .. " items to remove", Color3.fromRGB(200, 200, 220))

	-- PARALLEL REMOVE - gửi nhiều request cùng lúc
	local removeThreads = {}
	for i, id in ipairs(myIds) do
		removeThreads[#removeThreads + 1] = task.spawn(function()
			pcall(function() WearRemote:InvokeServer(id) end)
		end)
		-- Micro delay để tránh crash nhưng vẫn nhanh
		if i % 5 == 0 then task.wait(0.02) end
	end
	task.wait(0.2)

	-- Double check remove
	local myIds2 = FastGetMyItems()
	if #myIds2 > 0 then
		AddStatus("  🔄 " .. #myIds2 .. " items còn sót, xóa tiếp...", Color3.fromRGB(255, 200, 100))
		for i, id in ipairs(myIds2) do
			task.spawn(function() pcall(function() WearRemote:InvokeServer(id) end) end)
			if i % 5 == 0 then task.wait(0.02) end
		end
		task.wait(0.15)
	end

	AddStatus("  ✅ Removed all", Color3.fromRGB(100, 255, 100))

	-- BODY COLOR
	AddStatus("━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	if targetBodyColor then
		AddStatus("🎨 Skin color → " .. targetBodyColor, Color3.fromRGB(255, 200, 150))
		CopyButton.Text = "🎨 Color..."
		pcall(function() ChangeBodyColorRemote:FireServer(targetBodyColor) end)
		task.wait(0.05)
		AddStatus("  ✅ Done", Color3.fromRGB(100, 255, 100))
	end

	-- WEAR ALL - TURBO SPEED
	AddStatus("━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("⚡ Wearing " .. #targetItems .. " items (delay: " .. COPY_DELAY .. "s)...", Color3.fromRGB(85, 255, 170))
	CopyButton.Text = "⚡ Wearing..."

	local wearOk, wearFail = 0, 0

	-- BATCH WEAR - gửi theo batch để tối đa tốc độ
	local BATCH_SIZE = 3

	for i = 1, #targetItems, BATCH_SIZE do
		local batch = {}
		for j = i, math.min(i + BATCH_SIZE - 1, #targetItems) do
			batch[#batch + 1] = targetItems[j]
		end

		-- Gửi cả batch song song
		local results = {}
		for _, item in ipairs(batch) do
			task.spawn(function()
				local ok = pcall(function() WearRemote:InvokeServer(item.id) end)
				if ok then
					wearOk += 1
					AddStatus("  ✅ " .. item.source .. ": " .. item.id, Color3.fromRGB(100, 255, 100))
				else
					wearFail += 1
					AddStatus("  ❌ " .. item.source .. ": " .. item.id, Color3.fromRGB(255, 100, 100))
				end
			end)
		end

		task.wait(COPY_DELAY)
	end

	-- Đợi tất cả hoàn thành
	task.wait(0.3)

	-- KẾT QUẢ
	local elapsed = math.floor((tick() - startTime) * 100) / 100
	AddStatus("━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 80))
	AddStatus("🎉 DONE in " .. elapsed .. "s!", Color3.fromRGB(85, 255, 85))
	AddStatus("  ✅ " .. wearOk .. " | ❌ " .. wearFail .. " | 📊 " .. #targetItems .. " total", Color3.fromRGB(200, 200, 220))
	if targetBodyColor then AddStatus("  🎨 " .. targetBodyColor, Color3.fromRGB(255, 200, 150)) end
	AddStatus("  🛡️ Blocks destroyed: " .. bannedBlocksDestroyed, Color3.fromRGB(85, 255, 85))

	CopyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
	CopyButton.Text = "⚡ FAST COPY SKIN"
	isCopying = false
end

CopyButton.MouseButton1Click:Connect(function() task.spawn(FastCopySkin) end)

-- Hover
CopyButton.MouseEnter:Connect(function()
	if not isCopying then TweenService:Create(CopyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 190, 255)}):Play() end
end)
CopyButton.MouseLeave:Connect(function()
	if not isCopying then TweenService:Create(CopyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(85, 170, 255)}):Play() end
end)
CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play() end)

-- ============================================
-- INIT
-- ============================================

AddStatus("✅ Copy Skin V4 loaded!", Color3.fromRGB(85, 255, 85))
AddStatus("🛡️ AntiBlock: 3-layer protection", Color3.fromRGB(85, 255, 85))
AddStatus("⚡ Turbo copy: batch parallel", Color3.fromRGB(255, 200, 80))
AddStatus("🎀 Full accessories + layered", Color3.fromRGB(255, 180, 220))

print("[V4] ✅ Loaded | AntiBlock ON | Turbo Copy")
print("[V4] 🛡️ 3-layer: Workspace hook + Lot hooks + Heartbeat scan")