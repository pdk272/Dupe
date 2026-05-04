--[[ 
    VANGUARD TITAN V6.0 - TRADE / DUPE LOGIC
    - Auto Trade: Giữ E 0.1s thay vì 2s để vào GUI cực nhanh.
    - Fast Ready: Tự động nhấn Ready và bỏ qua Countdown 3s.
    - Stealth Speed: Giữ nguyên để di chuyển farm pet.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService

local Config = {
    SpeedValue = 16,
    Enabled = false,
    Accent = Color3.fromRGB(0, 255, 120), -- Màu xanh Dupe
    AutoReady = false,
    FastInteract = true
}

-- 1. GUI (THIẾT KẾ DUPE CHUYÊN NGHIỆP)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanV6Dupe"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V6.0 - DUPE MODE"
Title.TextSize = 22
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. TÍNH NĂNG TRADE & DUPE
local function CreateToggle(text, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = pos
    btn.Text = text
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local readyToggle = CreateToggle("AUTO READY: OFF", UDim2.new(0.05, 0, 0, 60), function()
    Config.AutoReady = not Config.AutoReady
end)

-- LOGIC AUTO INTERACT (Bỏ qua 2 giây giữ E)
task.spawn(function()
    while task.wait() do
        if Config.FastInteract then
            -- Quét các vật thể có ProximityPrompt (nút E)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0.1 -- Giảm từ 2s xuống 0.1s
                end
            end
        end
    end
end)

-- LOGIC FAST TRADE (Nã Remote khi vào GUI)
RunService.RenderStepped:Connect(function()
    if Config.AutoReady then
        -- Tìm cái GUI Trade của game (ông cần check đúng tên GUI này)
        local TradeGui = LPlr.PlayerGui:FindFirstChild("TradeGui") or LPlr.PlayerGui:FindFirstChild("Trading")
        if TradeGui and TradeGui.Enabled then
            -- Tìm nút Ready hoặc Accept
            local Remote = TradeGui:FindFirstChild("AcceptRemote", true) or TradeGui:FindFirstChild("ReadyRemote", true)
            if Remote and Remote:IsA("RemoteEvent") then
                Remote:FireServer(true) -- Nã lệnh Ready liên tục để bypass countdown
            end
        end
    end
end)

-- 3. SPEED STEALTH (GIỮ LẠI ĐỂ FARM)
local speedBtn = CreateToggle("STEALTH SPEED: OFF", UDim2.new(0.05, 0, 0, 120), function()
    Config.Enabled = not Config.Enabled
end)

RunService.Heartbeat:Connect(function(dt)
    if Config.Enabled and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LPlr.Character.HumanoidRootPart
        local hum = LPlr.Character:FindFirstChildOfClass("Humanoid")
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Config.SpeedValue * dt * 0.88))
        end
    end
end)

-- Cập nhật trạng thái nút
RunService.RenderStepped:Connect(function()
    readyToggle.Text = "AUTO READY: " .. (Config.AutoReady and "ON" or "OFF")
    readyToggle.TextColor3 = Config.AutoReady and Config.Accent or Color3.new(1,1,1)
    speedBtn.Text = "SPEED: " .. (Config.Enabled and "ON" or "OFF")
    speedBtn.TextColor3 = Config.Enabled and Config.Accent or Color3.new(1,1,1)
end)

CreateToggle("SERVER HOP", UDim2.new(0.05, 0, 0, 180), function()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local data = Services.HttpService:JSONDecode(game:HttpGet(url)).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, data[math.random(1, #data)].id)
end)

CreateToggle("TẮT MENU", UDim2.new(0.05, 0, 0, 340), function() ScreenGui:Destroy() end).BackgroundColor3 = Color3.fromRGB(120, 0, 0)

print("⚡ TITAN V6.0 DUPE LOADED. Trade fast, stay safe.")
