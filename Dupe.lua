--[[
    💀 TITAN BOT: SILENT ASSASSIN (NO-GUI VERSION)
    - Fix triệt để lỗi CoreGui nil value (Không dùng bất kỳ GUI nào).
    - Nhiệm vụ: Tự động nhảy Server -> Tìm Pet -> Báo Discord -> Lặp lại.
    - Status: Chạy ngầm 100%, im lặng tuyệt đối.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ================= CẤU HÌNH WEBHOOK =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local PETS_TO_FIND = {
    "garama",
    "hugedog",
    "chicleteirina",
    "bicicleterina"
}
-- ===================================================

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LPlr = game:GetService("Players").LocalPlayer

-- BỘ GỬI TÍN HIỆU ĐA NĂNG
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function NotifyDiscord(petName)
    if not httpRequest then 
        warn("Executor không hỗ trợ Webhook!")
        return 
    end

    local success, err = pcall(function()
        httpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                ["content"] = "||@everyone||",
                ["embeds"] = {{
                    ["title"] = "🎯 TÌM THẤY MỤC TIÊU HIẾM!",
                    ["description"] = "**Tên Pet:** `" .. petName .. "`\n**Mã Server (JobId):**\n```" .. game.JobId .. "
```",
                    ["color"] = tonumber("0x1abc9c")
                }}
            })
        })
    end)
    
    if success then
        print("✅ Đã bắn tín hiệu về Discord!")
    else
        warn("❌ Lỗi gửi Discord: " .. tostring(err))
    end
end

local function HopServer()
    print("🚀 Không thấy hàng ngon, đang nhảy Server...")
    task.wait(2)
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    end)

    if success then
        local data = HttpService:JSONDecode(result).data
        for _, s in pairs(data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LPlr)
                return
            end
        end
    else
        warn("❌ Không lấy được list Server!")
    end
end

-- VÒNG LẶP SÁT THỦ (CHẠY NGẦM)
task.spawn(function()
    print("🔍 Silent Bot đang rà soát...")
    task.wait(5) -- Đợi đồ trong map load ra

    local found = false
    -- Lọc toàn bộ đồ dưới đất
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, name in pairs(PETS_TO_FIND) do
                if obj.Name:lower():find(name:lower()) then
                    print("🎯 CHỐT HẠ: " .. obj.Name)
                    NotifyDiscord(obj.Name)
                    found = true
                    task.wait(3) -- Đợi gửi xong tin nhắn
                    break
                end
            end
        end
        if found then break end
    end
    
    -- Xong việc thì nhảy Server
    HopServer()
end)

print("💀 Silent Bot khởi động. F9 để xem log.")
