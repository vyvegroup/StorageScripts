local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")

-- Lấy thông tin người chơi hiện tại
local Player = game:GetService("Players").LocalPlayer
local PlayerName = Player.Name -- Tự động lấy Username của bạn

-- Cài đặt giao diện
ScreenGui.Parent = game.CoreGui
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 100, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 150) 
ToggleButton.Text = "Auto: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Draggable = true 

local active = false

-- Hàm xử lý Auto Win
task.spawn(function()
    while true do
        if active then
            pcall(function()
                -- Tự động tìm Worm dựa trên tên người chơi đang dùng Script
                local wormFolder = workspace:FindFirstChild("Worms")
                local myWorm = wormFolder and wormFolder:FindFirstChild("Worm-" .. PlayerName)
                local winTouch = workspace:FindFirstChild("WORM GOD") and workspace["WORM GOD"]:FindFirstChild("WinTouch")
                
                if myWorm and winTouch then
                    local hitbox = myWorm:FindFirstChild("Head") and myWorm.Head:FindFirstChild("WormHitbox")
                    
                    if hitbox then
                        -- 1. Dịch chuyển đến đích
                        hitbox.CFrame = winTouch.CFrame
                        task.wait(0.05) -- Giảm delay để nhận Touch nhanh hơn
                        
                        -- 2. Dịch chuyển ra xa 1 chút để "nhấp nhả" (Reset Touch)
                        -- CFrame.new(0, 20, 0) sẽ đưa bạn lên cao 20 studs
                        hitbox.CFrame = winTouch.CFrame * CFrame.new(0, 20, 0)
                    end
                end
            end)
        end
        task.wait(0.1) -- Tốc độ lặp lại tổng thể
    end
end)

-- Sự kiện bấm nút
ToggleButton.MouseButton1Click:Connect(function()
    active = not active
    ToggleButton.Text = active and "Auto: ON" or "Auto: OFF"
    ToggleButton.BackgroundColor3 = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)
