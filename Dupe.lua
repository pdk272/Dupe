if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local WEBHOOK_URL = "WEBHOOK_CUA_BAN"

-- 🔥 PET LIST (GIỮ NGUYÊN TÊN, KHÔNG TÁCH)
local TARGET_PETS = {
    "elefanto frigo","dug dug dug","las sis","nuclearo dinossauro",
    "money money puggy","chillin chili","tang tang kelentang",
    "garama and madundung","la secret combinasion","dragon cannelloni",
    "los hotspotsitos","tralaledon","celularcini viciosini",
    "tictac sahur","la supreme combinasion","ketupat kepat",
    "ketchuru and musturu","burguro and fryuro","cooki and milki",
    "capitano moby","cerberus","skibidi toilet",
    "strawberry elephant","meowl","money money bros"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer

local SENT = false
local HOPPING = false

-- ===== WEBHOOK =====
local function SendWebhook(pet)
    if SENT then return end
    SENT = true

    local sendFunc = request or http_request or (http and http.request)
    if not sendFunc then return end

    pcall(function()
        sendFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "||@everyone||",
                embeds = {{
                    title = "🎯 PET FOUND",
                    description = "**Pet:** `"..pet.."`\n```"..game.JobId.."```",
                    color = 0xFF0000
                }}
            })
        })
    end)

    print("📡 SENT:", pet)
end

-- ===== HOP CHẮC CHẮN =====
local function ForceHop()
    if HOPPING then return end
    HOPPING = true

    task.spawn(function()
        for i = 1,5 do
            print("🚀 TRY HOP:", i)

            local ok, res = pcall(function()
                return game:HttpGet(
                    "https://games.roblox.com/v1/games/"..
                    game.PlaceId..
                    "/servers/Public?sortOrder=Desc&limit=100"
                )
            end)

            if ok then
                local data = HttpService:JSONDecode(res)

                for _, s in pairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        print("⚡ HOP:", s.id)

                        -- ưu tiên instance
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LPlr)
                        end)

                        -- fallback
                        task.wait(1)
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId)
                        end)

                        return
                    end
                end
            end

            task.wait(1)
        end
    end)
end

-- ===== MATCH CHÍNH XÁC =====
local function IsMatch(name)
    name = name:lower()

    for _, pet in pairs(TARGET_PETS) do
        if name == pet then -- ✅ match EXACT
            return pet
        end
    end

    return nil
end

-- ===== CHECK =====
local function Check(obj)
    local name = (obj.Name or ""):lower()

    local pet = IsMatch(name)
    if pet then
        SendWebhook(pet)
        ForceHop()
        return true
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = (obj.Text or ""):lower()
        local pet2 = IsMatch(txt)
        if pet2 then
            SendWebhook(pet2)
            ForceHop()
            return true
        end
    end
end

-- ===== GUI =====
local function CreateGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local btn = Instance.new("TextButton", gui)

    btn.Size = UDim2.new(0,120,0,40)
    btn.Position = UDim2.new(0,20,0.5,0)
    btn.Text = "HOP SERVER"

    btn.MouseButton1Click:Connect(function()
        print("🖱️ Manual Hop")
        ForceHop() -- ❌ KHÔNG gửi webhook nữa
    end)
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ START")

    CreateGUI()

    for _, obj in pairs(workspace:GetDescendants()) do
        if SENT then break end
        Check(obj)
    end

    workspace.DescendantAdded:Connect(function(obj)
        if not SENT then
            Check(obj)
        end
    end)

    task.wait(3)

    if not SENT then
        print("💀 Không thấy → hop")
        ForceHop()
    end
end)
