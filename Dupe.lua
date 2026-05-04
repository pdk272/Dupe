--[[ 
    VANGUARD TITAN V7.0 - MASS INTRUDER
    - Method: Server Stress (Gửi trade hàng loạt để tạo lag).
    - Target: Toàn bộ người chơi trong Server.
    - Purpose: Phục vụ Dupe bằng cách làm nghẽn DataStore.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService

local Config = {
    Accent = Color3.fromRGB(255, 0, 0), -- Màu đỏ rực (Tấn công)
    MassSpam = false,
    SpamDelay = 0.5 -- Tốc độ nã (0.5 giây/lượt)
}

-- 1. GUI
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanMassIntruder"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Position = UDim2.new(0.5, 150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V7.0 - MASS TRADE"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. LOGIC TÌM REMOTE TRADE (DÒ TÌM TẤT CẢ BIẾN THỂ)
local function GetTradeRemote()
    -- Dò tìm trong ReplicatedStorage (Nơi game thường để Remote)
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("trade") or n:find("invite") or n:find("request") or n:find("send") then
                return v
            end
        end
    end
    return nil
end

-- 3. HÀM NÃ TRADE TOÀN SERVER
local function MassTradeSpam()
    local remote = GetTradeRemote()
    if not remote then 
        print("❌ Không tìm thấy Remote Trade của game này!")
        return 
    end

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LPlr then
            task.spawn(function()
                -- Gửi yêu cầu trade đến từng người
                remote:FireServer(player)
                -- Một số game yêu cầu tham số phụ, chúng ta nã thêm vài kiểu
                remote:FireServer(player, "Request")
                remote:FireServer(player.Name)
            end)
        end
    end
end

-- 4. NÚT ĐIỀU KHIỂN
local spamBtn = Instance.new("TextButton", Main)
spamBtn.Size = UDim2.new(0.9, 0, 0, 60)
spamBtn.Position = UDim2.new(0.05, 0, 0, 70)
spamBtn.Text = "MASS TRADE: OFF"
spamBtn.TextSize = 18
spamBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
spamBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", spamBtn)

spamBtn.MouseButton1Click:Connect(function()
    Config.MassSpam = not Config.MassSpam
    spamBtn.Text = Config.MassSpam and "SPAMMING... (LAG)" or "MASS TRADE: OFF"
    spamBtn.TextColor3 = Config.MassSpam and Config.Accent or Color3.new(1, 1, 1)
end)

-- Vòng lặp Spam
task.spawn(function()
    while task.wait(Config.SpamDelay) do
        if Config.MassSpam then
            MassTradeSpam()
        end
    end
end)

local hop = Instance.new("TextButton", Main)
hop.Size = UDim2.new(0.9, 0, 0, 50)
hop.Position = UDim2.new(0.05, 0, 0, 140)
hop.Text = "SERVER HOP (DUPE)"
hop.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hop.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hop)
hop.MouseButton1Click:Connect(function()
    local servers = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)].id)
end)

local close = Instance.new("TextButton", Main)
close.Size = UDim2.new(0.9, 0, 0, 40)
close.Position = UDim2.new(0.05, 0, 0, 200)
close.Text = "TẮT MENU"
close.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
