--[[ 
⚡ TITAN BOT FINAL (SCAN → GỬI → GIỮ SERVER)
- Không spam webhook
- Không detect sai
- Không hop ngay
- Giữ server cho acc chính vào
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local TARGET_PETS = {
    "elefanto frigo","dug dug dug","las sis","nuclearo dinossauro",
    "money money puggy","chillin chili","tang tang kelentang",
    "garama and madundung","la secret combinasion","dragon cannelloni",
    "los hotspotsitos","tralaledon","celularcini viciosini",
    "tictac sahur","la supreme combinasion","ketupat kepat",
    "ketchuru and musturu","burguro and fryuro","cooki and milki",
    "capitano moby","cerberus","skibidi toilet",
    "strawberry elephant","meowl","Chic"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer

local SENT = false

-- ===== WEBHOOK =====
local function SendWebhook(pet)
    if SENT then return end
    SENT = true

    local sendFunc = request or http_request or (http and http.request)
    if not sendFunc then return end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId

    pcall(function()
        sendFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "||@everyone||",
                embeds = {{
                    title = "🎯 PET FOUND",
                    description = "**Pet:** `"..pet.."`\n[JOIN NGAY]("..link..")\n```"..game.JobId.."```",
                    color = 0xFF0000
                }}
            })
        })
    end)

    print("📡 SENT:", pet)
end

-- ===== MATCH CHUẨN =====
local function IsMatch(name)
    name = name:lower()
    for _, pet in pairs(TARGET_PETS) do
        if name == pet then
            return pet
        end
    end
end

-- ===== CHECK =====
local function Check(obj)
    local name = (obj.Name or ""):lower()

    local pet = IsMatch(name)
    if pet then
        SendWebhook(pet)

        print("⏳ Giữ server 45s cho acc chính...")
        task.delay(45, function()
            print("🚀 Hết thời gian → hop")
            TeleportService:Teleport(game.PlaceId)
        end)

        return true
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = (obj.Text or ""):lower()
        local pet2 = IsMatch(txt)

        if pet2 then
            SendWebhook(pet2)

            print("⏳ Giữ server 45s cho acc chính...")
            task.delay(45, function()
                print("🚀 Hết thời gian → hop")
                TeleportService:Teleport(game.PlaceId)
            end)

            return true
        end
    end
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ BOT START")

    -- scan ngay
    for _, obj in pairs(workspace:GetDescendants()) do
        if SENT then break end
        Check(obj)
    end

    -- nghe spawn
    workspace.DescendantAdded:Connect(function(obj)
        if not SENT then
            Check(obj)
        end
    end)

    -- nếu không thấy → hop nhanh
    task.wait(3)
    if not SENT then
        print("💀 Không thấy → hop")
        TeleportService:Teleport(game.PlaceId)
    end
end)
