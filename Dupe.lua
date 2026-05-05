if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local WEBHOOK_URL = "WEBHOOK_CUA_BAN"

-- 🔥 LIST PET (GIỮ NGUYÊN TÊN THẬT)
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
local LPlr = Players.LocalPlayer

-- 🧠 lưu pet tìm được
local FOUND = {}
local SENT = false

-- ===== ADD PET =====
local function AddPet(pet, money)
    if not FOUND[pet] then
        FOUND[pet] = money or "?"
        print("🎯 FOUND:", pet, money or "")
    end
end

-- ===== MATCH CHUẨN =====
local function IsMatch(text)
    text = text:lower()
    for _, pet in pairs(TARGET_PETS) do
        if text == pet then
            return pet
        end
    end
end

-- ===== CHECK =====
local function Check(obj)
    local name = (obj.Name or ""):lower()

    local pet = IsMatch(name)
    if pet then
        AddPet(pet)
    end

    -- đọc GUI (có tiền + mutation)
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
        text = text .. string.format("%s | %s\n",
            pet:gsub("^%l", string.upper),
            money or "?"
        )
    end

    return text
end

-- ===== WEBHOOK =====
local function SendWebhook()
    if SENT then return end
    if next(FOUND) == nil then return end
    SENT = true

    local sendFunc = request or http_request or (http and http.request)
    if not sendFunc then return end

    local list = BuildList()
    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    pcall(function()
        sendFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "||@everyone||",
                embeds = {{
                    title = "🧠 Brainrot Scanner",
                    description =
                        "```"..list.."```\n"..
                        "[JOIN NGAY]("..link..")",
                    color = 0x00FF99
                }}
            })
        })
    end)

    print("📡 SENT LIST")
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ TITAN V45 START")

    -- quét toàn map
    for _, obj in pairs(workspace:GetDescendants()) do
        Check(obj)
    end

    -- nghe realtime
    workspace.DescendantAdded:Connect(function(obj)
        if not SENT then
            Check(obj)
        end
    end)

    -- gửi 1 lần
    task.wait(1)
    SendWebhook()

    -- nếu có pet → giữ server
    if next(FOUND) ~= nil then
        print("⏳ Giữ server 45s cho acc chính...")
        task.wait(45)
    end

    -- hop tiếp tục farm
    print("🚀 Hop server")
    TeleportService:Teleport(game.PlaceId)
end)
