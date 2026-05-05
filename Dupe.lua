--[[
    ⚡ VANGUARD TITAN: INSTANT E (LITE VERSION)
    - Tác dụng: Ép tất cả các phím tương tác (ProximityPrompt) về 0 giây.
    - Tối ưu: Cực kỳ nhẹ, tự động áp dụng cho đồ cũ và đồ mới rớt ra.
    - Giao diện: 1 nút bấm nhỏ gọn, có thể kéo thả (Draggable).
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local LPlr = game:GetService("Players").LocalPlayer
local PlayerGui = LPlr:WaitForChild("PlayerGui")

-- Trạng thái mặc định là Bật
local Enabled = true 

-- Xóa UI cũ nếu ông chạy lại script nhiều lần
if PlayerGui:FindFirstChild("TitanFastELite") then
    PlayerGui.TitanFastELite:Destroy()
end

-- 1. TẠO GUI SIÊU NHẸ
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "TitanFastELite"
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 130, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -65, 0, 20) -- Nằm gọn gàng giữa màn hình phía trên
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ToggleBtn.Text = "⚡ FAST E: ON"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Draggable = true -- Cho phép nắm kéo đi chỗ khác
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- 2. HÀM ÉP 0 GIÂY
local function ApplyFastE(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end

-- Tự động ép 0 giây cho bất kỳ đồ nào mới spawn ra
workspace.DescendantAdded:Connect(function(descendant)
    if Enabled then
        ApplyFastE(descendant)
    end
end)

-- Vòng lặp dọn dẹp quét lại map mỗi 0.5 giây (Tiết kiệm CPU, không gây lag)
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

-- 3. XỬ LÝ SỰ KIỆN NÚT BẤM
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBtn.Text = "⚡ FAST E: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        ToggleBtn.Text = "⚡ FAST E: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- Tùy chọn: Khi tắt, trả lại 1 giây cho đồ trong map
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 1
            end
        end
    end
end)

print("⚡ TITAN FAST E LITE LOADED!")
