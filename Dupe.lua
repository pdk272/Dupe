--[[
    ⚡ VANGUARD TITAN: INSTANT E (STANDALONE MODULE)
    - Tác dụng: Ép thời gian giữ phím E về 0 giây (Không cần chờ).
    - Đặc điểm: Siêu nhẹ, chạy ngầm, tự động áp dụng cho đồ mới rớt.
]]

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
    -- Quét toàn bộ map để tìm các nút tương tác
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            -- Triệt tiêu hoàn toàn thời gian chờ
            obj.HoldDuration = 0 
            
            -- (Tùy chọn) Anh có thể bỏ dấu -- ở dòng dưới để tăng tầm với nhặt đồ
            -- obj.MaxActivationDistance = 20 
        end
    end
end)

print("⚡ STANDALONE MODULE: Fast E (0s) đã được kích hoạt!")
