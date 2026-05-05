--[[
    📡 TITAN BOT V32.0 (DEBUG MODE)
    - Tự động nhận diện mọi loại Executor (Fluxus, Delta, Solara, Wave...)
    - Báo cáo lỗi chi tiết qua Console (F9)
    - Fix lỗi "attempt to call a nil value"
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ================= CẤU HÌNH =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local PETS_TO_FIND = {
    "garama",    -- Ghi chính xác tên pet trong Workspace (thường là viết thường)
    "hugedog",
    "Chicleteirina Bicicleterina"
}
-- ============================================

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LPlr = game:GetService("Players").LocalPlayer

-- BỘ GIẢI MÃ REQUEST (CHỐNG LỖI NIL)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function SendWebhook(petName)
    if not httpRequest then 
        warn("❌ Executor của ông 'phế' quá, không có hàm request để gửi Webhook!")
        return 
    end

    local success, err = pcall(function()
        httpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                ["content"] = "@everyone",
                ["embeds"] = {{
                    ["title"] = "🎯 MỤC TIÊU XUẤT HIỆN!",
                    ["description"] = "**Pet:** `" .. petName .. "`\n**Mã Server (JobId):**\n```" .. game.JobId .. "
```",
                    ["color"] = 0x00FFFF
                }}
            })
        })
    end)
    
    if success then print("✅ Đã gửi mật báo lên Discord!") else warn("❌ Gửi Webhook thất bại: " .. tostring(err)) end
end

local function ServerHop()
    print("🚀 Đang tìm server mới...")
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
        warn("❌ Không lấy được danh sách server!")
    end
end

-- VÒNG LẶP QUÉT (LOGIC THÔNG MINH)
task.spawn(function()
    print("🔍 Đang rà soát toàn bộ server...")
    task.wait(5) -- Đợi map load

    local targetFound = false
    -- Quét toàn bộ vật thể trong Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        for _, name in pairs(PETS_TO_FIND) do
            if obj.Name:lower():find(name:lower()) then
                print("🎯 PHÁT HIỆN: " .. obj.Name)
                SendWebhook(obj.Name)
                targetFound = true
                task.wait(2)
                break
            end
        end
        if targetFound then break end
    end

    if not targetFound then print("💀 Server này toàn rác, nhảy tiếp!") end
    
    task.wait(1)
    ServerHop()
end)
