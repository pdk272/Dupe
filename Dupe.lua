--[[
    SOLARA X - FUSE GOD MODE (V29.0)
    - Target: ReplicatedStorage.Prompts (Dựa trên ảnh của anh)
    - Features: Instant Skip & Auto Claim
    - Theme: Solara Dark Purple
    - Keybind: K (Toggle)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Titan = {
    Visible = true,
    AutoSkip = false
}

-- 1. TRUY XUẤT NGUỒN TIN (Dựa trên ảnh anh gửi)
local Prompts = RS:WaitForChild("Prompts")
local SkipRemote = Prompts:WaitForChild("SkipFusePrompt")
local ClaimRemote = Prompts:WaitForChild("ClaimFusePrompt")

-- 2. GIAO DIỆN SOLARA (CHUẨN ẢNH ÔNG GỬI)
local ScreenGui = Instance.new("ScreenGui", LPlr:WaitForChild("PlayerGui"))
ScreenGui.Name = "TitanFuseGod"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 220)
Main.Position = UDim2.new(0.5, -160, 0.4, -110)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
local Grad = Instance.new("UIGradient", TopBar)
Grad.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(0, 255, 255))

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "SOLARA • FUSE GOD"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- 3. NÚT KÍCH NỔ (INSTANT FUSE)
local FuseBtn = Instance.new("TextButton", Main)
FuseBtn.Size = UDim2.new(0.9, 0, 0, 50)
FuseBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
FuseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FuseBtn.Text = "AUTO SKIP & CLAIM: OFF"
FuseBtn.TextColor3 = Color3.new(1, 1, 1)
FuseBtn.Font = Enum.Font.GothamBold
FuseBtn.TextSize = 16
Instance.new("UICorner", FuseBtn)

-- 4. LOGIC ÉP MÁY CHỦ (PACKET ATTACK)
local function ExecuteFuseHacks()
    -- Gửi lệnh Skip (Bỏ qua thời gian)
    if SkipRemote:IsA("RemoteEvent") then
        SkipRemote:FireServer()
    elseif SkipRemote:IsA("RemoteFunction") then
        SkipRemote:InvokeServer()
    end

    -- Gửi lệnh Claim (Nhận pet ngay lập tức)
    task.wait(0.1) -- Delay cực nhỏ để tránh lỗi logic
    if ClaimRemote:IsA("RemoteEvent") then
        ClaimRemote:FireServer()
    elseif ClaimRemote:IsA("RemoteFunction") then
        ClaimRemote:InvokeServer()
    end
end

-- Vòng lặp quét trạng thái
task.spawn(function()
    while task.wait(0.5) do
        if Titan.AutoSkip then
            pcall(ExecuteFuseHacks)
        end
    end
end)

-- Toggle Button
FuseBtn.MouseButton1Click:Connect(function()
    Titan.AutoSkip = not Titan.AutoSkip
    FuseBtn.Text = "AUTO SKIP & CLAIM: " .. (Titan.AutoSkip and "ON" or "OFF")
    FuseBtn.TextColor3 = Titan.AutoSkip and Color3.fromRGB(0, 255, 255) or Color3.new(1, 1, 1)
    FuseBtn.BackgroundColor3 = Titan.AutoSkip and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(20, 20, 30)
end)

-- Phím K đóng mở
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.K then
        Main.Visible = not Main.Visible
    end
end)

print("🌌 TITAN FUSE GOD V29.0 LOADED! Đã khóa mục tiêu vào SkipFusePrompt.")
