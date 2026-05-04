--[[
    VANGUARD TITAN: OMNI-POTENTIAL (V15.0)
    - Theme: Deep Space / Galactic
    - Tech: Vector-CFrame Alignment (Anti-Cheat Bypass)
    - Keybind: RightControl (Open/Close Menu)
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService
local Camera = workspace.CurrentCamera

-- 1. STATE & CONFIG
local Titan = {
    Speed = 16,
    SpeedEnabled = false,
    Fly = 50,
    FlyEnabled = false,
    Noclip = false,
    KillAura = false,
    ESP = false,
    HitboxSize = 2,
    HitboxEnabled = false,
    Aimbot = false,
    GhostMode = false,
    Visible = true,
    Accent = Color3.fromRGB(0, 255, 255),
    Secondary = Color3.fromRGB(200, 0, 255)
}

-- 2. ĐẲNG CẤP GUI (CELESTIAL DESIGN)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanOmni"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 480, 0, 400)
Main.Position = UDim2.new(0.5, -240, 0.4, -200)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

-- Hiệu ứng phát sáng Nebula
local Glow = Instance.new("ImageLabel", Main)
Glow.Size = UDim2.new(1.2, 0, 1.2, 0)
Glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://6015667310" -- Shadow glow
Glow.ImageColor3 = Titan.Secondary
Glow.ZIndex = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "TITAN • OMNI POTENTIAL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 26
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(0.95, 0, 0.8, 0)
Container.Position = UDim2.new(0.025, 0, 0.18, 0)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 15)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- UI COMPONENTS (CÓ HIỆN SỐ TRÊN SLIDER)
local function CreateToggle(name, key)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0.9, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Btn.Text = name .. ": OFF"
    Btn.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 16
    Instance.new("UICorner", Btn)

    Btn.MouseButton1Click:Connect(function()
        Titan[key] = not Titan[key]
        Btn.Text = name .. ": " .. (Titan[key] and "ON" or "OFF")
        Btn.TextColor3 = Titan[key] and Titan.Accent or Color3.new(0.5, 0.5, 0.5)
    end)
end

local function CreateSlider(name, min, max, key)
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(0.9, 0, 0, 25)
    Label.Text = name .. ": [" .. Titan[key] .. "]"
    Label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham

    local Bar = Instance.new("Frame", Container)
    Bar.Size = UDim2.new(0.85, 0, 0, 8)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((Titan[key] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Titan.Accent
    Instance.new("UICorner", Fill)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local pos = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Titan[key] = math.floor(min + (pos * (max - min)))
                Label.Text = name .. ": [" .. Titan[key] .. "]"
                if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() end
            end)
        end
    end)
end

-- INJECT MODULES
CreateToggle("ANTI-CHEAT SPEED", "SpeedEnabled")
CreateSlider("SPEED VALUE", 1, 200, "Speed")
CreateToggle("GHOST FLY", "FlyEnabled")
CreateSlider("FLY SPEED", 1, 200, "Fly")
CreateToggle("NOCLIP (GHOST)", "Noclip")
CreateToggle("HITBOX EXPANDER", "HitboxEnabled")
CreateSlider("HITBOX SIZE", 2, 50, "HitboxSize")
CreateToggle("INFINITY ESP (NAME/DIST)", "ESP")
CreateToggle("SILENT AIMBOT", "Aimbot")
CreateToggle("GHOST MODE (INVIS)", "GhostMode")
CreateToggle("KILL AURA", "KillAura")

-- 3. ĐIỀU KHIỂN ĐÓNG MỞ (RIGHT CONTROL)
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Titan.Visible = not Titan.Visible
        Main.Visible = Titan.Visible
    end
end)

-- 4. CORE ENGINE (POTENTIAL UPGRADE)

-- INFINITY ESP (NAME & DISTANCE)
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LPlr and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = head:FindFirstChild("TitanTag")
            
            if Titan.ESP then
                if not billboard then
                    billboard = Instance.new("BillboardGui", head)
                    billboard.Name = "TitanTag"
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    
                    local nameTag = Instance.new("TextLabel", billboard)
                    nameTag.Size = UDim2.new(1, 0, 1, 0)
                    nameTag.BackgroundTransparency = 1
                    nameTag.TextColor3 = Color3.new(1, 1, 1)
                    nameTag.TextStrokeTransparency = 0
                    nameTag.Font = Enum.Font.GothamBold
                    nameTag.TextSize = 14
                end
                local dist = math.floor((LPlr.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                billboard.TextLabel.Text = p.Name .. "\n[" .. dist .. "m]"
            else
                if billboard then billboard:Destroy() end
            end
        end
    end
end)

-- HITBOX & KILL AURA
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LPlr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            -- Hitbox
            if Titan.HitboxEnabled then
                hrp.Size = Vector3.new(Titan.HitboxSize, Titan.HitboxSize, Titan.HitboxSize)
                hrp.Transparency = 0.7
                hrp.Color = Color3.fromRGB(0, 255, 100)
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
            
            -- Kill Aura
            if Titan.KillAura then
                local myHrp = LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and (myHrp.Position - hrp.Position).Magnitude < 20 then
                    local tool = LPlr.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end
end)

-- STEALTH SPEED & FLY (ANTI-CHEAT BYPASS)
RunService.Heartbeat:Connect(function(dt)
    local char = LPlr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if Titan.SpeedEnabled and not Titan.FlyEnabled then
        if hum.MoveDirection.Magnitude > 0 then
            -- Sử dụng Vector Force Alignment để né check teleport
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Titan.Speed * dt * 0.95))
        end
    end

    if Titan.FlyEnabled then
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (moveDir * (Titan.Fly * dt))
    end
    
    -- Ghost Mode (Bóng ma)
    if Titan.GhostMode then
        hum.PlatformStand = true
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0.5 v.CanCollide = false end
        end
    else
        hum.PlatformStand = false
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if Titan.Noclip and LPlr.Character then
        for _, v in pairs(LPlr.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- SILENT AIM (TỰ BẺ ĐƯỜNG ĐẠN)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Titan.Aimbot and method == "FireServer" and (tostring(self):find("Shoot") or tostring(self):find("Hit")) then
        local target = nil
        local dist = 1000
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= LPlr and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then target = p dist = mag end
                end
            end
        end
        if target then args[1] = target.Character.Head.Position return oldNamecall(self, unpack(args)) end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

print("🌌 TITAN OMNI POTENTIAL V15.0 LOADED. Press RightControl to Toggle UI.")
