if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local ACC_INDEX = 1 
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
    "esok sekolah","spaghetti tualetti"
}

local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

local function ScanPets()
    local found = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local name = v.Name:lower()
            for _, target in ipairs(TARGET_PETS) do
                if string.find(name, target, 1, true) then found[target] = true end
            end
        end
    end
    local names = {}
    for k in pairs(found) do table.insert(names, k) end
    return table.concat(names, ", "), #names
end

local function SendToDiscord(petString)
    local request_func = (syn and syn.request) or request or http_request
    if not request_func then 
        warn("❌ Executor của ông éo hỗ trợ gửi Discord!")
        return 
    end

    local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
    local data = {
        content = "🚨 **BOT " .. ACC_INDEX .. " THẤY HÀNG:** " .. petString,
        embeds = {{
            title = "🚀 BẤM VÀO ĐÂY ĐỂ HÚP",
            url = deepLink,
            description = "JobId: `" .. game.JobId .. "`",
            color = 0x00FF00
        }}
    }

    local success, res = pcall(function()
        return request_func({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)

    if success then
        print("✅ Báo Discord thành công!")
    else
        warn("❌ Lỗi gửi Discord: ", res)
    end
end

local function Broadcast(petString)
    -- Gửi Discord trực tiếp
    SendToDiscord(petString)
    
    -- Gửi Master GUI
    pcall(function()
        MessagingService:PublishAsync("HupPet_Channel", {
            PetName = petString,
            JobId = game.JobId,
            AccSource = ACC_INDEX
        })
    end)
end

-- Hàm nhảy server tui rút gọn cho nhẹ
local function HopServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local s, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if s and res and res.data then
        local segment = math.floor(#res.data / MAX_ACCS)
        local startIdx = ((ACC_INDEX - 1) * segment) + 1
        local tid = res.data[startIdx] and res.data[startIdx].id
        if tid and tid ~= game.JobId then 
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, tid) 
            return
        end
    end
    game:GetService("TeleportService"):Teleport(game.PlaceId)
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
