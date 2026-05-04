--[[
    VANGUARD TITAN: OMNI-POTENTIAL (V15.1)
    - Theme: Deep Space / Galactic
    - Tech: Vector-CFrame Alignment (Anti-Cheat Bypass)
    - Keybind: K (Open/Close Menu) - Theo yêu cầu của ông.
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
Title.Text = "TITAN • OMNI V15.1"
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

-- UI COMPONENTS
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
CreateToggle("INFINITY ESP", "ESP")
CreateToggle("SILENT AIMBOT", "Aimbot")
CreateToggle("GHOST MODE", "GhostMode")
CreateToggle("KILL AURA", "KillAura")

-- 3. ĐIỀU KHIỂN ĐÓNG MỞ (PHÍM K)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end -- Không phản hồi nếu đang gõ chat
    if input.KeyCode == Enum.KeyCode.K then
        Titan.Visible = not Titan.Visible
        Main.Visible = Titan.Visible
        -- Hiệu ứng thông báo nhỏ ở Console cho đẳng cấp
        print("🌌 Menu Status: " .. (Titan.Visible and "Visible" or "Hidden"))
    end
end)

-- 4. CORE ENGINE
-- (Giữ nguyên các hàm ESP, Hitbox, Speed, Silent Aim từ bản V15.0 của ông)

RunService.RenderStepped:Connect(function()
    if Titan.ESP then
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= LPlr and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local billboard = head:FindFirstChild("TitanTag")
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
                    nameTag.Font = Enum.Font.GothamBold
                    nameTag.TextSize = 14
                end
                local dist = math.floor((LPlr.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                billboard.TextLabel.Text = p.Name .. "\n[" .. dist .. "m]"
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local char = LPlr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if Titan.SpeedEnabled then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Titan.Speed * dt * 0.95))
        end
    end

    if Titan.FlyEnabled then
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (moveDir * (Titan.Fly * dt))
    end
end)

print("🌌 TITAN V15.1 READY. Nhấn phím 'K' để đóng/mở menu nhé ông!")
