-- Tải Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Biến điều khiển
local InfiniteHealthEnabled = false
local InfiniteHealthConnection = nil
local HEALTH_VALUE = 999999999 -- Giá trị máu cao

-- Tạo Window
local Window = Rayfield:CreateWindow({
    Name = "🛡️ Army Immortal Script",
    LoadingTitle = "Đang tải...",
    LoadingSubtitle = "by Script Master",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Tạo Tab chính
local MainTab = Window:CreateTab("⚔️ Main", 4483362458)

-- Hàm set máu cho 1 humanoid
local function SetInfiniteHealth(humanoid)
    pcall(function()
        if humanoid and humanoid:IsA("Humanoid") then
            humanoid.MaxHealth = HEALTH_VALUE
            humanoid.Health = HEALTH_VALUE
        end
    end)
end

-- Hàm quét toàn bộ PlayerArmy và set máu
local function HealAllArmy()
    local playerArmy = workspace:FindFirstChild("PlayerArmy")
    if not playerArmy then return end

    for _, child in pairs(playerArmy:GetDescendants()) do
        if child:IsA("Humanoid") then
            SetInfiniteHealth(child)
        end
    end
end

-- Toggle Infinite Health
MainTab:CreateToggle({
    Name = "🩸 Infinite Health (Tất cả lính + Dragon)",
    CurrentValue = false,
    Flag = "InfiniteHealthToggle",
    Callback = function(Value)
        InfiniteHealthEnabled = Value

        if InfiniteHealthEnabled then
            -- Ngắt connection cũ nếu có
            if InfiniteHealthConnection then
                InfiniteHealthConnection:Disconnect()
            end

            -- Loop liên tục mỗi frame để giữ máu
            InfiniteHealthConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not InfiniteHealthEnabled then return end
                HealAllArmy()
            end)

            -- Lắng nghe lính mới được thêm vào
            local playerArmy = workspace:FindFirstChild("PlayerArmy")
            if playerArmy then
                playerArmy.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Humanoid") and InfiniteHealthEnabled then
                        task.wait(0.1)
                        SetInfiniteHealth(descendant)
                    end
                end)
            end

            Rayfield:Notify({
                Title = "✅ BẬT",
                Content = "Infinite Health đã được kích hoạt cho toàn bộ lính!",
                Duration = 3,
            })
        else
            -- Tắt
            if InfiniteHealthConnection then
                InfiniteHealthConnection:Disconnect()
                InfiniteHealthConnection = nil
            end

            Rayfield:Notify({
                Title = "❌ TẮT",
                Content = "Infinite Health đã tắt.",
                Duration = 3,
            })
        end
    end,
})

-- Nút Heal 1 lần (thủ công)
MainTab:CreateButton({
    Name = "💚 Heal All Army (1 lần)",
    Callback = function()
        HealAllArmy()
        Rayfield:Notify({
            Title = "💚 Đã Heal",
            Content = "Đã set máu tối đa cho toàn bộ lính 1 lần.",
            Duration = 3,
        })
    end,
})

-- Slider chỉnh giá trị máu
MainTab:CreateSlider({
    Name = "❤️ Giá trị máu",
    Range = {1000, 9999999999},
    Increment = 1000,
    Suffix = " HP",
    CurrentValue = HEALTH_VALUE,
    Flag = "HealthSlider",
    Callback = function(Value)
        HEALTH_VALUE = Value
    end,
})

-- ============================================
-- TAB THÔNG TIN
-- ============================================
local InfoTab = Window:CreateTab("📊 Info", 4483362458)

-- Hiển thị số lính hiện tại
InfoTab:CreateButton({
    Name = "📋 Đếm số lính trong PlayerArmy",
    Callback = function()
        local playerArmy = workspace:FindFirstChild("PlayerArmy")
        if not playerArmy then
            Rayfield:Notify({
                Title = "⚠️ Lỗi",
                Content = "Không tìm thấy workspace.PlayerArmy",
                Duration = 3,
            })
            return
        end

        local count = 0
        local names = {}
        for _, child in pairs(playerArmy:GetChildren()) do
            local hum = child:FindFirstChildWhichIsA("Humanoid")
            if hum then
                count = count + 1
                local status = string.format("%s: %.0f/%.0f HP", child.Name, hum.Health, hum.MaxHealth)
                table.insert(names, status)
            end
        end

        local info = table.concat(names, "\n")
        Rayfield:Notify({
            Title = "📊 Tổng: " .. count .. " lính",
            Content = count > 0 and info or "Không có lính nào",
            Duration = 8,
        })
    end,
})

-- Liệt kê tên các model/group
InfoTab:CreateButton({
    Name = "🔍 Liệt kê tất cả con trong PlayerArmy",
    Callback = function()
        local playerArmy = workspace:FindFirstChild("PlayerArmy")
        if not playerArmy then
            Rayfield:Notify({
                Title = "⚠️",
                Content = "Không tìm thấy PlayerArmy",
                Duration = 3,
            })
            return
        end

        local list = {}
        for _, child in pairs(playerArmy:GetChildren()) do
            table.insert(list, child.Name .. " [" .. child.ClassName .. "]")
        end

        print("=== PlayerArmy Children ===")
        for _, v in pairs(list) do
            print(v)
        end

        Rayfield:Notify({
            Title = "🔍 Đã in ra Console (F9)",
            Content = #list .. " objects found. Mở F9 để xem chi tiết.",
            Duration = 5,
        })
    end,
})

-- ============================================
-- AUTO DETECT - Tự động phát hiện PlayerArmy
-- ============================================
-- Nếu PlayerArmy chưa tồn tại, chờ nó xuất hiện
task.spawn(function()
    if not workspace:FindFirstChild("PlayerArmy") then
        Rayfield:Notify({
            Title = "⏳ Đang chờ...",
            Content = "Đang chờ PlayerArmy xuất hiện trong workspace...",
            Duration = 5,
        })

        local army = workspace:WaitForChild("PlayerArmy", 60)
        if army then
            Rayfield:Notify({
                Title = "✅ Đã tìm thấy!",
                Content = "PlayerArmy đã xuất hiện. Bật toggle để bắt đầu!",
                Duration = 5,
            })
        else
            Rayfield:Notify({
                Title = "⚠️ Timeout",
                Content = "Không tìm thấy PlayerArmy sau 60 giây.",
                Duration = 5,
            })
        end
    end
end)

print("[Army Immortal] Script loaded successfully!")
print("[Army Immortal] Sử dụng UI để bật Infinite Health")