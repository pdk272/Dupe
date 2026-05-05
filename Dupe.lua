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
    "strawberry elephant","meowl"
}

-- ===== SERVICES =====
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local FOUND = {}
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

-- ===== WEBHOOK =====
local function SendWebhook()
    if SENT then return end

    local text = ""
    local count = 0

    for pet in pairs(FOUND) do
        text = text .. pet .. "\n"
        count += 1
    end

    if count == 0 then return end

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
                title = "🎯 PET TRONG BASE",
                description = "```"..text.."```\nJobId: "..game.JobId.."\n[JOIN]("..link..")",
                color = 65280
            }}
        })
    })

    SENT = true
    print("📡 SENT")
end

-- ===== CHECK MODEL =====
local function CheckModel(obj)
    if not obj:IsA("Model") then return end

    local pet = MatchPet(obj.Name)
    if pet then
        if not FOUND[pet] then
            FOUND[pet] = true
            print("🎯 FOUND:", pet)
            SendWebhook()
        end
    end
end

-- ===== SCAN BASE =====
local function ScanBases()
    for _, obj in ipairs(workspace:GetChildren()) do
        CheckModel(obj)

        for _, sub in ipairs(obj:GetDescendants()) do
            CheckModel(sub)
        end
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ SCAN BASE MODE")

    -- scan nhẹ 1 lần
    ScanBases()

    -- bắt pet spawn trong base
    workspace.DescendantAdded:Connect(CheckModel)

    print("✅ READY - ĐỢI PET")
end)
