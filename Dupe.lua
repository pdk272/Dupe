if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CONFIG =====
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local TARGET_PETS = {
    "elefanto frigo","dug dug dug","las sis","nuclearo dinossauro",
    "money money puggy","chillin chili","tang tang kelentang",
    "garama and madundung","la secret combinasion","dragon cannelloni",
    "los hotspotsitos","tralaledon","celularcini viciosini",
    "tictac sahur","la supreme combinasion","ketupat kepat",
    "ketchuru and musturu","burguro and fryuro","cooki and milki",
    "capitano moby","cerberus","skibidi toilet",
    "strawberry elephant","Lavadorito spinito"
}

-- ===== SERVICES =====
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ===== STATE =====
local FOUND = {}
local FOUND_COUNT = 0
local SENT = false

-- ===== NORMALIZE =====
local function Normalize(str)
    return (str or ""):lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end

-- ===== MATCH =====
local function MatchPet(name)
    name = Normalize(name)

    for _, pet in ipairs(TARGET_PETS) do
        if string.find(name, pet, 1, true) then
            return pet
        end
    end
end

-- ===== ADD =====
local function AddPet(pet)
    if not FOUND[pet] then
        FOUND[pet] = true
        FOUND_COUNT += 1
        print("🎯 FOUND:", pet)
    end
end

-- ===== CHECK =====
local function CheckModel(obj)
    if not obj:IsA("Model") then return end

    local pet = MatchPet(obj.Name)
    if pet then
        AddPet(pet)
    end
end

-- ===== BUILD =====
local function BuildList()
    local text = ""
    for pet in pairs(FOUND) do
        text = text .. pet .. "\n"
    end
    return text
end

-- ===== WEBHOOK =====
local function SendWebhook()
    if SENT then return end
    if FOUND_COUNT == 0 then return end

    local req =
        (syn and syn.request) or
        request or http_request or
        (http and http.request)

    if not req then return end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    req({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            embeds = {{
                title = "🎯 PET TRONG SERVER ("..FOUND_COUNT..")",
                description = "```"..BuildList().."```\nJobId: "..game.JobId.."\n[JOIN]("..link..")",
                color = 65280
            }}
        })
    })

    SENT = true
    print("📡 SENT WEBHOOK")
end

-- ===== HOP =====
local function HopServer()
    print("🚀 HOP SERVER")
    TeleportService:Teleport(game.PlaceId)
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ START SCAN")

    -- scan nhanh 1 lần
    for _, obj in ipairs(workspace:GetDescendants()) do
        CheckModel(obj)
    end

    -- bắt pet spawn thêm
    workspace.DescendantAdded:Connect(CheckModel)

    task.wait(5) -- cho load base

    if FOUND_COUNT > 0 then
        -- ✅ GỬI NGAY
        SendWebhook()

        -- ⏳ ĐỢI ACC CHÍNH VÀO
        print("⏳ WAIT 45s FOR MAIN ACC")
        task.wait(45)
    else
        print("❌ NO PET")
        task.wait(3)
    end

    HopServer()
end)
