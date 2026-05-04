--[[ 
    VANGUARD TITAN - SPIN EDITION
    - Feature: High-speed Spin (Anti-Aim style)
    - Bypass: CFrame Rotation (Né Anti-cheat)
    - UI: Chữ to, thanh kéo hiện số rõ ràng.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService

local Config = {
    SpinEnabled = false,
    SpinSpeed = 20, -- Tốc độ xoay mặc định
    Accent = Color3.fromRGB(255, 255, 255)
}

-- 1. GUI THIẾT KẾ MỚI (TO RÕ)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanSpin"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 280)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN - SPIN BOT"
Title.TextSize = 22
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Title)

-- 2. HÀM TẠO NÚT XOAY
local SpinToggle = Instance.new("TextButton", Main)
SpinToggle.Size = UDim2.new(0.9, 0, 0, 60)
SpinToggle.Position = UDim2.new(0.05, 0, 0, 65)
SpinToggle.Text = "BẬT XOAY: OFF"
SpinToggle.TextSize = 20
SpinToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpinToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpinToggle)

SpinToggle.MouseButton1Click:Connect(function()
    Config.SpinEnabled = not Config.SpinEnabled
    SpinToggle.Text = Config.SpinEnabled and "BẬT XOAY: ON" or "BẬT XOAY: OFF"
    SpinToggle.TextColor3 = Config.SpinEnabled and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
end)

-- 3. THANH TRƯỢT TỐC ĐỘ XOAY (SIÊU TO)
local SpeedLabel = Instance.new("TextLabel", Main)
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.Position = UDim2.new(0, 0, 0, 130)
SpeedLabel.Text = "TỐC ĐỘ XOAY: 20"
SpeedLabel.TextSize = 20
SpeedLabel.TextColor3 = Config.Accent
SpeedLabel.BackgroundTransparency = 1

local Bar = Instance.new("Frame", Main)
Bar.Size = UDim2.new(0.8, 0, 0, 10)
Bar.Position = UDim2.new(0.1, 0, 0, 170)
Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", Bar)

local Knob = Instance.new("TextButton", Bar)
Knob.Size = UDim2.new(0, 25, 0, 25)
Knob.Position = UDim2.new(0, -12, 0.5, -12)
Knob.Text = ""
Knob.BackgroundColor3 = Config.Accent
Instance.new("UICorner", Knob)

-- Logic Slider
local dragging = false
Knob.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Knob.Position = UDim2.new(pos, -12, 0.5, -12)
        Config.SpinSpeed = pos * 100 -- Tốc độ từ 0 đến 100
        SpeedLabel.Text = "TỐC ĐỘ XOAY: " .. math.floor(Config.SpinSpeed)
    end
end)

-- 4. LOGIC XOAY NHÂN VẬT (NE ANTI-CHEAT)
RunService.PostSimulation:Connect(function()
    if Config.SpinEnabled and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LPlr.Character.HumanoidRootPart
        -- Xoay CFrame theo trục Y (trục đứng)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
    end
end)

-- 5. NÚT TẮT MENU
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0.9, 0, 0, 45)
Close.Position = UDim2.new(0.05, 0, 0, 210)
Close.Text = "TẮT MENU"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("🌪️ TITAN SPIN BOT LOADED. Xoay vòng vòng nào!")
