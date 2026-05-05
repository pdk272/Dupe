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

local FOUND = {}
local SENT = false

-- ===== CHUẨN HÓA TEXT =====
local function Normalize(str)
    return (str or ""):lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end

-- ===== MATCH CHUẨN =====
local function MatchPet(text)
    text = Normalize(text)

    for _, pet in pairs(TARGET_PETS) do
        if text == pet then
            return pet
        end

        -- match nhẹ nhưng tránh ăn ké
        if string.find(text, pet, 1, true) and #pet > 6 then
            return pet
        end
    end
end

-- ===== ADD PET =====
local function AddPet(pet, money)
    if not FOUND[pet] then
        FOUND[pet] = money or "?"
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
            local money = txt:match("%$[%d%.]+%s*[mbk]?/s")
            AddPet(pet2, money)
        end
    end
end

-- ===== BUILD LIST =====
local function BuildList()
    local text = ""
    local count = 0

    for pet, money in pairs(FOUND) do
        text = text .. pet .. " | " .. money .. "\n"
        count += 1
    end

    return text, count
end

-- ===== WEBHOOK =====
local function SendWebhook()
    if SENT then return end

    local list, count = BuildList()
    if count == 0 then
        print("❌ Không có pet → không gửi")
        return
    end

    local sendFunc = request or http_request or (http and http.request)
    if not sendFunc then
        warn("❌ Executor không hỗ trợ HTTP")
        return
    end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    local success, err = pcall(function()
        sendFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "||@everyone||",
                embeds = {{
                    title = "🎯 PET TRONG SERVER ("..count..")",
                    description = "```"..list.."```\n[JOIN NGAY]("..link..")",
                    color = 0x00FF00
                }}
            })
        })
    end)

    if success then
        print("📡 ĐÃ GỬI:", count, "pet")
        SENT = true
    else
        warn("❌ LỖI WEBHOOK:", err)
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ SCAN START")

    for _, obj in pairs(game:GetDescendants()) do
        Check(obj)
    end

    task.wait(1)
    SendWebhook()

    if next(FOUND) ~= nil then
        print("⏳ Giữ server 45s...")
        task.wait(45)
    else
        task.wait(3)
    end

    print("🚀 HOP SERVER")
    TeleportService:Teleport(game.PlaceId)
end)
