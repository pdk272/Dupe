--[[ 
    VANGUARD TITAN V6.3 - VIETNAM SNIPER
    - Target Keyword: "Chấp nhận", "Sẵn sàng"
    - Method: Virtual Click + Remote Spam
    - Fast Interact: Ép nút E về 0 giây (Instant)
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser

local Config = {
    Accent = Color3.fromRGB(0, 255, 120),
    AutoReady = false,
    FastInteract = true
}

-- 1. GUI (TO RÕ THEO PHONG CÁCH CỦA ÔNG)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanVNSniper"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 280)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TITAN V6.3 - VN SNIPER"
Title.TextSize = 20
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Title)

-- 2. AUTO INTERACT (ÉP NÚT E 0 GIÂY)
task.spawn(function()
    while task.wait(1) do
        if Config.FastInteract then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0 -- Chạm là ăn ngay
                    v.ClickablePrompt = true
                end
            end
        end
    end
end)

-- 3. AUTO READY BYPASS (DÒ TỪ KHÓA TIẾNG VIỆT)
local readyBtn = Instance.new("TextButton", Main)
readyBtn.Size = UDim2.new(0.9, 0, 0, 60)
readyBtn.Position = UDim2.new(0.05, 0, 0, 70)
readyBtn.Text = "TỰ CHẤP NHẬN: OFF"
readyBtn.TextSize = 18
readyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
readyBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", readyBtn)

readyBtn.MouseButton1Click:Connect(function()
    Config.AutoReady = not Config.AutoReady
    readyBtn.Text = "TỰ CHẤP NHẬN: " .. (Config.AutoReady and "ON" or "OFF")
    readyBtn.TextColor3 = Config.AutoReady and Config.Accent or Color3.new(1,1,1)
end)

RunService.RenderStepped:Connect(function()
    if Config.AutoReady then
        -- Quét toàn bộ GUI của người chơi
        for _, gui in pairs(LPlr.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, v in pairs(gui:GetDescendants()) do
                    -- Tìm Remote Event theo từ khóa Tiếng Việt hoặc tên liên quan
                    if v:IsA("RemoteEvent") and (v.Name:find("Trade") or v.Name:find("Accept")) then
                        v:FireServer(true)
                    end
                    
                    -- Tìm Nút Bấm có chữ "Chấp nhận" hoặc "Sẵn sàng"
                    if v:IsA("TextButton") or v:IsA("TextLabel") then
                        local txt = v.Text:lower()
                        if txt:find("chấp nhận") or txt:find("sẵn sàng") or txt:find("ready") then
                            -- Nếu là nút bấm, giả lập Click chuột vào tâm nút
                            if v:IsA("TextButton") then
                                local pos = v.AbsolutePosition
                                local size = v.AbsoluteSize
                                VirtualUser:ClickButton1(Vector2.new(pos.X + (size.X/2), pos.Y + (size.Y/2)))
                            -- Nếu là nhãn dán nằm trong nút, bấm vào cha của nó
                            elseif v.Parent:IsA("TextButton") then
                                local pos = v.Parent.AbsolutePosition
                                local size = v.Parent.AbsoluteSize
                                VirtualUser:ClickButton1(Vector2.new(pos.X + (size.X/2), pos.Y + (size.Y/2)))
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 4. SERVER HOP (DUPE HOP)
local hop = Instance.new("TextButton", Main)
hop.Size = UDim2.new(0.9, 0, 0, 60)
hop.Position = UDim2.new(0.05, 0, 0, 140)
hop.Text = "DUPE HOP (FAST)"
hop.TextSize = 18
hop.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hop.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hop)

hop.MouseButton1Click:Connect(function()
    local servers = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)].id)
end)

-- NÚT ĐÓNG
local close = Instance.new("TextButton", Main)
close.Size = UDim2.new(0.9, 0, 0, 40)
close.Position = UDim2.new(0.05, 0, 0, 220)
close.Text = "TẮT MENU"
close.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("🎯 VN SNIPER V6.3 LOADED. Đang dò từ khóa 'Chấp nhận'...")
