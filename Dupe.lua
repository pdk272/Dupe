if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1  -- Đổi cho mỗi acc (1, 2, 3...)
local MAX_ACCS = 10 
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"
local FILENAME = "server_history.json"

-- ===== TẮT RENDER GIẢM LAG =====
settings().Rendering.QualityLevel = 1
game:GetService("RunService"):Set3dRenderingEnabled(false) 

local TARGET_PETS = {
    "elefanto frigo", "dug dug dug", "las sis", "nuclearo dinossauro",
    "money money puggy", "chillin chili", "tang tang kelentang",
    "garama and madundung", "la secret combinasion", "dragon cannelloni",
    "los hotspotsitos", "tralaledon", "celularcini viciosini",
    "tictac sahur", "la supreme combinasion", "ketupat kepat",
    "ketchuru and musturu", "burguro and fryuro", "cooki and milki",
    "capitano moby", "cerberus", "skibidi toilet",
    "strawberry elephant", "lavadorito spinito","Guest 666",
    "La Ginger Sekolah","Dragon Gingerini","Jolly Jolly Sahur",
    "Ketupat Bros","Ketupat Bros","Cloverat Clapat","Cash or Card",
    "Pretzo Robo","John Doe","Money Money Bros","Mariachi Corazoni",
    "Hydra Bunny","Celestial Pegasus","Los Amigos","Fragola La La La",
    "Mieteteira Bicicleteira","Los Puggies","Los Spaghettis","La Spooky Grande",
    "Antonio","La Casa Boo","Reinito Sleighito","Popcuru and Fizzuru","Quackini Snackini",
    "Los Mariachis","Gym Bros","Fortunu and Cashuru","Esok Sekolah","Spaghetti Tualetti"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ===== LỊCH SỬ SERVER =====
local function saveServer(jobId)
    local history = {}
    pcall(function()
        if isfile(FILENAME) then history = HttpService:JSONDecode(readfile(FILENAME)) end
    end)
    history[jobId] = os.time()
    for id, ts in pairs(history) do if os.time() - ts > 3600 then history[id] = nil end end
    pcall(writefile, FILENAME, HttpService:JSONEncode(history))
end

local function isServerVisited(jobId)
    local s, history = pcall(function() return HttpService:JSONDecode(readfile(FILENAME)) end)
    return s and history[jobId] ~= nil
end

-- ===== HÀM QUÉT PET (QUÉT SÂU) =====
local function ScanPets()
    local found = {}
    local count = 0
    -- Quét toàn bộ vật thể trong Workspace
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local name = v.Name:lower()
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

-- ===== GỬI WEBHOOK (LINK DEEP JOIN) =====
local function SendWebhook(foundList, count)
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if not req then return end

    local petText = ""
    for pet in pairs(foundList) do petText = petText .. "• " .. pet .. "\n" end

    local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
    
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🎯 ["..game:GetService("Players").LocalPlayer.Name.."] ĐÃ TÌM THẤY PET!",
                    description = "```\n" .. petText .. "```\n**Acc quét:** " .. ACC_INDEX .. "\n**JobId:** `" .. game.JobId .. "`",
                    fields = {
                        {name = "👉 Link App (Vào ngay)", value = "[NHẤN ĐỂ MỞ APP]("..deepLink..")", inline = false}
                    },
                    color = 0x00FF00
                }}
            })
        })
    end)
end

-- ===== SERVER HOP (CHIA VÙNG + CHỐNG KẸT) =====
local function HopServer()
    saveServer(game.JobId)
    local function GetNext()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local s, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if s and res and res.data then
            local servers = res.data
            local segment = math.floor(#servers / MAX_ACCS)
            local startIdx = ((ACC_INDEX - 1) * segment) + 1
            local endIdx = math.min(ACC_INDEX * segment, #servers)
            
            for i = startIdx, endIdx do
                local srv = servers[i]
                if srv and srv.id ~= game.JobId and srv.playing <= (srv.maxPlayers - 2) then
                    if not isServerVisited(srv.id) then return srv.id end
                end
            end
            -- Fallback
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
        if tid then TeleportService:TeleportToPlaceInstance(game.PlaceId, tid)
        else TeleportService:Teleport(game.PlaceId) end
        task.wait(15)
    end
end

-- ===== CHẠY CHÍNH =====
task.spawn(function()
    print("⏳ Đang đợi 5 giây cho map và pet load...")
    task.wait(5) -- Đợi 5 giây theo yêu cầu của ông

    print("⚡ Bắt đầu quét kỹ server...")
    local list, c = ScanPets()

    if c > 0 then
        print("🎯 TÌM THẤY! Đang báo lên Discord...")
        SendWebhook(list, c)
        task.wait(60) -- Đợi ông nhấn join
    else
        print("❌ Không có pet. Chuẩn bị nhảy server...")
        task.wait(1)
    end
    
    HopServer()
end)
