if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local WEBHOOK_URL = "WEBHOOK_CUA_BAN"

-- 🔥 PET LIST + GIÁ TRỊ (có thể chỉnh)
local PET_DATA = {
    ["garama and madundung"] = {money="$50M/s", rank="Gold"},
    ["tang tang kelentang"] = {money="$175.88M/s", rank="Gold"},
    ["chicleteirina bicicleteirina"] = {money="$68M/s", rank="Divine"},
    ["la grande combinasion"] = {money="$85M/s", rank="Rainbow"},
    ["trralaledon"] = {money="$60M/s", rank="Normal"},
    ["strawberry elephant"] = {money="$39M/s", rank="Normal"},
    ["meowl"] = {money="$??/s", rank="???"},
}

local TARGET_PETS = {}
for name,_ in pairs(PET_DATA) do
    table.insert(TARGET_PETS, name)
end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local FOUND = {}

-- ===== ADD PET =====
local function AddPet(pet)
    if not FOUND[pet] then
        FOUND[pet] = true
        print("🎯 FOUND:", pet)
    end
end

-- ===== CHECK =====
local function Check(obj)
    local name = (obj.Name or ""):lower()

    for _, pet in pairs(TARGET_PETS) do
        if name == pet then
            AddPet(pet)
        end
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = (obj.Text or ""):lower()
        for _, pet in pairs(TARGET_PETS) do
            if txt == pet then
                AddPet(pet)
            end
        end
    end
end

-- ===== FORMAT ĐẸP =====
local function BuildList()
    local text = ""

    for pet,_ in pairs(FOUND) do
        local data = PET_DATA[pet] or {money="?", rank="?"}

        text = text ..
        string.format("[%s] %s | %s\n",
            data.rank,
            pet:gsub("^%l", string.upper),
            data.money
        )
    end

    return text
end

-- ===== WEBHOOK =====
local function SendWebhook()
    if next(FOUND) == nil then return end

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
                content = "",
                embeds = {{
                    title = "🧠 Brainrot Notify",
                    description =
                        "**🎯 Found Pets:**\n```"..list.."```\n"..
                        "[JOIN SERVER]("..link..")",
                    color = 0x00FF99
                }}
            })
        })
    end)

    print("📡 SENT LIST")
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ MULTI SCAN START")

    for _, obj in pairs(workspace:GetDescendants()) do
        Check(obj)
    end

    SendWebhook()

    if next(FOUND) ~= nil then
        print("⏳ Giữ server 45s...")
        task.wait(45)
    end

    print("🚀 Hop")
    TeleportService:Teleport(game.PlaceId)
end)
