if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CONFIG =====
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local MIN_MONEY = 5000000 -- 20M

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

-- ===== MATCH PET =====
local function MatchPet(text)
    text = Normalize(text)

    for _, pet in ipairs(TARGET_PETS) do
        if text == pet then
            return pet
        end

        if #text <= (#pet + 10) and string.find(text, pet, 1, true) then
            return pet
        end
    end
end

-- ===== LẤY TIỀN ĐÚNG FORMAT $50M/s =====
local function GetMoneyFromText(txt)
    return txt:match("%$[%d%.]+%s*[KMBkmb]?/s")
end

-- ===== PARSE TIỀN =====
local function ParseMoney(str)
    if not str then return 0 end

    local num, suffix = str:match("%$([%d%.]+)%s*([KMBkmb]?)")
    num = tonumber(num)
    if not num then return 0 end

    if suffix == "k" or suffix == "K" then
        num *= 1e3
    elseif suffix == "m" or suffix == "M" then
        num *= 1e6
    elseif suffix == "b" or suffix == "B" then
        num *= 1e9
    end

    return num
end

-- ===== ADD =====
local function AddPet(pet, moneyStr)
    local value = ParseMoney(moneyStr)

    if value < MIN_MONEY then return end

    if not FOUND[pet] then
        FOUND[pet] = moneyStr or "?"
        FOUND_COUNT += 1
        print("💰 GOOD:", pet, moneyStr)
    end
end

-- ===== CHECK =====
local function Check(obj)
    if not obj:IsDescendantOf(workspace) then return end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = obj.Text or ""

        local pet = MatchPet(txt)
        if pet then
            local moneyStr = GetMoneyFromText(txt)
            local value = ParseMoney(moneyStr)

            -- DEBUG (có thể tắt)
            print("DEBUG:", pet, moneyStr, value)

            if value >= MIN_MONEY then
                AddPet(pet, moneyStr)
            end
        end
    end
end

-- ===== SCAN NHẸ =====
local function FastScan()
    local list = game:GetDescendants()
    local chunk = math.ceil(#list / 3)

    for i = 1, 3 do
        task.spawn(function()
            for j = (i-1)*chunk+1, math.min(i*chunk, #list) do
                Check(list[j])
            end
        end)
    end
end

-- ===== WEBHOOK =====
local function SendWebhook()
    if SENT or FOUND_COUNT == 0 then return end

    local req =
        (syn and syn.request) or
        request or http_request or
        (http and http.request)

    if not req then
        warn("❌ NO HTTP")
        return
    end

    local text = ""
    for pet, money in pairs(FOUND) do
        text = text .. pet .. " | " .. money .. "\n"
    end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "💰 GOOD PET ("..FOUND_COUNT..")",
                    description = "```"..text.."```\n[JOIN SERVER]("..link..")",
                    color = 65280
                }}
            })
        })
    end)

    SENT = true
    print("📡 SENT WEBHOOK")
end

-- ===== HOP SERVER =====
local function HopServer()
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"

    local success, res = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(res)

        for _, v in ipairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                print("🚀 HOP:", v.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                break
            end
        end
    else
        TeleportService:Teleport(game.PlaceId)
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ START")

    FastScan()
    game.DescendantAdded:Connect(Check)

    task.wait(8)

    if FOUND_COUNT > 0 then
        SendWebhook()
        print("⏳ HOLD 60s")
        task.wait(60)
    else
        print("❌ NO GOOD PET")
        task.wait(2)
    end

    HopServer()
end)
