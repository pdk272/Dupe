--[[ 
    VANGUARD TITAN V8.0 - THE GHOST ENGINE
    - Instant Trigger: Bỏ qua việc "giữ E", tự động kích hoạt Prompt ngay khi chạm.
    - Deep Scanner: Quét mọi Object có chữ "Chấp", "Accept", "Confirm", "Xác nhận".
    - FireSignal: Ép nút bấm phải nổ ngay cả khi game chặn VirtualUser.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService

local Config = {
    Accent = Color3.fromRGB(255, 255, 255),
    Active = false,
    Keywords = {"accept", "chấp nhận", "sẵn sàng", "ready", "confirm", "xác nhận", "ok", "đồng ý"}
}

-- 1. GUI (THIẾT KẾ TỐI GIẢN, TRÁNH LAG)
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanGhost8"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 220)
Main.Position = UDim2.new(0.5, 160, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "TITAN V8.0 - GHOST ENGINE"
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- 2. HÀM ÉP NÚT E (INSTANT TRIGGER)
-- Không đợi HoldDuration, chỉ cần đứng gần là tự kích hoạt
task.spawn(function()
    while task.wait(0.1) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                -- Ép kích hoạt ngay lập tức
                v:InputHoldBegin()
                task.wait()
                v:InputHoldEnd()
                -- Một số game dùng Triggered
                fireproximityprompt(v)
            end
        end
    end
end)

-- 3. BỘ DÒ TÍN HIỆU ĐA TẦNG (DEEP SCAN)
local function UniversalAccept()
    if not Config.Active then return end
    
    for _, gui in pairs(LPlr.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui ~= ScreenGui then
            for _, v in pairs(gui:GetDescendants()) do
                -- Kiểm tra Text hoặc Tên Object
                local found = false
                local name = v.Name:lower()
                local txt = (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text:lower() or ""
                
                for _, k in pairs(Config.Keywords) do
                    if name:find(k) or txt:find(k) then
                        found = true break
                    end
                end
                
                if found then
                    -- CÁCH 1: Nã Remote (nếu tìm thấy)
                    task.spawn(function()
                        local rem = v:FindFirstChildOfClass("RemoteEvent") or v.Parent:FindFirstChildOfClass("RemoteEvent")
                        if rem then rem:FireServer(true) end
                    end)
                    
                    -- CÁCH 2: Ép Signal (Nếu là nút bấm chuẩn)
                    if v:IsA("TextButton") or v:IsA("ImageButton") then
                        firesignal(v.MouseButton1Click)
                        firesignal(v.MouseButton1Down)
                    elseif v.Parent:IsA("TextButton") then
                        firesignal(v.Parent.MouseButton1Click)
                    end
                end
            end
        end
    end
end

-- 4. NÚT ĐIỀU KHIỂN
local btn = Instance.new("TextButton", Main)
btn.Size = UDim2.new(0.9, 0, 0, 60)
btn.Position = UDim2.new(0.05, 0, 0, 60)
btn.Text = "AUTO TRADE: OFF"
btn.TextSize = 20
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
    Config.Active = not Config.Active
    btn.Text = Config.Active and "NUKE ACTIVE!" or "AUTO TRADE: OFF"
    btn.BackgroundColor3 = Config.Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
end)

RunService.RenderStepped:Connect(UniversalAccept)

local hop = Instance.new("TextButton", Main)
hop.Size = UDim2.new(0.9, 0, 0, 50)
hop.Position = UDim2.new(0.05, 0, 0, 130)
hop.Text = "FAST SERVER HOP"
hop.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hop.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hop)
hop.MouseButton1Click:Connect(function()
    local s = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, s[math.random(1, #s)].id)
end)

print("👻 GHOST ENGINE V8.0 LOADED. Đang ép tín hiệu...")
