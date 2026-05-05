if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ===== CẤU HÌNH =====
local WEBHOOK_URL = "URL_WEBHOOK_CỦA_ÔNG_TẠI_ĐÂY" 
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
    if not req then return print("Executor không hỗ trợ gửi Webhook!") end

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
                    title = "🎯 ĐÃ TÌM THẤY PET HIẾM! ("..FOUND_COUNT..")",
                    description = "```\n" .. petList .. "```\n**JobId:** `" .. game.JobId .. "`\n\n[NHẤN VÀO ĐÂY ĐỂ VÀO SERVER]("..link..")",
                    color = 65280, -- Màu xanh lá
                    footer = {text = "Pet Hunter Bot | " .. os.date("%X")}
                }}
            })
        })
    end)

    if success then SENT = true print("📡 Đã gửi thông báo lên Discord!") else warn("Lỗi gửi Webhook: " .. err) end
end

-- ===== CHUYỂN SERVER (SERVER HOP) =====
local function HopServer()
    print("🚀 Đang tìm server mới...")
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(sfUrl))
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                print("✅ Đã tìm thấy server mới, đang nhảy...")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    
    -- Nếu không tìm được server qua API thì dùng cách cũ làm dự phòng
    TeleportService:Teleport(game.PlaceId)
end

-- ===== QUÉT MÔ HÌNH =====
local function CheckModel(obj)
    if not obj:IsA("Model") then return end
    local pet = MatchPet(obj.Name)
    if pet and not FOUND[pet] then
        FOUND[pet] = true
        FOUND_COUNT = FOUND_COUNT + 1
        print("🎯 TÌM THẤY:", pet)
    end
end

-- ===== CHẠY CHÍNH =====
task.spawn(function()
    print("⚡ Bắt đầu quét server...")

    -- Quét nhanh lúc vừa vào
    for _, obj in ipairs(workspace:GetDescendants()) do
        CheckModel(obj)
    end

    -- Theo dõi nếu có pet mới spawn ra
    workspace.DescendantAdded:Connect(CheckModel)

    task.wait(3) -- Chờ một chút để dữ liệu load hết

    if FOUND_COUNT > 0 then
        SendWebhook()
        print("⏳ Đang đợi 45 giây cho acc chính vào...")
        task.wait(45)
    else
        print("❌ Server này không có pet mục tiêu.")
        task.wait(2)
    end

    HopServer()
end)
