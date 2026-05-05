--[[
    SOLARA X - FUSE ACCELERATOR (V28.0)
    - Logic: Remote Interceptor & UI Bypass.
    - Feature: Skip Fuse Time / Instant Fuse.
    - Theme: Solara Dark (Purple-Cyan Gradient).
    - Keybind: K (Toggle).
]]

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Titan = {
    Visible = true,
    InstantFuse = true
}

-- 1. GUI SOLARA STYLE (TRUNG TÂM ĐIỀU KHIỂN)
local ScreenGui = Instance.new("ScreenGui", LPlr:WaitForChild("PlayerGui"))
ScreenGui.Name = "TitanFuseSkip"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 200)
Main.Position = UDim2.new(0.5, -150, 0.4, -100)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Tự viết kéo thả nếu bản này lỗi nhé
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 5)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 5)
local Grad = Instance.new("UIGradient", TopBar)
Grad.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(0, 255, 255))

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = " SOLARA • FUSE SKIPPER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- 2. NÚT KÍCH HOẠT SIÊU TỐC
local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "INSTANT FUSE: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 18
Instance.new("UICorner", ToggleBtn)

-- 3. CORE LOGIC - ĐÁNH BẠI THỜI GIAN
local function SkipFuseLogic()
    -- 3a. Xử lý UI (Nếu game dùng thanh trượt/đếm ngược trên màn hình)
    for _, v in pairs(LPlr.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and (v.Text:find(":") or v.Text:find("s")) then
            -- Nếu thấy nhãn thời gian, ta ép nó về 0
            if v.Parent:IsA("Frame") and v.Parent.Name:lower():find("fuse") then
                v.Text = "0s"
            end
        end
    end

    -- 3b. Xử lý Remote (Nã lệnh hoàn tất ngay khi vừa bắt đầu)
    -- Em quét các Remote tiềm năng liên quan đến Fuse
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = remote.Name:lower()
            if rName:find("fuse") or rName:find("evolve") or rName:find("merge") then
                -- Nếu nó là lệnh xác nhận kết thúc, ta nã nó liên tục
                if rName:find("confirm") or rName:find("finish") or rName:find("end") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(true)
                    else
                        remote:InvokeServer(true)
                    end
                end
            end
        end
    end
end

-- Vòng lặp kiểm tra
RunService.Heartbeat:Connect(function()
    if Titan.InstantFuse then
        SkipFuseLogic()
    end
end)

-- Toggle trạng thái
ToggleBtn.MouseButton1Click:Connect(function()
    Titan.InstantFuse = not Titan.InstantFuse
    ToggleBtn.Text = "INSTANT FUSE: " .. (Titan.InstantFuse and "ON" or "OFF")
    ToggleBtn.TextColor3 = Titan.InstantFuse and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(200, 50, 50)
end)

-- Phím K đóng mở
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.K then
        Main.Visible = not Main.Visible
    end
end)

print("⚡ SOLARA FUSE SKIPPER LOADED! Press K to Toggle.")
