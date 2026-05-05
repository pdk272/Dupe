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
local function MatchPet(text)
    text = Normalize(text)

    for _, pet in ipairs(TARGET_PETS) do
        if string.find(text, pet, 1, true) then
            return pet
        end
    end
end

-- ===== ADD =====
local function AddPet(pet, money)
    if not FOUND[pet] then
        FOUND[pet] = money or "?"
        FOUND_COUNT += 1
        print("🎯 FOUND:", pet, money or "")
    end
end

-- ===== CHECK =====
local function Check(obj)
    local pet = MatchPet(obj.Name)
    if pet then
        AddPet(pet)
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = obj.Text or ""
        local pet2 = MatchPet(txt)

        if pet2 then
            local money = txt:match("%$[%d%.]+%s*[KMBkmb]?")
            AddPet(pet2, money)
        end
    end
end

-- ===== BUILD =====
local function BuildList()
    local text = ""
    for pet, money in pairs(FOUND) do
        text = text .. pet .. " | " .. money .. "\n"
    end
    return text
end

-- ===== WEBHOOK =====
local function SendWebhook()
    if SENT then return end
    if FOUND_COUNT == 0 then return end -- ❗ chỉ gửi khi có pet

    local sendFunc =
        (syn and syn.request) or
        request or http_request or
        (http and http.request)

    if not sendFunc then
        warn("❌ No HTTP support")
        return
    end

    local list = BuildList()
    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    local success, err = pcall(function()
        sendFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "",
                embeds = {{
                    title = "🎯 FOUND PET ("..FOUND_COUNT..")",
                    description = "```"..list.."```\n[JOIN SERVER]("..link..")",
                    color = 65280
                }}
            })
        })
    end)

    if success then
        SENT = true
        print("📡 SENT:", FOUND_COUNT)
    else
        warn("❌ WEBHOOK ERROR:", err)
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ SCANNING...")

    -- scan lần đầu
    for _, obj in ipairs(game:GetDescendants()) do
        Check(obj)
    end

    -- scan object spawn mới
    game.DescendantAdded:Connect(Check)

    -- đợi thêm để bắt pet spawn
    local SCAN_TIME = 10
    for i = 1, SCAN_TIME do
        task.wait(1)
    end

    -- gửi nếu có pet
    SendWebhook()

    -- ===== HOP =====
    if FOUND_COUNT > 0 then
        print("⏳ HOLD SERVER 60s...")
        task.wait(60)
    else
        task.wait(3)
    end

    print("🚀 HOP SERVER")
    TeleportService:Teleport(game.PlaceId)
end)
