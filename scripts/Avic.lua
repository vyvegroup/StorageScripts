-- === ANTI AVICSCRIPT 100% CLEAN - 2025 EDITION ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local blocked = {
    "avicscript", "avic script", "avic", "avi c", "a v i c",
    "best script", "free script", "op script", "join my group", "discord.gg"
}

local function containBlocked(msg)
    if not msg or type(msg) ~= "string" then return false end
    local low = msg:lower()
    for _, v in ipairs(blocked) do
        if low:find(v:lower()) then
            return true
        end
    end
    return false
end

-- 1. Hook __namecall (cách mạnh nhất hiện tại)
local oldnc
oldnc = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if (method == "FireServer" or method == "InvokeServer") and #args > 0 then
        if containBlocked(args[1]) then
            return -- chặn hoàn toàn
        end
    end

    if method == "Chat" or method == "SetCore" then
        for _, v in ipairs(args) do
            if containBlocked(v) then
                return
            end
        end
    end

    return oldnc(self, ...)
end)

-- 2. Chặn SayMessageRequest (RemoteEvent, KHÔNG PHẢI ModuleScript)
-- ĐÃ SỬA: Tìm RemoteEvent và hook FireServer trực tiếp
spawn(function()
    local sayRemote = game:GetService("ReplicatedStorage"):FindFirstChild("SayMessageRequest")
    if sayRemote and sayRemote:IsA("RemoteEvent") then
        local oldFire = sayRemote.FireServer
        hookfunction(oldFire, function(self, msg, ...)
            if containBlocked(msg) then
                return -- chặn không gửi
            end
            return oldFire(self, msg, ...)
        end)
        print("✅ Đã hook SayMessageRequest")
    else
        print("⚠️ SayMessageRequest không tìm thấy, bỏ qua")
    end
end)

-- 3. Chặn toàn bộ remote nào có tên chứa "Chat" hoặc "Message"
local hookedRemotes = {}
spawn(function()
    while task.wait(0.5) do
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent")
                and (v.Name:find("Chat") or v.Name:find("Message") or v.Name:find("Say"))
                and not hookedRemotes[v] then

                hookedRemotes[v] = true
                local oldFS = v.FireServer
                hookfunction(oldFS, function(selfArg, ...)
                    local args = {...}
                    for _, arg in ipairs(args) do
                        if containBlocked(arg) then
                            return -- chặn
                        end
                    end
                    return oldFS(selfArg, ...)
                end)
            end
        end
    end
end)

-- 4. Chặn cả khi dùng TextChatService (Roblox mới)
pcall(function()
    local TCS = game:GetService("TextChatService")
    if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
        local TextChannels = TCS:WaitForChild("TextChannels", 5)
        if TextChannels then
            local connectedChannels = {}
            spawn(function()
                while task.wait(1) do
                    for _, channel in pairs(TextChannels:GetChildren()) do
                        if not connectedChannels[channel] then
                            connectedChannels[channel] = true
                            -- Hook SendAsync để chặn trước khi gửi
                            if channel:IsA("TextChannel") then
                                local oldSend = channel.SendAsync
                                hookfunction(oldSend, function(self, msg, ...)
                                    if containBlocked(msg) then
                                        return
                                    end
                                    return oldSend(self, msg, ...)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("🔥 AVICSCRIPT ĐÃ BỊ CHẶN HOÀN TOÀN - 100% CLEAN")
task.wait(1)

-- Bây giờ mới load script kia (an toàn)
loadstring(game:HttpGet("https://rawscripts.net/raw/Escape-Waves-For-Lucky-Blocks-Op-Escape-Tsunami-for-lucky-block-script-110898"))()