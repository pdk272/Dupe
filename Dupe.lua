--[[ 
    VANGUARD TITAN V7.2 - SERVER CRASHER
    - Dual Lang: Quét cả "Accept" và "Chấp nhận" để chắc chắn 100%.
    - Server Focus: Nâng cấp Mass Trade cực mạnh để tạo Lag/Dupe.
    - Meta-Hook: Bắt sống Remote Trade ẩn.
    - Auto Interact: Chạm E 0.01s (Instant).
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser

local Config = {
    Accent = Color3.fromRGB(0, 255, 255), -- Màu xanh Neon
    MassSpam = false,
    AutoAccept = false,
    CapturedRemote = nil,
    Keywords = {"accept", "chấp nhận", "sẵn sàng", "ready", "confirm", "đồng ý"}
}

-- 1. GUI (TO RÕ, CHUYÊN DỤNG)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanV72"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 350)
Main.Position = UDim2.new(0.5, 160, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V7.2 - SERVER CRASHER"
Title.TextSize = 22
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. META-HOOK (BẮT TÍN HIỆU NGẦM)
local gmt = getrawmetatable(game)
local oldNamecall = gmt.__namecall
setreadonly(gmt, false)
gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and not checkcaller() then
        local name = tostring(self):lower()
        for _, k in pairs(Config.Keywords) do
            if name:find(k) or name:find("trade") then
                Config.CapturedRemote = self
                break
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(gmt, true)

-- 3. HÀM NÃ TRADE TOÀN SERVER (TẠO LAG)
local function MassTrade()
    if not Config.MassSpam then return end
    local players = Services.Players:GetPlayers()
    for _, p in pairs(players) do
        if p ~= LPlr and Config.CapturedRemote then
            task.spawn(function()
                Config.CapturedRemote:FireServer(p)
                Config.CapturedRemote:FireServer(p, "Request")
            end)
        end
    end
end

-- 4. HÀM CHẤP NHẬN SONG NGỮ (AUTO SCAN)
local function AutoAcceptLogic()
    if not Config.AutoAccept then return end
    for _, gui in pairs(LPlr.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui ~= ScreenGui then
            for _, v in pairs(gui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("TextLabel")) and v.Visible then
                    local txt = v.Text:lower()
                    for _, k in pairs(Config.Keywords) do
                        if txt:find(k) then
                            local target = v:IsA("TextButton") and v or v.Parent
                            if target:IsA("TextButton") then
                                -- Click tọa độ chuẩn
                                local pos = target.AbsolutePosition
                                local size = target.AbsoluteSize
                                VirtualUser:ClickButton1(Vector2.new(pos.X + (size.X/2), pos.Y + (size.Y/2) + 36))
                                -- Nã kèm Remote
                                if Config.CapturedRemote then Config.CapturedRemote:FireServer(true) end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 5. NÚT ĐIỀU KHIỂN
local function CreateBtn(text, pos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 50)
    b.Position = pos
    b.Text = text
    b.TextSize = 18
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local spamBtn = CreateBtn("MASS TRADE (LAG): OFF", UDim2.new(0.05, 0, 0, 60), function()
    Config.MassSpam = not Config.MassSpam
end)

local acceptBtn = CreateBtn("AUTO ACCEPT (DUPE): OFF", UDim2.new(0.05, 0, 0, 120), function()
    Config.AutoAccept = not Config.AutoAccept
end)

CreateBtn("FAST SERVER HOP", UDim2.new(0.05, 0, 0, 180), function()
    local s = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, s[math.random(1, #s)].id)
end)

-- VÒNG LẶP HỆ THỐNG
RunService.RenderStepped:Connect(function()
    -- Cập nhật màu nút
    spamBtn.Text = "MASS TRADE: " .. (Config.MassSpam and "ON (LAGGING)" or "OFF")
    spamBtn.TextColor3 = Config.MassSpam and Config.Accent or Color3.new(1,1,1)
    acceptBtn.Text = "AUTO ACCEPT: " .. (Config.AutoAccept and "ON" or "OFF")
    acceptBtn.TextColor3 = Config.AutoAccept and Config.Accent or Color3.new(1,1,1)
    
    -- Chạy logic
    AutoAcceptLogic()
    
    -- Ép nút E siêu nhanh
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0.01 end
    end
end)

task.spawn(function()
    while task.wait(0.3) do MassTrade() end
end)

CreateBtn("TẮT MENU", UDim2.new(0.05, 0, 0, 300), Color3.fromRGB(120, 0, 0), function() ScreenGui:Destroy() end)
