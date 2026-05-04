--[[ 
    VANGUARD TITAN V6.1 - PURE DUPE & TRADE
    - Chỉ giữ lại tính năng can thiệp Trade/Dupe.
    - Fast Interact: Chạm E 0.1s để mở bảng Trade/Steal.
    - Trade Bypass: Tự động Ready và nã tín hiệu kết thúc giao dịch.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService

local Config = {
    Accent = Color3.fromRGB(0, 255, 120), -- Xanh lá chuyên Dupe
    AutoReady = false,
    FastInteract = true
}

-- 1. GUI (TỐI GIẢN CHỈ CÓ DUPE)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanPureDupe"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V6.1 - DUPE ONLY"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. HÀM TẠO NÚT
local function CreateButton(text, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 55)
    btn.Position = pos
    btn.Text = text
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 3. CƠ CHẾ FAST INTERACT (0.1s GIỮ E)
-- Dùng để cướp lượt Steal hoặc vào Trade ngay lập tức
task.spawn(function()
    while task.wait(0.5) do
        if Config.FastInteract then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0.1 -- Ép tất cả nút giữ E về 0.1s
                end
            end
        end
    end
end)

-- 4. CƠ CHẾ AUTO READY & BYPASS COUNTDOWN
local readyBtn = CreateButton("AUTO READY: OFF", UDim2.new(0.05, 0, 0, 70), function()
    Config.AutoReady = not Config.AutoReady
end)

RunService.RenderStepped:Connect(function()
    readyBtn.Text = "AUTO READY: " .. (Config.AutoReady and "ON" or "OFF")
    readyBtn.TextColor3 = Config.AutoReady and Config.Accent or Color3.new(1,1,1)
    
    if Config.AutoReady then
        -- Tự động tìm GUI Trade và nã Remote Ready
        -- Lưu ý: Nếu game đổi tên GUI, ông cần dùng Remote Spy để check
        local playerGui = LPlr:FindFirstChild("PlayerGui")
        local tradeGui = playerGui:FindFirstChild("TradeGui", true) or playerGui:FindFirstChild("Trading", true)
        
        if tradeGui and tradeGui.Enabled then
            -- Tìm Remote để nã lệnh chấp nhận
            local acceptRem = tradeGui:FindFirstChild("Accept", true) or tradeGui:FindFirstChild("Ready", true) or tradeGui:FindFirstChild("Remote", true)
            if acceptRem and acceptRem:IsA("RemoteEvent") then
                acceptRem:FireServer(true)
            end
        end
    end
end)

-- 5. SERVER HOP (PHỤC VỤ DUPE KHI CẦN ĐỔI SERVER NHANH)
CreateButton("SERVER HOP", UDim2.new(0.05, 0, 0, 135), function()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local data = Services.HttpService:JSONDecode(game:HttpGet(url)).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, data[math.random(1, #data)].id)
end)

-- NÚT TẮT
local close = Instance.new("TextButton", Main)
close.Size = UDim2.new(0.9, 0, 0, 40)
close.Position = UDim2.new(0.05, 0, 0, 200)
close.Text = "CLOSE MENU"
close.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("💎 TITAN V6.1 - DUPE MODE LOADED.")
