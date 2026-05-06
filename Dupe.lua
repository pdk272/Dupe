if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local ACC_INDEX = 1 
local MAX_ACCS = 10  
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

-- TỐI ƯU GIẢM LAG TUYỆT ĐỐI
settings().Rendering.QualityLevel = 1
game:GetService("RunService"):Set3dRenderingEnabled(false) 

-- ===== DANH SÁCH PET KHỔNG LỒ CỦA ÔNG =====
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
    local petNames = {}
    for k in pairs(found) do table.insert(petNames, k) end
    return table.concat(petNames, ", "), count
end

-- ===== PHÁT TÍN HIỆU =====
local function Broadcast(petString)
    -- 1. Báo Discord
    pcall(function()
        local deepLink = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "🎯 **ACC " .. ACC_INDEX .. "** THẤY HÀNG: " .. petString,
                embeds = {{
                    title = "VÀO HÚP NGAY",
                    url = deepLink,
                    description = "JobId: `" .. game.JobId .. "`",
                    color = 0x00FF00
                }}
            })
        })
    end)
    -- 2. Báo trực tiếp vào Game
    pcall(function()
        MessagingService:PublishAsync("BrainrotFinderSignal", {
            PetName = petString,
            JobId = game.JobId,
            Players = #game:GetService("Players"):GetPlayers() .. "/8",
            AccSource = ACC_INDEX
        })
    end)
end

-- (Phần HopServer ông dán code nhảy server cũ vào đây nhé)

task.spawn(function()
    task.wait(5) -- Đợi pet load
    local res, count = ScanPets()
    if count > 0 then
        Broadcast(res)
        task.wait(60) -- Giữ server
    end
    -- HopServer()
end)
