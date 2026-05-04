--[[ 
    VANGUARD TITAN V6.6 - DUPE EXPLOIT
    - Method: Packet Split (Chấp nhận + Thoát nhanh).
    - Target: Bỏ qua 1s Countdown để Snap Pet.
    - Feature: Instant Dupe (Chấp nhận & Hop Server ngay lập tức).
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser

local Config = {
    Accent = Color3.fromRGB(0, 200, 255), -- Màu xanh điện tử
    AutoReady = false,
    FastInteract = true
}

-- 1. GUI
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanDupeEx"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 300)
Main.Position = UDim2.new(0.5, 150, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V6.6 - DUPE EX"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. FAST INTERACT (CHẠM E 0S)
task.spawn(function()
    while task.wait(0.5) do
        if Config.FastInteract then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 3. HÀM CHẤP NHẬN SIÊU TỐC
local function InstantAccept()
    for _, gui in pairs(LPlr.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in pairs(gui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("TextLabel")) and v.Visible then
                    local txt = v.Text:lower()
                    if txt:find("chấp nhận") or txt:find("sẵn sàng") or txt:find("accept") then
                        local target = v:IsA("TextButton") and v or v.Parent
                        if target:IsA("TextButton") then
                            -- Nã tín hiệu
                            local rem = target:FindFirstChildOfClass("RemoteEvent") or target.Parent:FindFirstChildOfClass("RemoteEvent")
                            if rem then rem:FireServer(true) end
                            -- Giả lập click
                            local pos = target.AbsolutePosition
                            local size = target.AbsoluteSize
                            VirtualUser:ClickButton1(Vector2.new(pos.X + (size.X/2), pos.Y + (size.Y/2)))
                        end
                    end
                end
            end
        end
    end
end

-- 4. NÚT CHỨC NĂNG
local function CreateBtn(text, pos, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 50)
    b.Position = pos
    b.Text = text
    b.TextSize = 18
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- BẬT SNAP TỰ ĐỘNG
local snapBtn = CreateBtn("AUTO SNAP: OFF", UDim2.new(0.05, 0, 0, 65), Color3.fromRGB(30, 30, 30), function()
    Config.AutoReady = not Config.AutoReady
end)

-- NÚT INSTANT DUPE (QUAN TRỌNG NHẤT)
CreateBtn("⚡ INSTANT DUPE ⚡", UDim2.new(0.05, 0, 0, 125), Color3.fromRGB(0, 120, 200), function()
    -- BƯỚC 1: Chấp nhận trade ngay lập tức
    InstantAccept()
    task.wait(0.1) -- Đợi server nhận lệnh nhận pet
    -- BƯỚC 2: Force Server Hop để dupe dữ liệu
    local servers = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)].id)
end)

CreateBtn("SERVER HOP", UDim2.new(0.05, 0, 0, 185), Color3.fromRGB(30, 30, 30), function()
    local servers = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)].id)
end)

RunService.RenderStepped:Connect(function()
    if Config.AutoReady then
        InstantAccept()
        snapBtn.Text = "AUTO SNAP: ON"
        snapBtn.TextColor3 = Config.Accent
    else
        snapBtn.Text = "AUTO SNAP: OFF"
        snapBtn.TextColor3 = Color3.new(1,1,1)
    end
end)

CreateBtn("TẮT MENU", UDim2.new(0.05, 0, 0, 245), Color3.fromRGB(120, 0, 0), function() ScreenGui:Destroy() end)
