--[[ 
    VANGUARD TITAN V13.0 - SILENT AIM
    - Target: ShootSniper Remote (Knit)
    - Feature: Đạn tự tìm đầu (Silent Aim)
    - Field of View (FOV): Vòng tròn giới hạn vùng quét mục tiêu.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = Services.RunService

local Config = {
    Enabled = false,
    TeamCheck = true,
    Fov = 150,
    Accent = Color3.fromRGB(255, 0, 0)
}

-- 1. FOV CIRCLE (VÒNG TRÒN QUÉT MỤC TIÊU)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 60
FovCircle.Radius = Config.Fov
FovCircle.Filled = false
FovCircle.Visible = false
FovCircle.Color = Config.Accent

-- 2. HÀM TÌM KẺ ĐỊCH GẦN TÂM NHẤT
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Config.Fov

    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LPlr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            -- Team Check (Nếu game có chia đội)
            if Config.TeamCheck and p.Team == LPlr.Team then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if distance < shortestDistance then
                    target = p
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- 3. HOOK REMOTE (BẺ LÁI ĐƯỜNG ĐẠN)
local gmt = getrawmetatable(game)
local oldNamecall = gmt.__namecall
setreadonly(gmt, false)

gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Config.Enabled and method == "FireServer" and tostring(self) == "ShootSniper" then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Thay đổi tham số đầu tiên (thường là tọa độ mục tiêu) thành vị trí đầu kẻ địch
            args[1] = target.Character.Head.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(gmt, true)

-- 4. GUI TỐI GIẢN
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanSilentAim"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 150)
Main.Position = UDim2.new(0.5, 150, 0.7, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9, 0, 0, 50)
Toggle.Position = UDim2.new(0.05, 0, 0, 50)
Toggle.Text = "SILENT AIM: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    FovCircle.Visible = Config.Enabled
    Toggle.Text = Config.Enabled and "SILENT AIM: ON" or "SILENT AIM: OFF"
    Toggle.TextColor3 = Config.Enabled and Config.Accent or Color3.new(1, 1, 1)
end)

RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

print("🎯 TITAN V13.0 LOADED. Silent Aim Ready.")
