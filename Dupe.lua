--[[ 
⚡ TITAN BOT V42
- Giữ logic: scan nhanh → thấy pet gửi 1 lần → hop ngay
- Thêm GUI nút HOP
- Auto hop có fallback retry (chắc chắn chuyển server)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

-- 🔥 LIST PET BẠN YÊU CẦU
local TARGET_PETS = {
    "elefanto frigo","dug dug dug","las sis","nuclearo dinossauro",
    "money money puggy","chillin chili","tang tang kelentang",
    "garama","madundung","la secret combinasion","dragon cannelloni",
    "los hotspotsitos","tralaledon","celularcini viciosini",
    "tictac sahur","la supreme combinasion","ketupat kepat",
    "ketchuru","musturu","burguro","fryuro","cooki","milki",
    "capitano moby","cerberus","skibidi toilet",
    "strawberry elephant","meowl","reideer","bros"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer

local SENT = false
local HOPPING = false

-- ===== WEBHOOK + TRIGGER HOP =====
local function SendAndTriggerHop(pet)
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

    -- 🚀 hop ngay + fallback
    task.spawn(function()
        if not HOPPING then
            HOPPING = true
            for i = 1, 5 do -- retry tối đa 5 lần
                print("🚀 TRY HOP:", i)

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
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LPlr)
                            task.wait(0.8)
                            break
                        end
                    end
                end

                task.wait(1) -- nếu chưa đi thì thử lại
            end
        end
    end)
end

-- ===== CHECK PET =====
local function Check(obj)
    local name = (obj.Name or ""):lower()

    for _, pet in pairs(TARGET_PETS) do
        if string.find(name, pet) then
            SendAndTriggerHop(pet)
            return true
        end
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local txt = (obj.Text or ""):lower()
        for _, pet in pairs(TARGET_PETS) do
            if string.find(txt, pet) then
                SendAndTriggerHop(pet)
                return true
            end
        end
    end

    return false
end

-- ===== GUI HOP =====
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TitanGUI"
    ScreenGui.Parent = game.CoreGui

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0,120,0,40)
    Button.Position = UDim2.new(0,20,0.5,0)
    Button.Text = "HOP SERVER"
    Button.BackgroundColor3 = Color3.fromRGB(255,50,50)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = ScreenGui

    Button.MouseButton1Click:Connect(function()
        print("🖱️ Click Hop")
        SENT = false
        HOPPING = false
        SendAndTriggerHop("manual")
    end)
end

-- ===== MAIN =====
task.spawn(function()
    print("⚡ TITAN V42 START")

    CreateGUI()

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

    -- nếu không thấy → auto hop sau 3s
    task.wait(3)
    if not SENT then
        print("💀 Không thấy → auto hop")
        SendAndTriggerHop("no pet")
    end
end)
