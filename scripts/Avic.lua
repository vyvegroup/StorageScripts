-- ====== CHẠY CÁI NÀY TRƯỚC ======

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Danh sách từ khóa cần chặn (thêm bớt tùy ý)
local blockedKeywords = {
    "avicscript",
    "avic",
    "avi script",
    -- Thêm từ khóa khác nếu cần
}

-- Hàm kiểm tra tin nhắn có chứa từ cấm không
local function isBlocked(message)
    local lower = string.lower(message)
    for _, keyword in ipairs(blockedKeywords) do
        if string.find(lower, string.lower(keyword)) then
            return true
        end
    end
    return false
end

-- ======= HOOK HÀM CHAT (namecall hook) =======
-- Chặn mọi cách gọi :Chat(), :FireServer() liên quan đến chat

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Chặn :FireServer() trên RemoteEvent chat
    if method == "FireServer" then
        local remoteName = ""
        pcall(function()
            remoteName = self.Name
        end)

        -- Kiểm tra nếu là remote liên quan đến chat
        local chatRemotes = {
            "SayMessageRequest",      -- Chat mặc định
            "SendMessage",            -- Một số game custom
            "ChatMessage",
            "DefaultChatSystemChatBar",
        }

        for _, name in ipairs(chatRemotes) do
            if string.find(remoteName, name) then
                for _, arg in ipairs(args) do
                    if type(arg) == "string" and isBlocked(arg) then
                        warn("[ANTI-SPAM] Đã chặn chat quảng cáo: " .. arg)
                        return nil -- Không gửi
                    end
                end
            end
        end
    end

    -- Chặn :Chat() method
    if method == "Chat" then
        for _, arg in ipairs(args) do
            if type(arg) == "string" and isBlocked(arg) then
                warn("[ANTI-SPAM] Đã chặn :Chat() quảng cáo: " .. arg)
                return nil
            end
        end
    end

    return oldNamecall(self, ...)
end))

-- ======= HOOK FireServer trực tiếp =======
-- Phòng trường hợp script gọi FireServer trực tiếp không qua namecall

local oldFireServer
oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    local args = {...}
    local remoteName = ""
    pcall(function()
        remoteName = self.Name
    end)

    if string.find(remoteName, "SayMessageRequest") or string.find(remoteName, "SendMessage") then
        for _, arg in ipairs(args) do
            if type(arg) == "string" and isBlocked(arg) then
                warn("[ANTI-SPAM] Đã chặn FireServer quảng cáo: " .. arg)
                return nil
            end
        end
    end

    return oldFireServer(self, ...)
end))

-- ======= CHẶN THÊM: Hook toàn bộ string đi qua mọi remote =======
-- Dự phòng nếu script dùng remote tên lạ

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
    if type(value) == "string" and isBlocked(value) then
        -- Nếu đang set text liên quan chat
        if key == "Text" or key == "Message" then
            warn("[ANTI-SPAM] Đã chặn gán text quảng cáo")
            return oldNewIndex(self, key, "")
        end
    end
    return oldNewIndex(self, key, value)
end))

print("✅ Anti-Spam đã bật! Mọi chat chứa từ cấm sẽ bị chặn.")
print("========================================")

-- ====== SAU ĐÓ MỚI LOAD SCRIPT GỐC ======
wait(1)
loadstring(game:HttpGet("https://rawscripts.net/raw/Escape-Waves-For-Lucky-Blocks-Op-Escape-Tsunami-for-lucky-block-script-110898"))()