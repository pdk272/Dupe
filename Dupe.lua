--[[
    ⚡ TITAN INSTANT E - OPTIMIZED VERSION
    - Chức năng: Ép phím E về 0 giây ngay lập tức.
    - Tối ưu: Tiết kiệm tài nguyên, nút bấm di chuyển được.
    - Cơ chế: Auto-Apply cho cả đồ cũ và đồ mới rớt ra.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LPlr = game:GetService("Players").LocalPlayer
local PlayerGui = LPlr:WaitForChild("PlayerGui")

local Enabled = true -- Trạng thái mặc định

-- 1. TẠO GUI NÚT BẤM TỐI GIẢN
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "TitanFastE"
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 150, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -75, 0, 100) -- Vị trí giữa phía trên
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ToggleBtn.Text = "INSTANT E: ON"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Draggable = true -- Cho phép anh kéo nút đi chỗ khác cho gọn
Instance.new("UICorner", ToggleBtn)

-- 2. LOGIC TỐI ƯU HÓA (OPTIMIZED ENGINE)
local function ApplyFastE(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end

-- Quét đồ mới rớt ra ngay lập tức
workspace.DescendantAdded:Connect(function(descendant)
    if Enabled then
        ApplyFastE(descendant)
    end
end)

-- Vòng lặp quét bảo trì (Mỗi 0.5 giây một lần để không lag máy)
task.spawn(function()
    while task.wait(0.5) do
        if Enabled then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.HoldDuration ~= 0 then
                    ApplyFastE(v)
                end
            end
        end
    end
end)

-- 3. XỬ LÝ NÚT BẤM
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBtn.Text = "INSTANT E: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        ToggleBtn.Text = "INSTANT E: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- Khôi phục lại thời gian chờ mặc định (Tùy chọn)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 1 end -- Thường là 1s
        end
    end
end)

print("⚡ Titan Instant E Optimized đã sẵn sàng!")
