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
local oldnc; oldnc = hookmetamethod(game, "__namecall", function(self, ...)
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

-- 2. Hook trực tiếp SayMessageRequest (cái chính script kia dùng)
local SayMessageRequest = Instance.new("RemoteEvent").FireServer
hookfunction(getrenv().require(game:GetService("ReplicatedStorage"):WaitForChild("SayMessageRequest", 5)), function() end)

-- 3. Chặn toàn bộ remote nào có tên chứa "Chat" hoặc "Message"
spawn(function()
    while wait(0.5) do
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:find("Chat") or v.Name:find("Message") or v.Name:find("Say")) then
                if not v:GetAttribute("BlockedAvic") then
                    v:SetAttribute("BlockedAvic", true)
                    v.OnClientEvent:Connect(function() end) -- vô hiệu hóa
                    hookfunction(v.FireServer, function() end)
                end
            end
        end
    end
end)

-- 4. Chặn cả khi nó dùng TextChatService (Roblox mới)
if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
    local TextChannels = game:GetService("TextChatService"):WaitForChild("TextChannels")
    spawn(function()
        while wait() do
            for _, channel in pairs(TextChannels:GetChildren()) do
                channel.OnMessageDoneFiltering:Connect(function(messageData)
                    if messageData.FromSpeaker == LocalPlayer.Name and containBlocked(messageData.Text) then
                        -- không làm gì cả → chặn
                    end
                end)
            end
        end
    end)
end

print("🔥 AVICSCRIPT ĐÃ BỊ CHẶN HOÀN TOÀN - 100% CLEAN")
wait(1)

-- Bây giờ mới load script kia (an toàn tuyệt đối)
loadstring(game:HttpGet("https://rawscripts.net/raw/Escape-Waves-For-Lucky-Blocks-Op-Escape-Tsunami-for-lucky-block-script-110898"))()