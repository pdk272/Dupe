--[[ 
    VANGUARD TITAN V11.0 - MEMORY OVERRIDE
    - Method: GC Scanning (Quét bộ nhớ Knit Controller).
    - Action: Ép Cooldown, Debounce, ReloadTime về 0.
    - Animation: Tăng tốc độ Animation lên 100x để bỏ qua 2s.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local Camera = workspace.CurrentCamera

local Config = {
    Enabled = false,
    FireDelay = 0.05,
    Accent = Color3.fromRGB(255, 0, 255)
}

-- 1. GUI
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanV11"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 220)
Main.Position = UDim2.new(0.5, 160, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 15)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V11 - MEMORY HACK"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(30, 0, 30)

-- 2. HÀM QUÉT BỘ NHỚ (MÓC KNIT CONTROLLER)
local function BypassMemory()
    -- Quét toàn bộ các bảng (Tables) trong bộ nhớ game
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            -- Tìm các bảng có chứa thông số của súng/sniper
            if v.FireRate or v.Cooldown or v.ReloadTime or v.NextFire then
                v.FireRate = 0
                v.Cooldown = 0
                v.ReloadTime = 0
                v.NextFire = 0
                v.Debounce = false
            end
        end
    end
end

-- 3. HÀM TĂNG TỐC ANIMATION (BỎ QUA 2S CHỜ)
local function SpeedUpAnimations()
    local char = LPlr.Character
    if char and char:FindFirstChild("Humanoid") then
        local animator = char.Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                -- Ép tốc độ animation lên cực cao để nó kết thúc ngay lập tức
                track:AdjustSpeed(100)
            end
        end
    end
end

-- 4. LOGIC BẮN (SNIPER REMOTE)
local function GetShootRemote()
    local RS = game:GetService("ReplicatedStorage")
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "ShootSniper" then return v end
    end
    return nil
end

task.spawn(function()
    while task.wait() do
        if Config.Enabled then
            BypassMemory() -- Liên tục ép bộ nhớ về 0
            SpeedUpAnimations() -- Bỏ qua animation nạp đạn
            
            local remote = GetShootRemote()
            if remote then
                -- Lấy tâm màn hình (FPS)
                local targetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * 1000)
                remote:FireServer(targetPos)
            end
            task.wait(Config.FireDelay)
        end
    end
end)

-- 5. NÚT ĐIỀU KHIỂN
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9, 0, 0, 60)
Toggle.Position = UDim2.new(0.05, 0, 0, 65)
Toggle.Text = "MEMORY OVERRIDE: OFF"
Toggle.TextSize = 18
Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    Toggle.Text = Config.Enabled and "OVERRIDE ACTIVE" or "MEMORY OVERRIDE: OFF"
    Toggle.TextColor3 = Config.Enabled and Config.Accent or Color3.new(1, 1, 1)
end)

local close = Instance.new("TextButton", Main)
close.Size = UDim2.new(0.9, 0, 0, 40)
close.Position = UDim2.new(0.05, 0, 0, 140)
close.Text = "TẮT MENU"
close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("🧠 TITAN V11 LOADED. Đang ép bộ nhớ Sniper...")
