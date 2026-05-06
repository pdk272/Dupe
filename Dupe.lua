if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1 
local MAX_ACCS = 10  
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

settings().Rendering.QualityLevel = 1
game:GetService("RunService"):Set3dRenderingEnabled(false) 

local TARGET_PETS = {
    "elefanto frigo", "dug dug dug", "las sis", "nuclearo dinossauro",
    "money money puggy", "chillin chili", "tang tang kelentang",
    "garama and madundung", "la secret combinasion", "dragon cannelloni",
    "los hotspotsitos", "tralaledon", "celularcini viciosini",
    "tictac sahur", "la supreme combinasion", "ketupat kepat",
    "ketchuru and musturu", "burguro and fryuro", "cooki and milki",
    "capitano moby", "cerberus", "skibidi toilet", "strawberry elephant", 
    "lavadorito spinito","guest 666", "la ginger sekolah","dragon gingerini",
    "jolly jolly sahur", "ketupat bros","cloverat clapat","cash or card",
    "pretzo robo","john doe","money money bros","mariachi corazoni",
    "hydra bunny","celestial pegasus","los amigos","fragola la la la",
    "mieteteira bicicleteira","los puggies","los spaghettis","la spooky grande",
    "antonio","la casa boo","reinito sleighito","popcuru and fizzuru",
    "quackini snackini", "los mariachis","gym bros","fortunu and cashuru",
    "esok sekolah","spaghetti tualetti"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local MessagingService = game:GetService("MessagingService")

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
    local petNames = {}
    for k in pairs(found) do table.insert(petNames, k) end
    return table.concat(petNames, ", "), count
end

local function Broadcast(petString)
    local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
    
    -- 1. BÁO LÊN DISCORD
    task.spawn(function()
        local req = (syn and syn.request) or request or http_request
        if req then
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "🚨 **ACC " .. ACC_INDEX .. " THẤY HÀNG:** " .. petString,
                    embeds = {{
                        title = "🚀 BẤM ĐỂ HÚP NGAY",
                        url = deepLink,
                        description = "JobId: `" .. game.JobId .. "`",
                        color = 0x00FF00
                    }}
                })
            })
        end
    end)

    -- 2. BÁO VỀ ACC CHÍNH (MASTER GUI)
    task.spawn(function()
        pcall(function()
            MessagingService:PublishAsync("BrainrotFinderSignal", {
                PetName = petString,
                JobId = game.JobId,
                Players = #game:GetService("Players"):GetPlayers() .. "/8",
                AccSource = ACC_INDEX
            })
        end)
    end)
end

-- ===== NHẢY SERVER =====
local function HopServer()
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
                    return srv.id
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

task.spawn(function()
    task.wait(5) 
    local res, count = ScanPets()
    if count > 0 then
        Broadcast(res)
        task.wait(60) 
    end
    HopServer()
end)
