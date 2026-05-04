--[[ 
    VANGUARD TITAN V8.5 - LAG SWITCH / DESYNC
    - Method: Network Suspension (Đình chỉ mạng tạm thời).
    - Purpose: Tạo độ trễ dữ liệu để thực hiện Dupe/Snap.
    - Fast Interact: Giữ nguyên chạm E 0s.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local settings = settings()
local LPlr = Services.Players.LocalPlayer

local Config = {
    Accent = Color3.fromRGB(255, 150, 0),
    Lagging = false
}

-- 1. GUI
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanLagSwitch"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 220)
Main.Position = UDim2.new(0.5, 160, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V8.5 - LAG SWITCH"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- 2. HÀM TẠO LAG (LAG SWITCH)
local function SetLag(state)
    Config.Lagging = state
    -- Đẩy độ trễ mạng lên mức tối đa để game "đơ" nhưng không bị mất kết nối ngay
    settings.Network.IncomingReplicationLag = state and 99e9 or 0
end

-- 3. NÚT ĐIỀU KHIỂN
local lagBtn = Instance.new("TextButton", Main)
lagBtn.Size = UDim2.new(0.9, 0, 0, 60)
lagBtn.Position = UDim2.new(0.05, 0, 0, 70)
lagBtn.Text = "LAG SWITCH: OFF"
lagBtn.TextSize = 18
lagBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
lagBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", lagBtn)

lagBtn.MouseButton1Click:Connect(function()
    SetLag(not Config.Lagging)
    lagBtn.Text = Config.Lagging and "LAGGING... (ACTIVE)" or "LAG_SWITCH: OFF"
    lagBtn.BackgroundColor3 = Config.Lagging and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 4. FAST INTERACT & SERVER HOP
local function QuickBtn(text, pos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 50)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

QuickBtn("SERVER HOP (FAST)", UDim2.new(0.05, 0, 0, 140), function()
    local s = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, s[math.random(1, #s)].id)
end)

-- Auto Interact
task.spawn(function()
    while task.wait(0.5) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    end
end)

print("⚡ TITAN V8.5 LOADED. Lag Switch Ready.")
