--[[ 
    VANGUARD TITAN V12.0 - ANIMATION KILLER
    - Method: Hooking Animation & Wait (Bỏ qua 2s chờ của súng).
    - Target: Knit Sniper Controller.
    - Feature: Ép súng kết thúc trạng thái "Đang nạp đạn" ngay lập tức.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService

local Config = {
    Enabled = false,
    Accent = Color3.fromRGB(255, 255, 255)
}

-- 1. GUI TỐI GIẢN
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanV12"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 150)
Main.Position = UDim2.new(0.5, 160, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TITAN V12 - FINAL"
Title.TextColor3 = Config.Accent
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- 2. HÀM "GIẾT" ANIMATION (BỎ QUA 2S ĐỢI)
local function KillCooldown()
    -- Cách 1: Ép mọi Animation nạp đạn phải kết thúc trong 0.1s
    local char = LPlr.Character
    if char and char:FindFirstChild("Humanoid") then
        local animator = char.Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                -- Nếu thấy animation liên quan đến súng (Sniper)
                if track.Name:lower():find("sniper") or track.Name:lower():find("bolt") then
                    track:AdjustSpeed(100) -- Chạy nhanh gấp 100 lần
                end
            end
        end
    end

    -- Cách 2: Quét bộ nhớ để tìm trạng thái "Reloading" và ép nó về false
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            if rawget(v, "Reloading") ~= nil or rawget(v, "IsAiming") ~= nil then
                v.Reloading = false
                v.Cooldown = 0
                v.NextFire = 0
            end
        end
    end
end

-- 3. NÃ REMOTE (DỰA TRÊN ẢNH CỦA ÔNG)
local function FireRemote()
    local RS = game:GetService("ReplicatedStorage")
    local remote = nil
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "ShootSniper" then
            remote = v break
        end
    end

    if remote then
        local cam = workspace.CurrentCamera
        local targetPos = cam.CFrame.Position + (cam.CFrame.LookVector * 1000)
        remote:FireServer(targetPos)
    end
end

-- 4. NÚT KÍCH HOẠT
local btn = Instance.new("TextButton", Main)
btn.Size = UDim2.new(0.9, 0, 0, 50)
btn.Position = UDim2.new(0.05, 0, 0, 50)
btn.Text = "FORCE RAPID: OFF"
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    btn.Text = Config.Enabled and "ACTIVE (SẤY)" or "FORCE RAPID: OFF"
    btn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        KillCooldown()
        FireRemote()
    end
end)

print("💀 TITAN V12 - Đòn cuối cùng để phá Cooldown...")
