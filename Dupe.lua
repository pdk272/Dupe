--[[ 
⚡ TITAN BOT V41 - FINAL FAST
- Scan ngay khi vào
- Gửi webhook 1 lần duy nhất
- Hop ngay lập tức khi thấy pet
- Không spam, không delay ngu
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local TARGET_PETS = {
    "garama","chicleteirina","bicicleterina","hugedog",
    "huge","secret","dog"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer

local SENT = false

-- ===== WEBHOOK + HOP NGAY =====
local function SendAndHop(pet)
    if SENT then return end
    SENT = true

    local sendFunc = request or http_request or (http and http.request)
    if sendFunc then
        pcall(function()
            sendFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "||@everyone||",
                    embeds = {{
                        title = "🎯 PHÁT HIỆN PET!",
                        description = "**Pet:** `" .. pet .. "`\n```" .. game.JobId .. "```",
                        color = 0xFF0000
                    }}
                })
            })
        end)
    end

    print("📡 SENT:", pet)

    -- 🚀 HOP NGAY (KHÔNG ĐỢI)
    task.spawn(function()
        local ok, res = pcall(function()
            return game:HttpGet(
                "https://games.roblox.com/v1/games/" ..
                game.PlaceId ..
                "/servers/Public?sortOrder=Desc&limit=100"
            )
        end)

        if ok then
            local data = HttpService:JSONDecode(res)

            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    print("🚀 HOP:", s.id)

                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        s.id,
                        LPlr
                    )
                    break
                end
            end
        else
            warn("❌ Hop fail")
        end
    end)
end

-- ===== CHECK PET =====
local function Check(obj)
    local name = (obj.Name or ""):lower()

    for _, pet in pairs(TARGET_PETS) do
        if string.find(name, pet) then
            SendAndHop(pet)
            return true
        end
    end

    -- GUI
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = (obj.Text or ""):lower()
        for _, pet in pairs(TARGET_PETS) do
            if string.find(txt, pet) then
                SendAndHop(pet)
                return true
            end
        end
    end

    return false
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ TITAN V41 START")

    -- scan ngay khi vào
    for _, obj in pairs(workspace:GetDescendants()) do
        if SENT then break end
        Check(obj)
    end

    -- nghe spawn realtime
    workspace.DescendantAdded:Connect(function(obj)
        if not SENT then
            Check(obj)
        end
    end)

    -- nếu không thấy → hop nhanh
    task.wait(3)
    if not SENT then
        print("💀 Không thấy → hop")

        local ok, res = pcall(function()
            return game:HttpGet(
                "https://games.roblox.com/v1/games/" ..
                game.PlaceId ..
                "/servers/Public?sortOrder=Desc&limit=100"
            )
        end)

        if ok then
            local data = HttpService:JSONDecode(res)

            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    print("🚀 HOP:", s.id)

                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        s.id,
                        LPlr
                    )
                    break
                end
            end
        end
    end
end)
