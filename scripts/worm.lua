local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")

-- Giao diện nút bấm
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
                local worm = workspace.Worms:FindFirstChild("Worm-taokotenl")
                local hitbox = worm and worm:FindFirstChild("Head") and worm.Head:FindFirstChild("WormHitbox")
                local winTouch = workspace["WORM GOD"]:FindFirstChild("WinTouch")
                
                if hitbox and winTouch then
                    -- Bước 1: Bay đến chỗ Win
                    hitbox.CFrame = winTouch.CFrame
                    task.wait(0.1) -- Đợi một chút để game nhận Touch
                    
                    -- Bước 2: Bay ra xa một khoảng (ví dụ lên trời 50 block) để reset Touch
                    hitbox.CFrame = winTouch.CFrame * CFrame.new(0, 50, 0)
                end
            end)
        end
        task.wait(0.1) -- Tốc độ lặp lại
    end
end)

-- Sự kiện bấm nút
ToggleButton.MouseButton1Click:Connect(function()
    active = not active
    ToggleButton.Text = active and "Auto: ON" or "Auto: OFF"
    ToggleButton.BackgroundColor3 = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)
