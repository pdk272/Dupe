--[[ 
    VANGUARD TITAN V10.0 - KNIT BYPASS
    - Fix: Bỏ qua animation "reapplying sniper"
    - Method: Raycast Target (Bắn trực tiếp vào vật thể)
    - Target: ReplicatedStorage.Packages._Index...ShootSniper
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local Camera = workspace.CurrentCamera

local Config = {
    Enabled = false,
    FireDelay = 0.1, -- Nã liên tục mỗi 0.1 giây
    Accent = Color3.fromRGB(255, 0, 0)
}

-- 1. GUI
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanV10"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 200)
Main.Position = UDim2.new(0.5, 160, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V10 - KNIT BYPASS"
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- 2. HÀM TÌM REMOTE (CHUẨN THEO ẢNH)
local function GetShootRemote()
    local RS = game:GetService("ReplicatedStorage")
    local path = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("_Index")
    if path then
        for _, v in pairs(path:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name == "ShootSniper" then
                return v
            end
        end
    end
    return nil
end

-- 3. HÀM LẤY VẬT THỂ (TARGET) ĐANG NHẮM TỚI
local function GetAimedPart()
    local mouse = LPlr:GetMouse()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LPlr.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)

    if result and result.Instance then
        return result.Instance
    end
    return nil
end

-- 4. LOGIC RAPID FIRE (BYPASS ANIMATION)
task.spawn(function()
    while task.wait() do
        if Config.Enabled then
            local remote = GetShootRemote()
            local targetPart = GetAimedPart()
            
            if remote and targetPart then
                -- Nã Remote kèm theo vật thể đích để Server nhận diện hit
                -- Chúng ta nã 3-5 lần một lượt để đè bẹp cái cooldown 2s
                for i = 1, 3 do 
                    remote:FireServer(targetPart, targetPart.Position)
                end
            end
            task.wait(Config.FireDelay)
        end
    end
end)

-- 5. NÚT BẬT/TẮT
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9, 0, 0, 60)
Toggle.Position = UDim2.new(0.05, 0, 0, 65)
Toggle.Text = "FORCE RAPID: OFF"
Toggle.TextSize = 18
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    Toggle.Text = Config.Enabled and "FORCE RAPID: ACTIVE" or "FORCE RAPID: OFF"
    Toggle.TextColor3 = Config.Enabled and Config.Accent or Color3.new(1, 1, 1)
end)

local close = Instance.new("TextButton", Main)
close.Size = UDim2.new(0.9, 0, 0, 40)
close.Position = UDim2.new(0.05, 0, 0, 140)
close.Text = "TẮT MENU"
close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("🚀 TITAN V10 LOADED. Đang can thiệp sâu vào Sniper...")
