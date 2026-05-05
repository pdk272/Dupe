if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH (ĐÃ GẮN WEBHOOK) =====
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local TARGET_PETS = {
    "elefanto frigo", "dug dug dug", "las sis", "nuclearo dinossauro",
    "money money puggy", "chillin chili", "tang tang kelentang",
    "garama and madundung", "la secret combinasion", "dragon cannelloni",
    "los hotspotsitos", "tralaledon", "celularcini viciosini",
    "tictac sahur", "la supreme combinasion", "ketupat kepat",
    "ketchuru and musturu", "burguro and fryuro", "cooki and milki",
    "capitano moby", "cerberus", "skibidi toilet",
    "strawberry elephant", "lavadorito spinito"
}

-- ===== DỊCH VỤ =====
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ===== TRẠNG THÁI =====
local FOUND = {}
local FOUND_COUNT = 0
local SENT = false

-- ===== CHUẨN HÓA TÊN =====
local function Normalize(str)
    return (str or ""):lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end

-- ===== KIỂM TRA PET =====
local function MatchPet(name)
    name = Normalize(name)
    for _, pet in ipairs(TARGET_PETS) do
        if string.find(name, pet, 1, true) then
            return pet
        end
    end
end

-- ===== GỬI WEBHOOK =====
local function SendWebhook()
    if SENT or FOUND_COUNT == 0 then return end

    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if not req then return print("❌ Executor không hỗ trợ gửi Webhook!") end

    local petList = ""
    for pet in pairs(FOUND) do
        petList = petList .. "• " .. pet .. "\n"
    end

    local link = "https://www.roblox.com/games/"..game.PlaceId.."?gameInstanceId="..game.JobId
    
    local success, err = pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🎯 PHÁT HIỆN PET MỤC TIÊU! ("..FOUND_COUNT..")",
                    description = "```\n" .. petList .. "```\n**JobId:** `" .. game.JobId .. "`\n\n[NHẤN ĐỂ VÀO SERVER]("..link..")",
                    color = 65280,
                    footer = {text = "Pet Hunter Pro | " .. os.date("%X")}
                }}
            })
        })
    end)

    if success then SENT = true print("📡 Đã gửi Discord thành công!") else warn("Lỗi Webhook: " .. err) end
end

-- ===== SERVER HOP (CHỐNG KẸT / ANTI-FULL) =====
local function HopServer()
    print("🚀 Đang tìm server mới (ưu tiên server vắng)...")
    
    local function GetNextServer()
        local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(sfUrl))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                -- Lọc server còn trống ít nhất 2 chỗ để không bị hụt
                if server.id ~= game.JobId and server.playing <= (server.maxPlayers - 2) then
                    return server.id
                end
            end
        end
        return nil
    end

    while true do
        local targetId = GetNextServer()
        if targetId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId)
        else
            TeleportService:Teleport(game.PlaceId)
        end
        
        -- Nếu bị kẹt ở màn hình Full quá 15 giây, nó sẽ tự lặp lại để tìm server khác
        task.wait(15)
        print("🔄 Vẫn kẹt ở server cũ, đang thử nhảy lại...")
    end
end

-- ===== QUÉT MÔ HÌNH =====
local function CheckModel(obj)
    if not obj:IsA("Model") then return end
    local pet = MatchPet(obj.Name)
    if pet and not FOUND[pet] then
        FOUND[pet] = true
        FOUND_COUNT += 1
        print("🎯 TÌM THẤY:", pet)
    end
end

-- ===== CHẠY CHÍNH =====
task.spawn(function()
    print("⚡ Đang quét server...")

    for _, obj in ipairs(workspace:GetDescendants()) do
        CheckModel(obj)
    end

    workspace.DescendantAdded:Connect(CheckModel)

    task.wait(3)

    if FOUND_COUNT > 0 then
        SendWebhook()
        print("⏳ Đợi 45 giây cho acc chính...")
        task.wait(45)
    else
        print("❌ Không có pet mục tiêu.")
        task.wait(1)
    end

    HopServer()
end)
