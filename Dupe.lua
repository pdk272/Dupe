--[[
    VANGUARD TITAN - CELESTIAL EDITION
    - Theme: Deep Universe / Nebula
    - Security: Stealth CFrame Bypass (Universal)
    - Features: Speed, Fly, Noclip, ESP (Glow), Kill Aura
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService
local Camera = workspace.CurrentCamera

-- 1. CONFIG & STATE
local Titan = {
    Speed = 16,
    SpeedEnabled = false,
    Fly = 50,
    FlyEnabled = false,
    Noclip = false,
    KillAura = false,
    ESP = false,
    Accent = Color3.fromRGB(0, 255, 170), -- Cyber Green
    Secondary = Color3.fromRGB(170, 0, 255) -- Nebula Purple
}

-- 2. CELESTIAL GUI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "CelestialTitan"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 350)
Main.Position = UDim2.new(0.5, -225, 0.4, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)

-- Nebula Gradient
local Gradient = Instance.new("UIGradient", Main)
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 30))
})
Gradient.Rotation = 45

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "TITAN • CELESTIAL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(0.95, 0, 0.8, 0)
Container.Position = UDim2.new(0.025, 0, 0.18, 0)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Container.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 12)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- UI COMPONENTS
local function CreateToggle(name, state_key)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0.9, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Btn.Text = name .. ": OFF"
    Btn.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 16
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

    Btn.MouseButton1Click:Connect(function()
        Titan[state_key] = not Titan[state_key]
        Btn.Text = name .. ": " .. (Titan[state_key] and "ON" or "OFF")
        Btn.TextColor3 = Titan[state_key] and Titan.Accent or Color3.new(0.6, 0.6, 0.6)
        Btn.BackgroundColor3 = Titan[state_key] and Color3.fromRGB(30, 40, 45) or Color3.fromRGB(25, 25, 35)
    end)
end

local function CreateSlider(name, min, max, state_key)
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(0.9, 0, 0, 20)
    Label.Text = name .. ": " .. Titan[state_key]
    Label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham

    local Bar = Instance.new("Frame", Container)
    Bar.Size = UDim2.new(0.85, 0, 0, 8)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((Titan[state_key] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Titan.Accent
    Instance.new("UICorner", Fill)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local pos = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Titan[state_key] = math.floor(min + (pos * (max - min)))
                Label.Text = name .. ": " .. Titan[state_key]
                if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() end
            end)
        end
    end)
end

-- INJECT MODULES
CreateToggle("STEALTH SPEED", "SpeedEnabled")
CreateSlider("SPEED INTENSITY", 1, 200, "Speed")
CreateToggle("CELESTIAL FLY", "FlyEnabled")
CreateSlider("FLY VELOCITY", 1, 200, "Fly")
CreateToggle("NOCLIP (GHOST)", "Noclip")
CreateToggle("ESP (GLOW GREEN)", "ESP")
CreateToggle("KILL AURA", "KillAura")

-- 3. CORE LOGIC (THE "POTENTIAL" STUFF)

-- ESP System (Highlight Method - Best Glow)
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LPlr and p.Character then
            local highlight = p.Character:FindFirstChild("TitanESP")
            if Titan.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "TitanESP"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Movement & Noclip Loop
RunService.Stepped:Connect(function()
    local char = LPlr.Character
    if not char then return end
    
    -- Noclip Logic
    if Titan.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local char = LPlr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Stealth Speed (CFrame)
    if Titan.SpeedEnabled and not Titan.FlyEnabled then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Titan.Speed * dt * 0.9))
        end
    end

    -- Celestial Fly
    if Titan.FlyEnabled then
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (moveDir * (Titan.Fly * dt))
    end

    -- Kill Aura (Logic Đa Năng)
    if Titan.KillAura then
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= LPlr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        -- Nã mọi Remote khả nghi trong Tool để gây damage
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") then v:FireServer(p.Character.HumanoidRootPart.Position) end
                        end
                    end
                end
            end
        end
    end
end)

-- Draggable UI Fix
local dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("🌌 VANGUARD TITAN: CELESTIAL EDITION LOADED.")
