if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1  -- QUAN TRỌNG: Đổi số này cho mỗi acc (1, 2, 3... đến 10)
local MAX_ACCS = 10  
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"
local FILENAME = "server_history.json"

-- ===== TỐI ƯU HÓA GIẢM LAG (MÀN HÌNH ĐEN) =====
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
    "Ketupat Bros","Cloverat Clapat","Cash or Card",
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
    return found, count
end

-- ===== GỬI WEBHOOK =====
local function SendWebhook(foundList)
    local req = (syn and syn.request) or request or http_request
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
                    title = "🎯 TÌM THẤY PET HIẾM!",
                    description = "```\n" .. petText .. "```\n**Acc quét số:** " .. ACC_INDEX .. "\n**JobId:** `" .. game.JobId .. "`",
                    fields = {{name = "👉 Link Vào Ngay", value = "[NHẤN ĐỂ MỞ APP]("..deepLink..")", inline = false}},
                    color = 0x00FF00
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
    task.wait(5) -- Đợi đúng 5 giây như ông yêu cầu

    local list, c = ScanPets()

    if c > 0 then
        print("🎯 Đã thấy hàng! Báo Discord...")
        SendWebhook(list)
        task.wait(60) -- Tìm thấy thì đứng im 1 phút chờ ông vào húp
    else
        print("❌ Server này không có. Nhảy tiếp...")
    end
    
    HopServer()
end)
