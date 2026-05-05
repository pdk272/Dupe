if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CONFIG =====
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"
local FILENAME = "server_history.json" -- File lưu lịch sử server để không bị trùng

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

-- ===== HÀM LƯU LỊCH SỬ SERVER =====
local function saveServer(jobId)
    local history = {}
    if isfile(FILENAME) then
        history = HttpService:JSONDecode(readfile(FILENAME))
    end
    history[jobId] = os.time()
    
    -- Dọn dẹp lịch sử cũ (xóa server đã lưu quá 1 tiếng để tránh file quá nặng)
    for id, timestamp in pairs(history) do
        if os.time() - timestamp > 3600 then history[id] = nil end
    end
    
    writefile(FILENAME, HttpService:JSONEncode(history))
end

local function isServerVisited(jobId)
    if not isfile(FILENAME) then return false end
    local history = HttpService:JSONDecode(readfile(FILENAME))
    return history[jobId] ~= nil
end

-- ===== CHUẨN HÓA & CHECK PET =====
local function Normalize(str) return (str or ""):lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1") end

local function MatchPet(name)
    name = Normalize(name)
    for _, pet in ipairs(TARGET_PETS) do
        if string.find(name, pet, 1, true) then return pet end
    end
end

-- ===== WEBHOOK =====
local function SendWebhook(foundList, count)
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if not req then return end

    local petText = ""
    for pet in pairs(foundList) do petText = petText .. "• " .. pet .. "\n" end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId
    
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🎯 ["..game:GetService("Players").LocalPlayer.Name.."] ĐÃ TÌM THẤY!",
                    description = "```\n" .. petText .. "```\nJobId: `" .. game.JobId .. "`\n\n[JOIN]("..link..")",
                    color = 0xFF0000, -- Màu đỏ cho nổi
                    footer = {text = "Server Time: " .. os.date("%X")}
                }}
            })
        })
    end)
end

-- ===== SERVER HOP THÔNG MINH =====
local function HopServer()
    saveServer(game.JobId) -- Lưu server hiện tại trước khi đi
    
    local function GetNext()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local s, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if s and res and res.data then
            for _, srv in ipairs(res.data) do
                if srv.id ~= game.JobId and srv.playing <= (srv.maxPlayers - 2) then
                    -- Kiểm tra xem server này acc nào đã vào chưa
                    if not isServerVisited(srv.id) then
                        return srv.id
                    end
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
        task.wait(15)
    end
end

-- ===== MAIN =====
local FOUND = {}
local COUNT = 0

task.spawn(function()
    print("🚀 Đang quét server...")
    for _, v in ipairs(workspace:GetDescendants()) do
        local p = MatchPet(v.Name)
        if p and not FOUND[p] then FOUND[p] = true COUNT += 1 end
    end

    if COUNT > 0 then
        SendWebhook(FOUND, COUNT)
        print("✅ Đã báo Discord. Đang đợi acc chính vào (45s)...")
        task.wait(45)
    else
        print("❌ Không có pet. Đang nhảy server...")
        task.wait(1)
    end
    HopServer()
end)
