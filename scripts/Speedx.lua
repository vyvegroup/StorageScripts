local url = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua"
local code = game:HttpGet(url, true)
local func = loadstring(code)

if func then
    -- Lấy môi trường global hiện tại của executor
    local global_env = getgenv and getgenv() or getfenv(0)
    
    -- 1. Tạo môi trường giả kế thừa mọi thứ từ global
    local fake_env = setmetatable({}, { __index = global_env })
    
    -- 2. Làm giả bảng 'os'
    local fake_os = setmetatable({}, { __index = os })
    fake_os.date = function(format, time)
        -- Hook logic: Ép thời gian trả về là Thứ 7 hoặc Chủ nhật
        if format == "*t" then
            local t = os.date("*t", time)
            t.wday = 7 -- Ép luôn là Thứ 7 (tuỳ hệ thống: 1 hoặc 7 là cuối tuần)
            return t
        elseif type(format) == "string" and string.match(format, "%%w") then
            return "6" -- 6 thường đại diện cho Thứ 7 trong định dạng %w
        end
        -- Trả về bình thường cho các format khác để script không bị lỗi crash
        return os.date(format, time)
    end
    -- Có thể cần hook thêm fake_os.time nếu script check os.time()
    fake_env.os = fake_os
    
    -- 3. QUAN TRỌNG: Làm giả loadstring để "lây lan" môi trường
    fake_env.loadstring = function(child_code, chunkname)
        local child_func, err = loadstring(child_code, chunkname)
        if child_func then
            -- Áp dụng tiếp fake_env cho hàm con vừa được load
            setfenv(child_func, fake_env) 
        end
        return child_func, err
    end
    
    -- 4. Áp dụng môi trường cho script gốc và chạy
    setfenv(func, fake_env)
    func()
end