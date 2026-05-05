--[[
    📡 TITAN BOT: SERVER SCANNER & HOPPER
    - Chạy trên Acc Phụ. 
    - Nhảy Server -> Quét Workspace -> Báo Webhook -> Nhảy tiếp.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ================= CẤU HÌNH CỦA ÔNG =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local PETS_TO_FIND = {
    "garama",    -- Ghi tên pet viết thường
    "hugedog",
    "chihuanini taconini"
}
-- ====================================================

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LPlr = game:GetService("Players").LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

local function SendWebhook(petName)
    local data = {
        ["content"] = "||@everyone||", -- Ping mọi người (xóa dòng này nếu không thích ồn ào)
        ["embeds"] = {{
            ["title"] = "🚨 PHÁT HIỆN PET VIP!",
            ["description"] = "**Pet tìm thấy:** `" .. petName .. "`\n**Mã Server (JobId):**\n```" .. JobId .. "
```\n*Hãy copy mã JobId này và dùng lệnh Teleport để join!*",
            ["color"] = tonumber("0x00FFFF")
        }}
    }
    
    local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
    if req then
        pcall(function()
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    else
        print("Executor của ông không hỗ trợ gửi Webhook!")
    end
end

local function ServerHop()
    print("Đang tìm Server mới để nhảy...")
    task.wait(2)
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    
    if success and servers then
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LPlr)
                task.wait(5)
            end
        end
    end
end

task.spawn(function()
    print("Bắt đầu quét Server...")
    task.wait(3) 
    
    local found = false
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Model") or item:IsA("BasePart") then
            for _, vipPet in pairs(PETS_TO_FIND) do
                if item.Name:lower():find(vipPet) then
                    print("🎯 TÌM THẤY: " .. item.Name)
                    SendWebhook(item.Name)
                    found = true
                    task.wait(3) -- Đợi gửi xong Webhook
                    break
                end
            end
        end
        if found then break end 
    end

    if not found then
        print("Server này không có pet, đang nhảy...")
    end
    
    ServerHop()
end)
