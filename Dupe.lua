--[[ 
    VANGUARD TITAN V9.0 - RAPID FIRE
    - Feature: Bypass Cooldown (Bắn nhanh hơn tốc độ game cho phép).
    - Method: Remote Spam (Nã tín hiệu bắn liên tục).
    - UI: Thanh chỉnh tốc độ bắn (Delay).
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local UIS = Services.UserInputService

local Config = {
    RapidEnabled = false,
    FireDelay = 0.1, -- Tốc độ nã đạn (0.1 là cực nhanh)
    Accent = Color3.fromRGB(255, 50, 50) -- Màu đỏ chiến đấu
}

-- 1. GUI (TO RÕ, DỄ ĐIỀU CHỈNH)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanRapidFire"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 280)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V9.0 - RAPID FIRE"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Title)

-- 2. NÚT BẬT/TẮT RAPID FIRE
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9, 0, 0, 60)
Toggle.Position = UDim2.new(0.05, 0, 0, 65)
Toggle.Text = "RAPID FIRE: OFF"
Toggle.TextSize = 18
Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    Config.RapidEnabled = not Config.RapidEnabled
    Toggle.Text = Config.RapidEnabled and "RAPID FIRE: ON" or "RAPID FIRE: OFF"
    Toggle.TextColor3 = Config.RapidEnabled and Config.Accent or Color3.new(1, 1, 1)
end)

-- 3. THANH CHỈNH TỐC ĐỘ (DELAY)
local DelayLabel = Instance.new("TextLabel", Main)
DelayLabel.Size = UDim2.new(1, 0, 0, 30)
DelayLabel.Position = UDim2.new(0, 0, 0, 130)
DelayLabel.Text = "DELAY: 0.1s (SIÊU NHANH)"
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
Knob.Position = UDim2.new(0.1, -12, 0.5, -12) -- Mặc định ở 0.1s
Knob.Text = ""
Knob.BackgroundColor3 = Config.Accent
Instance.new("UICorner", Knob)

-- Logic Slider cho Delay
local dragging = false
Knob.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Knob.Position = UDim2.new(pos, -12, 0.5, -12)
        Config.FireDelay = math.clamp(pos, 0.01, 1) -- Delay từ 0.01s đến 1s
        DelayLabel.Text = "DELAY: " .. string.format("%.2f", Config.FireDelay) .. "s"
    end
end)

-- 4. LOGIC TÌM REMOTE VÀ BẮN
local function GetFireRemote(tool)
    -- Tìm trong tool các RemoteEvent có tên liên quan đến bắn/dùng
    for _, v in pairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("fire") or n:find("shoot") or n:find("attack") or n:find("activated") or n:find("use") or n:find("action") then
                return v
            end
        end
    end
    return nil
end

-- Vòng lặp bắn
task.spawn(function()
    while task.wait() do
        if Config.RapidEnabled then
            local char = LPlr.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            
            if tool then
                local remote = GetFireRemote(tool)
                if remote then
                    -- Nã Remote liên tục kèm theo vị trí chuột
                    local mousePos = LPlr:GetMouse().Hit.Position
                    remote:FireServer(mousePos) -- Kiểu phổ thông
                    remote:FireServer() -- Kiểu dự phòng
                end
                -- Tự động kích hoạt Tool (nếu game dùng Tool:Activate)
                tool:Activate()
            end
            task.wait(Config.FireDelay)
        end
    end
end)

-- NÚT TẮT
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0.9, 0, 0, 45)
Close.Position = UDim2.new(0.05, 0, 0, 220)
Close.Text = "TẮT MENU"
Close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("🔫 TITAN RAPID FIRE LOADED. Nã đạn thôi ông ơi!")
