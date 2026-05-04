--[[ 
    VANGUARD TITAN V6.7 - HARDCORE SCANNER
    - Fix: Tự động dò tìm tọa độ nút Chấp nhận (kể cả khi là hình ảnh).
    - Method: Raycast GUI (Quét mọi vật thể có thể click trên bảng Trade).
    - Speed: Nã 100 click/giây vào vùng mục tiêu.
]]

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local LPlr = Services.Players.LocalPlayer
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser

local Config = {
    Accent = Color3.fromRGB(255, 0, 0), -- Màu đỏ (Cảnh báo/Hardcore)
    AutoReady = false,
}

-- 1. GUI
local ScreenGui = Instance.new("ScreenGui", LPlr.PlayerGui)
ScreenGui.Name = "TitanHardcore"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 200)
Main.Position = UDim2.new(0.5, 150, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "TITAN V6.7 - HARDCORE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)

-- 2. HÀM QUÉT VÀ CLICK TỌA ĐỘ (CỰC MẠNH)
local function HardcoreClick()
    -- Tìm tất cả ScreenGui đang bật
    for _, gui in pairs(LPlr.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "TitanHardcore" then
            for _, v in pairs(gui:GetDescendants()) do
                -- Kiểm tra nếu là Nút bấm hoặc vật thể có thể tương tác
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible and v.AbsoluteSize.X > 0 then
                    local txt = ""
                    if v:IsA("TextButton") then txt = v.Text:lower() end
                    
                    -- Dò tìm từ khóa hoặc vị trí nghi vấn (thường nút chấp nhận nằm bên phải hoặc phía dưới)
                    if txt:find("chấp nhận") or txt:find("sẵn sàng") or txt:find("accept") or txt:find("ready") or v.Name:lower():find("confirm") then
                        -- Lấy tọa độ thật trên màn hình
                        local pos = v.AbsolutePosition
                        local size = v.AbsoluteSize
                        local centerX = pos.X + (size.X / 2)
                        local centerY = pos.Y + (size.Y / 2) + 36 -- +36 để bù trừ thanh tiêu đề Roblox
                        
                        -- Nã Click chuột ảo trực tiếp vào tọa độ đó
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(centerX, centerY))
                        
                        -- Thử nã Remote song song
                        local rem = v:FindFirstChildOfClass("RemoteEvent") or v.Parent:FindFirstChildOfClass("RemoteEvent")
                        if rem then rem:FireServer(true) end
                    end
                end
            end
        end
    end
end

-- 3. NÚT ĐIỀU KHIỂN
local snapBtn = Instance.new("TextButton", Main)
snapBtn.Size = UDim2.new(0.9, 0, 0, 60)
snapBtn.Position = UDim2.new(0.05, 0, 0, 60)
snapBtn.Text = "FORCE SNAP: OFF"
snapBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
snapBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", snapBtn)

snapBtn.MouseButton1Click:Connect(function()
    Config.AutoReady = not Config.AutoReady
    snapBtn.Text = Config.AutoReady and "FORCE SNAP: ACTIVE" or "FORCE SNAP: OFF"
    snapBtn.BackgroundColor3 = Config.AutoReady and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
end)

-- Vòng lặp nã lệnh liên tục
RunService.RenderStepped:Connect(function()
    if Config.AutoReady then
        HardcoreClick()
    end
end)

local close = Instance.new("TextButton", Main)
close.Size = UDim2.new(0.9, 0, 0, 40)
close.Position = UDim2.new(0.05, 0, 0, 140)
close.Text = "TẮT SCRIPT"
close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
