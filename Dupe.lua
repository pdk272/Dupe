if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1  -- Đổi từ 1 đến 10 cho mỗi acc
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
    "capitano moby", "cerberus", "skibidi toilet",
    "strawberry elephant", "lavadorito spinito","guest 666",
    "la ginger sekolah","dragon gingerini","jolly jolly sahur",
    "ketupat bros","cloverat clapat","cash or card",
    "pretzo robo","john doe","money money bros","mariachi corazoni",
    "hydra bunny","celestial pegasus","los amigos","fragola la la la",
    "mieteteira bicicleteira","los puggies","los spaghettis","la spooky grande",
    "antonio","la casa boo","reinito sleighito","popcuru and fizzuru","quackini snackini",
    "los mariachis","gym bros","fortunu and cashuru","esok sekolah","spaghetti tualetti"
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

-- ===== HÀM QUÉT PET =====
local function ScanPets()
    local found = {}
    local count = 0
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
    
    local petString = ""
    if count > 0 then
        for petName, _ in pairs(found) do
            petString = petString .. "✅ " .. petName .. "\n"
        end
    end
    return petString, count
end

-- ===== GỬI WEBHOOK (CÓ NÚT SAO CHÉP JOBID) =====
local function SendWebhook(petString)
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
                    title = "🎯 [" .. (ACC_INDEX == 1 and "MASTER" or "ACC " .. ACC_INDEX) .. "] ĐÃ THẤY PET!",
                    description = "📦 **Danh sách Pet:**\n" .. petString,
                    fields = {
                        {
                            name = "🔑 JobId (Nhấn để chọn và Copy)", 
                            value = "```" .. game.JobId .. "```", 
                            inline = false
                        },
                        {
                            name = "🚀 Vào Server Nhanh", 
                            value = "[NHẤN VÀO ĐÂY ĐỂ MỞ ROBLOX](" .. deepLink .. ")", 
                            inline = false
                        }
                    },
                    color = 0x00FF00,
                    footer = {text = "Dùng RAM + Bloxstrap để treo 24/24 | Acc số: " .. ACC_INDEX}
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
        if tid then TeleportService:TeleportToPlaceInstance(game.PlaceId, tid) end
        task.wait(5)
    end
end

-- ===== CHẠY CHÍNH =====
task.spawn(function()
    print("⏳ Chờ 5 giây cho Pet load...")
    task.wait(5) 

    local petResult, totalFound = ScanPets()

    if totalFound > 0 then
        print("🎯 Đã thấy hàng! Đang báo lên Discord...")
        SendWebhook(petResult)
        task.wait(60) -- Giữ server 1 phút để ông kịp copy JobId hoặc bấm Join
    else
        print("❌ Server trống. Đang nhảy...")
    end
    
    HopServer()
end)
