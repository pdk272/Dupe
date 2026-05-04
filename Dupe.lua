--[[ 
    VANGUARD TITAN V9.1 - SNIPER OVERLOAD
    - Target: ShootSniper Remote (Dựa trên ảnh của ông)
    - Method: Knit Framework Bypass
    - UI: Chỉnh Delay cực nhạy.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService

local Config = {
    Enabled = false,
    FireDelay = 0.1, -- 0.1s là sấy như súng máy
    Accent = Color3.fromRGB(0, 255, 255)
}

-- 1. GUI (THIẾT KẾ SNIPER)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanSniperRapid"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 280)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V9.1 - SNIPER"
Title.TextSize = 22
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. HÀM TÌM REMOTE (DÒ THEO ẢNH)
local function GetSniperRemote()
    -- Cách 1: Dò trực tiếp theo cấu trúc Knit trong ảnh
    local RS = game:GetService("ReplicatedStorage")
    local success, result = pcall(function()
        return RS.Packages._Index["sleitnick_net@0.2.0"].net.RE.ShootSniper
    end)
    
    if success and result then return result end
    
    -- Cách 2: Dò quét (Nếu phiên bản @0.2.0 thay đổi)
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "ShootSniper" then
            return v
        end
    end
    return nil
end

-- 3. NÚT BẬT/TẮT
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9, 0, 0, 60)
Toggle.Position = UDim2.new(0.05, 0, 0, 65)
Toggle.Text = "SNIPER RAPID: OFF"
Toggle.TextSize = 18
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    Toggle.Text = Config.Enabled and "SNIPER RAPID: ON" or "SNIPER RAPID: OFF"
    Toggle.TextColor3 = Config.Enabled and Config.Accent or Color3.new(1, 1, 1)
end)

-- 4. THANH CHỈNH TỐC ĐỘ
local DelayLabel = Instance.new("TextLabel", Main)
DelayLabel.Size = UDim2.new(1, 0, 0, 30)
DelayLabel.Position = UDim2.new(0, 0, 0, 130)
DelayLabel.Text = "DELAY: 0.10s"
DelayLabel.TextSize = 18
DelayLabel.TextColor3 = Color3.new(1, 1, 1)
DelayLabel.BackgroundTransparency = 1

local Bar = Instance.new("Frame", Main)
Bar.Size = UDim2.new(0.8, 0, 0, 10)
Bar.Position = UDim2.new(0.1, 0, 0, 170)
Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", Bar)

local Knob = Instance.new("TextButton", Bar)
Knob.Size = UDim2.new(0, 25, 0, 25)
Knob.Position = UDim2.new(0.1, -12, 0.5, -12)
Knob.Text = ""
Knob.BackgroundColor3 = Config.Accent
Instance.new("UICorner", Knob)

local dragging = false
Knob.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Knob.Position = UDim2.new(pos, -12, 0.5, -12)
        Config.FireDelay = math.clamp(pos, 0.01, 1)
        DelayLabel.Text = "DELAY: " .. string.format("%.2f", Config.FireDelay) .. "s"
    end
end)

-- 5. LOGIC NÃ ĐẠN (MÓC VÀO REMOTE TRONG ẢNH)
task.spawn(function()
    while task.wait() do
        if Config.Enabled then
            local remote = GetSniperRemote()
            if remote then
                -- Sniper thường cần tọa độ chuột (mouse.Hit.p) để bắn trúng
                local mouse = LPlr:GetMouse()
                local target = mouse.Hit.Position
                
                -- Nã lệnh!
                remote:FireServer(target)
            end
            task.wait(Config.FireDelay)
        end
    end
end)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0.9, 0, 0, 45)
Close.Position = UDim2.new(0.05, 0, 0, 220)
Close.Text = "TẮT MENU"
Close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("🎯 TITAN V9.1 LOADED. Target: ShootSniper.")
