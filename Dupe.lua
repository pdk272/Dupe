if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1  
local MAX_ACCS = 10  
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"
local FILENAME = "server_history.json"

-- ===== TỐI ƯU =====
pcall(function()
    settings().Rendering.QualityLevel = 1
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end)

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
    "los mariachis","cerberus","fortunu and cashuru","cigo","spaghetti tualetti",
    "OG","esok sekola"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- ===== SERVER HISTORY (FIX) =====
local function loadHistory()
    local data = {}
    pcall(function()
        if isfile(FILENAME) then
            data = HttpService:JSONDecode(readfile(FILENAME))
        end
    end)
    return data
end

local function saveHistory(data)
    pcall(writefile, FILENAME, HttpService:JSONEncode(data))
end

local function saveServer(jobId)
    local history = loadHistory()
    history[jobId] = os.time()

    for id, ts in pairs(history) do
        if os.time() - ts > 86400 then -- 1 ngày
            history[id] = nil
        end
    end

    saveHistory(history)
end

local function isServerVisited(jobId)
    local history = loadHistory()
    return history[jobId] ~= nil
end

-- ===== SCAN PET (GIỮ NGUYÊN LOGIC + THÊM LỌC TRÙNG) =====
local function ScanPets()
    local foundList = {}
    local totalCount = 0
    local seen = {}

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local name = v.Name:lower()

            for _, target in ipairs(TARGET_PETS) do
                if string.find(name, target, 1, true) then
                    if not seen[v.Name] then
                        seen[v.Name] = true
                        totalCount += 1
                        table.insert(foundList, "✅ ["..totalCount.."] " .. v.Name)
                    end
                    break
                end
            end
        end
    end

    return table.concat(foundList, "\n"), totalCount
end

-- ===== SCAN LOOP (THÊM MỚI - QUAN TRỌNG) =====
local function ScanLoop(duration)
    local finalList = {}
    local total = 0
    local cache = {}

    local start = tick()
    while tick() - start < duration do
        local res, count = ScanPets()

        if count > 0 then
            for line in string.gmatch(res, "[^\n]+") do
                if not cache[line] then
                    cache[line] = true
                    table.insert(finalList, line)
                    total += 1
                end
            end
        end

        task.wait(2)
    end

    return table.concat(finalList, "\n"), total
end

-- ===== WEBHOOK =====
local function SendWebhook(petString, count)
    local req = (syn and syn.request) or request or http_request
    if not req then return end

    local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId

    req({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            embeds = {{
                title = "🎯 PHÁT HIỆN " .. count .. " PET HIẾM!",
                description = petString .. "\n\n🔑 JobId: "..game.JobId,
                color = 0x00FF00
            }}
        })
    })
end

-- ===== HOP SERVER (FIX) =====
local function HopServer()
    saveServer(game.JobId)

    local function GetNext()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local s, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if s and res and res.data then
            local servers = res.data
            local segment = math.max(1, math.floor(#servers / MAX_ACCS))

            local startIdx = ((ACC_INDEX - 1) * segment) + 1
            local endIdx = math.min(ACC_INDEX * segment, #servers)

            for i = startIdx, endIdx do
                local srv = servers[i]
                if srv and srv.id ~= game.JobId then
                    if srv.playing >= 2 and srv.playing <= 12 then
                        if not isServerVisited(srv.id) then
                            return srv.id
                        end
                    end
                end
            end
        end
    end

    while true do
        local tid = GetNext()

        if tid then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tid)
        else
            TeleportService:Teleport(game.PlaceId)
        end

        task.wait(5)
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⏳ Đợi load...")
    task.wait(5)

    local res, count = ScanLoop(15) -- 🔥 thay vì scan 1 lần

    if count > 0 then
        print("🎯 Found "..count)
        SendWebhook(res, count)
        task.wait(60)
    else
        print("❌ Không có")
    end

    HopServer()
end)
