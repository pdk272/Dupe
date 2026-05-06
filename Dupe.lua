if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1  
local MAX_ACCS = 10  
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"
local FILENAME = "server_history.json"

-- ===== TỐI ƯU GIẢM LAG (MÀN HÌNH ĐEN) =====
settings().Rendering.QualityLevel = 1
game:GetService("RunService"):Set3dRenderingEnabled(false) 

local TARGET_PETS = {
    "elefanto frigo", "dug dug dug", "las sis", "nuclearo dinossauro",
    "money money puggy", "chillin chili", "tang tang kelentang",
    "garama and madundung", "la secret combinasion", "dragon cannelloni",
    "los hotspotsitos", "tralaledon", "celularcini viciosini",
    "tictac sahur", "la supreme combinasion", "ketupat kepat",
    "ketchuru and musturu", "burguro and fryuro", "cooki and milki",
    "capitano moby", "gues 666", "skibidi toilet",
    "strawberry elephant", "lavadorito spinito","guest 666",
    "la ginger sekolah","dragon gingerini","jolly jolly sahur",
    "ketupat bros","cloverat clapat","cash or card",
    "pretzo robo","john doe","money money bros","mariachi corazoni",
    "hydra bunny","ketupat bros","los amigos","fragola la la la",
    "mieteteira bicicleteira","los puggies","los spaghettis","la spooky grande",
    "antonio","la casa boo","reinito sleighito","popcuru and fizzuru","quackini snackini",
    "los mariachis","cerberus","fortunu and cashuru","pipi kiwi","spaghetti tualetti",
    "OG","esok sekola"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = game:GetService("Players").LocalPlayer

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

-- ===== HÀM QUÉT PET TỐI ƯU (KHÔNG SÓT CON NÀO) =====
local function ScanPets()
    local foundList = {}
    local totalCount = 0
    
    -- Quét sâu vào toàn bộ workspace
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local name = v.Name:lower()
            for _, target in ipairs(TARGET_PETS) do
                if string.find(name, target, 1, true) then
                    totalCount = totalCount + 1
                    table.insert(foundList, "✅ ["..totalCount.."] " .. v.Name)
                    break -- Tìm thấy tên khớp thì nhảy sang vật thể tiếp theo
                end
            end
        end
    end
    
    local petString = table.concat(foundList, "\n")
    return petString, totalCount
end

-- ===== GỬI WEBHOOK =====
local function SendWebhook(petString, count)
    local req = (syn and syn.request) or request or http_request
    if not req then return end
    local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
    
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🎯 PHÁT HIỆN " .. count .. " PET HIẾM!",
                    description = "👤 **Acc:** `" .. LocalPlayer.Name .. "` (Vùng " .. ACC_INDEX .. ")\n\n📦 **Danh sách chi tiết:**\n" .. petString .. "\n\n🔑 **JobId:** `" .. game.JobId .. "`",
                    fields = {{name = "🚀 Join Server", value = "[BẤM VÀO ĐÂY ĐỂ VÀO HÚP]("..deepLink..")", inline = false}},
                    color = 0x00FF00,
                    footer = {text = "Thời gian: " .. os.date("%X") .. " | Bot ID: " .. ACC_INDEX}
                }}
            })
        })
    end)
end

-- ===== NHẢY SERVER =====
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
        end
        return nil
    end
    while true do
        local tid = GetNext()
        if tid then TeleportService:TeleportToPlaceInstance(game.PlaceId, tid)
        else TeleportService:Teleport(game.PlaceId) end
        task.wait(5)
    end
end

-- ===== CHẠY CHÍNH =====
task.spawn(function()
    print("⏳ Đợi 5s cho acc: " .. LocalPlayer.Name .. " load pet...")
    task.wait(5) 
    
    local res, count = ScanPets()
    
    if count > 0 then
        print("🎯 Tìm thấy " .. count .. " pet! Đang báo lên Discord...")
        SendWebhook(res, count)
        print("⏳ Đang đợi 60s cho ông vào húp...")
        task.wait(60) -- Đợi 1 phút chuẩn chỉ
    else
        print("❌ Không thấy gì, đang đổi server...")
    end
    
    HopServer()
end)
