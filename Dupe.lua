if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local ACC_INDEX = 1 -- Đổi từ 1 đến 10
local MAX_ACCS = 10  
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

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
    "esok sekolah","spaghetti tualetti", "brainrot"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local function ScanPets()
    local found = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local name = v.Name:lower()
            for _, target in ipairs(TARGET_PETS) do
                if string.find(name, target, 1, true) then 
                    found[target] = true 
                end
            end
        end
    end
    local names = {}
    for k in pairs(found) do table.insert(names, k) end
    return table.concat(names, ", "), #names
end

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
                content = "🚨 **ACC " .. ACC_INDEX .. " THẤY HÀNG:** " .. petString,
                embeds = {{
                    title = "🚀 NHẤN ĐỂ VÀO GAME NHANH",
                    url = deepLink,
                    description = "**JobId:** `" .. game.JobId .. "`",
                    color = 0x00FF00
                }}
            })
        })
    end)
end

local function HopServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local s, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if s and res and res.data then
        local segment = math.floor(#res.data / MAX_ACCS)
        local startIdx = ((ACC_INDEX - 1) * segment) + 1
        local tid = res.data[startIdx] and res.data[startIdx].id
        if tid and tid ~= game.JobId then 
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tid) 
            return
        end
    end
    TeleportService:Teleport(game.PlaceId)
end

task.spawn(function()
    task.wait(5) -- Đợi đúng 5 giây load
    local res, count = ScanPets()
    if count > 0 then
        SendWebhook(res) -- Gửi thẳng Discord
        task.wait(60) -- Đợi ông vào
    end
    HopServer()
end)
