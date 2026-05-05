--[[
    SOLARA X: FORCE OVERRIDE (V30.0)
    - Target: Bắt chuẩn đường dẫn từ ảnh (Workspace & ReplicatedStorage)
    - Logic: ProximityPrompt Overload & Server Fire
    - Theme: Solara Dark
]]

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Titan = { Visible = true, GodFuse = false }

-- 1. TẠO GUI SOLARA TỐI GIẢN
local ScreenGui = Instance.new("ScreenGui", LPlr:WaitForChild("PlayerGui"))
ScreenGui.Name = "TitanFuseGod"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 180)
Main.Position = UDim2.new(0.5, -160, 0.4, -90)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 5)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 5)
local Grad = Instance.new("UIGradient", TopBar)
Grad.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(0, 255, 255))

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "SOLARA • FORCE FUSE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local FuseBtn = Instance.new("TextButton", Main)
FuseBtn.Size = UDim2.new(0.9, 0, 0, 50)
FuseBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
FuseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FuseBtn.Text = "ÉP SKIP & CLAIM: OFF"
FuseBtn.TextColor3 = Color3.new(1, 1, 1)
FuseBtn.Font = Enum.Font.GothamBold
FuseBtn.TextSize = 16
Instance.new("UICorner", FuseBtn)

-- 2. LOGIC TẤN CÔNG (THEO ĐƯỜNG DẪN ẢNH)
local function ForceSkipAndClaim()
    -- BƯỚC 1: Ép kích hoạt nút Skip ngoài đời thực (Workspace)
    -- Đường dẫn: Workspace.Shops.FuseMachine.Prompt.SkipFusePrompt
    local shopFolder = workspace:FindFirstChild("Shops")
    if shopFolder then
        local fuseMachine = shopFolder:FindFirstChild("FuseMachine")
        if fuseMachine then
            local promptFolder = fuseMachine:FindFirstChild("Prompt")
            if promptFolder then
                local skipPrompt = promptFolder:FindFirstChild("SkipFusePrompt")
                -- Nếu nó là ProximityPrompt (E)
                if skipPrompt and skipPrompt:IsA("ProximityPrompt") then
                    if fireproximityprompt then
                        fireproximityprompt(skipPrompt)
                    else
                        skipPrompt.HoldDuration = 0
                        skipPrompt:InputHoldBegin()
                        task.wait()
                        skipPrompt:InputHoldEnd()
                    end
                end
            end
        end
    end

    -- BƯỚC 2: Bắn gói tin thẳng vào ReplicatedStorage
    local promptsRS = RS:FindFirstChild("Prompts")
    if promptsRS then
        local skipRemote = promptsRS:FindFirstChild("SkipFusePrompt")
        local claimRemote = promptsRS:FindFirstChild("ClaimFusePrompt")
        
        -- Kẹp lệnh gửi lên Server
        if skipRemote and skipRemote:IsA("RemoteEvent") then skipRemote:FireServer() end
        if skipRemote and skipRemote:IsA("RemoteFunction") then pcall(function() skipRemote:InvokeServer() end) end
        
        task.wait(0.1) -- Đợi server nuốt gói Skip
        
        if claimRemote and claimRemote:IsA("RemoteEvent") then claimRemote:FireServer() end
        if claimRemote and claimRemote:IsA("RemoteFunction") then pcall(function() claimRemote:InvokeServer() end) end
    end
end

-- Vòng lặp cưỡng chế
task.spawn(function()
    while task.wait(0.2) do
        if Titan.GodFuse then
            ForceSkipAndClaim()
        end
    end
end)

FuseBtn.MouseButton1Click:Connect(function()
    Titan.GodFuse = not Titan.GodFuse
    FuseBtn.Text = "ÉP SKIP & CLAIM: " .. (Titan.GodFuse and "ON" or "OFF")
    FuseBtn.TextColor3 = Titan.GodFuse and Color3.fromRGB(0, 255, 255) or Color3.new(1, 1, 1)
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.K then Main.Visible = not Main.Visible end
end)

print("🌌 SOLARA V30.0 READY! Target locked to Image Paths.")
