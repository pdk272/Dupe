if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CONFIG =====
local ACC_INDEX = 1 -- ĐỔI SỐ NÀY CHO MỖI ACC (1, 2, 3...)
local MAX_ACCS = 10 -- Tổng số acc ông đang dùng để quét
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"
local FILENAME = "server_history.json" 

-- ===== TỐI ƯU HÓA GIẢM LAG (DÀNH CHO LOG NHIỀU ACC) =====
settings().Rendering.QualityLevel = 1
-- Dòng dưới đây sẽ tắt hình ảnh 3D để giảm CPU/RAM. Muốn xem lại hình thì đổi false thành true.
game:GetService("RunService"):Set3dRenderingEnabled(false) 

local TARGET_PETS = {
    "elefanto frigo", "dug dug dug", "las sis", "nuclearo dinossauro",
    "money money puggy", "chillin chili", "tang tang kelentang",
    "garama and madundung", "la secret combinasion", "dragon cannelloni",
    "los hotspotsitos", "tralaledon", "celularcini viciosini",
    "tictac sahur", "la supreme combinasion", "ketupat kepat",
    "ketchuru and musturu", "burguro and fryuro", "cooki and milki",
    "capitano moby", "cerberus", "skibidi toilet",
    "strawberry elephant", "lavadorito spinito"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ===== QUẢN LÝ LỊCH SỬ SERVER (CHỐNG TRÙNG) =====
local function saveServer(jobId)
    local history = {}
    pcall(function()
        if isfile(FILENAME) then
            history = HttpService:JSONDecode(readfile(FILENAME))
        end
    end)
    history[jobId] = os.time()
    -- Xóa lịch sử cũ sau 1 tiếng
    for id, ts in pairs(history) do
        if os.time() - ts > 3600 then history[id] = nil end
    end
    pcall(writefile, FILENAME, HttpService:JSONEncode(history))
end

local function isServerVisited(jobId)
    local success, history = pcall(function()
        return HttpService:JSONDecode(readfile(FILENAME))
    end)
    if success and history[jobId] then return true end
    return false
end

-- ===== CHUẨN HÓA & QUÉT PET =====
local function Normalize(str) return (str or ""):lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1") end

local function ScanPets()
    local found = {}
    local count = 0
    -- Quét nhanh ở Workspace bề nổi để đỡ lag
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") then
            local name = Normalize(v.Name)
            for _, target in ipairs(TARGET_PETS) do
                if string.find(name, target, 1, true) then
                    if not found[target] then
                        found[target] = true
                        count = count + 1
                    end
                end
            end
        end
    end
    return found, count
end

-- ===== GỬI WEBHOOK (SỬA LINK JOIN APP) =====
local function SendWebhook(foundList, count)
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if not req then return end

    local petText = ""
    for pet in pairs(foundList) do petText = petText .. "• " .. pet .. "\n" end

    -- Link mở thẳng App Roblox
    local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
    local webLink = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId
    
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🎯 ["..game:GetService("Players").LocalPlayer.Name.."] ĐÃ TÌM THẤY PET!",
                    description = "```\n" .. petText .. "```\n**Acc quét:** Acc số " .. ACC_INDEX .. "\n**JobId:** `" .. game.JobId .. "`",
                    fields = {
                        {name = "👉 Vào thẳng Game (Nhanh nhất)", value = "[NHẤN ĐỂ MỞ APP]("..deepLink..")", inline = false},
                        {name = "🔗 Link trình duyệt", value = "[Mở Web]("..webLink..")", inline = false}
                    },
                    color = 0x00FF00,
                    footer = {text = "Server Time: " .. os.date("%X")}
                }}
            })
        })
    end)
end

-- ===== SERVER HOP THÔNG MINH (CHIA VÙNG + CHỐNG KẸT) =====
local function HopServer()
    saveServer(game.JobId)
    print("🚀 Acc " .. ACC_INDEX .. " đang tìm server mới...")
    
    local function GetNext()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local s, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if s and res and res.data then
            local servers = res.data
            -- Chia vùng quét cho 10 acc
            local segment = math.floor(#servers / MAX_ACCS)
            local startIdx = ((ACC_INDEX - 1) * segment) + 1
            local endIdx = math.min(ACC_INDEX * segment, #servers)
            
            for i = startIdx, endIdx do
                local srv = servers[i]
                if srv and srv.id ~= game.JobId and srv.playing <= (srv.maxPlayers - 2) then
                    if not isServerVisited(srv.id) then return srv.id end
                end
            end
            
            -- Fallback: Nếu vùng được giao không có, lấy bất kỳ server vắng nào chưa đi
            for _, srv in ipairs(servers) do
                if srv.id ~= game.JobId and srv.playing <= (srv.maxPlayers - 3) then
                    if not isServerVisited(srv.id) then return srv.id end
                end
            end
        end
        return nil
    end

    while true do
        local tid = GetNext()
        if tid then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tid)
        else
            TeleportService:Teleport(game.PlaceId)
        end
        task.wait(15) -- Nếu bị kẹt (server full), đợi 15s rồi tìm server khác
        print("🔄 Đang thử nhảy lại...")
    end
end

-- ===== CHẠY CHÍNH =====
task.spawn(function()
    print("⚡ Bắt đầu quét...")
    local list, c = ScanPets()

    if c > 0 then
        SendWebhook(list, c)
        print("✅ Đã báo Discord. Đang đợi 60s...")
        task.wait(60) -- Tăng lên 60s cho chắc chắn ông kịp bấm link
    else
        print("❌ Không có pet. Đang chuyển server...")
        task.wait(0.5)
    end
    HopServer()
end)
