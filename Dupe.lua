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

-- ===== MATCH CHUẨN (ANTI NHẶT RÁC) =====
local function MatchPet(text)
    text = Normalize(text)

    for _, pet in ipairs(TARGET_PETS) do
        if text == pet then
            return pet
        end

        -- chỉ match nếu text ngắn gần tên pet
        if #text <= (#pet + 10) and string.find(text, pet, 1, true) then
            return pet
        end
    end
end

-- ===== CHỈ SCAN TRONG MAP =====
local function IsValid(obj)
    return obj:IsDescendantOf(workspace)
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
    if not IsValid(obj) then return end

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

-- ===== FAST SCAN (ĐA LUỒNG NHẸ) =====
local function FastScan()
    local list = game:GetDescendants()
    local chunk = math.ceil(#list / 5)

    for i = 1, 5 do
        task.spawn(function()
            for j = (i-1)*chunk+1, math.min(i*chunk, #list) do
                Check(list[j])
            end
        end)
    end
end

-- ===== BUILD TEXT =====
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
    if FOUND_COUNT == 0 then return end

    local req =
        (syn and syn.request) or
        request or http_request or
        (http and http.request)

    if not req then
        warn("❌ No HTTP")
        return
    end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    local success = pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "",
                embeds = {{
                    title = "🎯 FOUND PET ("..FOUND_COUNT..")",
                    description = "```"..BuildList().."```\n[JOIN SERVER]("..link..")",
                    color = 65280
                }}
            })
        })
    end)

    if success then
        SENT = true
        print("📡 SENT WEBHOOK")
    end
end

-- ===== HOP SERVER API =====
local function HopServer()
    print("🔎 FIND NEW SERVER...")

    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"

    local success, res = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(res)

        for _, v in ipairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                print("🚀 HOP TO:", v.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                break
            end
        end
    else
        warn("❌ API FAIL")
        TeleportService:Teleport(game.PlaceId)
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ START SCAN")

    FastScan()
    game.DescendantAdded:Connect(Check)

    task.wait(8) -- thời gian quét

    if FOUND_COUNT > 0 then
        SendWebhook()
        print("⏳ HOLD 60s")
        task.wait(60)
    else
        print("❌ NO PET → HOP")
        task.wait(2)
    end

    HopServer()
end)
