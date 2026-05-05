--[[
    💀 TITAN BOT V34.0 - TRỊ DỨT ĐIỂM LỖI CORE GUI
    - Tuyệt đối không tạo GUI (Tránh hoàn toàn lỗi CoreGui: nil).
    - Tự động nhận diện Executor để gửi Webhook.
    - Added Pets: Chicleteirina, Bicicleterina.
    - Logic: Quét -> Báo Discord -> Nhảy Server.
]]

-- Chờ game load xong
if not game:IsLoaded() then game.Loaded:Wait() end

-- ================= CẤU HÌNH (THAY LINK CỦA ÔNG) =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local TARGET_PETS = {
    "garama",
    "chicleteirina",
    "bicicleterina",
    "hugedog"
}
-- ===============================================================

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LPlr = game:GetService("Players").LocalPlayer

-- Kiểm tra hàm request của từng loại Executor (Fix lỗi nil khi gọi Webhook)
local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function SendToDiscord(petName)
    if not request_func then 
        print("Executor này không hỗ trợ gửi Webhook!")
        return 
    end

    pcall(function()
        request_func({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                ["content"] = "@everyone",
                ["embeds"] = {{
                    ["title"] = "🚨 ĐÃ TÌM THẤY HÀNG NGON!",
                    ["description"] = "**Tên Pet:** `" .. petName .. "`\n**JobId (Mã Server):**\n```" .. game.JobId .. "
```",
                    ["color"] = 16711680 -- Màu đỏ
                }}
            })
        })
    end)
end

local function JumpServer()
    print("Đang nhảy sang server khác...")
    task.wait(1)
    local success, response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    end)

    if success then
        local servers = HttpService:JSONDecode(response).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LPlr)
                return
            end
        end
    end
end

-- VÒNG LẶP QUÉT NGẦM
task.spawn(function()
    print("Bot đang quét ngầm, F9 để xem log...")
    task.wait(6) -- Đợi 6 giây cho map rớt đồ ra hết

    local isFound = false
    -- Quét toàn bộ vật thể trong Workspace (Kể cả folder Shops hay Pet)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local objName = obj.Name:lower()
            for _, target in pairs(TARGET_PETS) do
                if objName:find(target:lower()) then
                    print("🎯 PHÁT HIỆN: " .. obj.Name)
                    SendToDiscord(obj.Name)
                    isFound = true
                    task.wait(2) -- Đợi gửi Webhook thành công
                    break
                end
            end
        end
        if isFound then break end
    end

    -- Nhảy server dù có thấy hay không để tìm tiếp
    JumpServer()
end)

print("V34.0: TRUE SILENT BOT IS RUNNING...")
