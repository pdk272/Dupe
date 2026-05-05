--[[ 
⚡ TITAN V46 FINAL
- Scan toàn game (tránh miss)
- Gom nhiều pet
- Không detect sai (ưu tiên match chuẩn)
- Webhook có debug rõ
- Giữ server 45s cho acc chính
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

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

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local FOUND = {}
local SENT = false

-- ===== ADD PET =====
local function AddPet(pet, money)
    if not FOUND[pet] then
        FOUND[pet] = money or "?"
        print("🎯 FOUND:", pet, money or "")
    end
end

-- ===== MATCH CHUẨN (TRÁNH FAKE) =====
local function FindMatch(text)
    text = text:lower()

    for _, pet in pairs(TARGET_PETS) do
        if text == pet then
            return pet
        end
    end

    return nil
end

-- ===== CHECK OBJECT =====
local function Check(obj)
    -- check name
    local name = (obj.Name or ""):lower()
    local pet = FindMatch(name)
    if pet then
        AddPet(pet)
    end

    -- check GUI text (có money)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = (obj.Text or ""):lower()

        for _, petName in pairs(TARGET_PETS) do
            if string.find(txt, petName) then
                local money = txt:match("%$[%d%.]+%s*[mbk]?/s")
                AddPet(petName, money)
            end
        end
    end
end

-- ===== BUILD LIST =====
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

    if next(FOUND) == nil then
        print("❌ Không có pet → không gửi")
        return
    end

    local sendFunc = request or http_request or (http and http.request)

    if not sendFunc then
        warn("❌ Executor không hỗ trợ HTTP")
        return
    end

    local list = BuildList()
    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    local payload = {
        content = "||@everyone||",
        embeds = {{
            title = "🧠 SCAN RESULT",
            description = "```"..list.."```\n[JOIN NGAY]("..link..")",
            color = math.random(100000,999999)
        }}
    }

    local success, err = pcall(function()
        sendFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if success then
        print("✅ WEBHOOK SENT")
        SENT = true
    else
        warn("❌ WEBHOOK ERROR:", err)
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ TITAN V46 START")

    -- scan toàn game (fix miss pet)
    for _, obj in pairs(game:GetDescendants()) do
        Check(obj)
    end

    print("📊 FOUND:", HttpService:JSONEncode(FOUND))

    -- gửi webhook
    SendWebhook()

    -- giữ server
    if next(FOUND) ~= nil then
        print("⏳ Giữ server 45s...")
        task.wait(45)
    else
        task.wait(3)
    end

    print("🚀 HOP SERVER")
    TeleportService:Teleport(game.PlaceId)
end)
