-- === ANTI AVICSCRIPT - OPTIMIZED (NO LAG) ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local blocked = {
    "avicscript", "avic script", "avic", "avi c", "a v i c",
    "best script", "free script", "op script", "join my group", "discord.gg"
}

local function containBlocked(msg)
    if type(msg) ~= "string" then return false end
    local low = msg:lower()
    for _, v in ipairs(blocked) do
        if low:find(v:lower(), 1, true) then -- plain find, nhanh hơn
            return true
        end
    end
    return false
end

local function checkArgs(...)
    for _, arg in ipairs({...}) do
        if containBlocked(arg) then
            return true
        end
    end
    return false
end

-- ===== 1. Hook __namecall (ĐỦ ĐỂ CHẶN TẤT CẢ) =====
local oldnc
oldnc = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Chặn mọi FireServer/InvokeServer có nội dung blocked
    if method == "FireServer" or method == "InvokeServer" then
        if checkArgs(unpack(args)) then
            return
        end
    end

    -- Chặn Chat và SetCore
    if method == "Chat" or method == "SetCore" then
        if checkArgs(unpack(args)) then
            return
        end
    end

    -- Chặn SendAsync (TextChatService)
    if method == "SendAsync" then
        if checkArgs(unpack(args)) then
            return
        end
    end

    return oldnc(self, ...)
end)

-- ===== 2. Hook SayMessageRequest 1 lần duy nhất =====
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local sayRemote = RS:FindFirstChild("SayMessageRequest")
        or RS:WaitForChild("SayMessageRequest", 10)

    if sayRemote and sayRemote:IsA("RemoteEvent") then
        local oldFire
        oldFire = hookfunction(sayRemote.FireServer, function(self, msg, ...)
            if containBlocked(msg) then
                return
            end
            return oldFire(self, msg, ...)
        end)
        print("✅ Hooked SayMessageRequest")
    end
end)

-- ===== 3. Hook remote mới bằng DescendantAdded (KHÔNG QUÉT LẶP) =====
local hookedRemotes = {}

local function tryHookRemote(v)
    if not v:IsA("RemoteEvent") then return end
    if hookedRemotes[v] then return end

    local name = v.Name
    if not (name:find("Chat") or name:find("Message") or name:find("Say")) then
        return
    end

    hookedRemotes[v] = true

    local oldFire
    oldFire = hookfunction(v.FireServer, function(self, ...)
        if checkArgs(...) then
            return
        end
        return oldFire(self, ...)
    end)
end

-- Hook remote đã có sẵn (1 lần duy nhất)
for _, v in pairs(game:GetDescendants()) do
    pcall(tryHookRemote, v)
end

-- Hook remote mới được thêm (event-based, không loop)
game.DescendantAdded:Connect(function(v)
    task.defer(function()
        pcall(tryHookRemote, v)
    end)
end)

-- ===== 4. TextChatService (hook 1 lần, không loop) =====
pcall(function()
    local TCS = game:GetService("TextChatService")
    if TCS.ChatVersion ~= Enum.ChatVersion.TextChatService then return end

    local TextChannels = TCS:WaitForChild("TextChannels", 10)
    if not TextChannels then return end

    local hookedChannels = {}

    local function hookChannel(channel)
        if not channel:IsA("TextChannel") then return end
        if hookedChannels[channel] then return end
        hookedChannels[channel] = true

        local oldSend
        oldSend = hookfunction(channel.SendAsync, function(self, msg, ...)
            if containBlocked(msg) then
                return
            end
            return oldSend(self, msg, ...)
        end)
    end

    for _, ch in pairs(TextChannels:GetChildren()) do
        pcall(hookChannel, ch)
    end

    TextChannels.ChildAdded:Connect(function(ch)
        task.defer(function()
            pcall(hookChannel, ch)
        end)
    end)

    print("✅ Hooked TextChatService")
end)

print("🔥 ANTI-AVICSCRIPT ACTIVE (OPTIMIZED - NO LAG)")
task.wait(1)

-- Load script chính
loadstring(game:HttpGet("https://rawscripts.net/raw/Escape-Waves-For-Lucky-Blocks-Op-Escape-Tsunami-for-lucky-block-script-110898"))()