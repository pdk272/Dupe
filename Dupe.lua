--[[ 
    VANGUARD TITAN - KNIT SNIFFER (PRO VERSION)
    - Công dụng: Soi toàn bộ dữ liệu (Arguments) mà Sniper gửi đi.
    - Mục tiêu: Tìm xem game có gửi kèm mã bảo mật hoặc mã thời gian không.
]]

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Chỉ bắt đúng cái Remote ShootSniper ông đã tìm thấy
    if tostring(self) == "ShootSniper" and method == "FireServer" then
        print("-------------------------------")
        print("🎯 ĐÃ BẮT ĐƯỢC LỆNH BẮN!")
        for i, v in pairs(args) do
            print("Tham số [" .. i .. "]:", v, "(" .. type(v) .. ")")
        end
        -- ĐÂY LÀ CHỖ ÔNG CẦN SOI: 
        -- Nếu thấy có một con số nhảy liên tục, đó là mã thời gian (Cooldown).
    end

    return oldNamecall(self, ...)
end))

print("🔬 SNIFFER ACTIVE. Hãy bắn thử 1 phát để xem 'nội tạng' của gói tin!")
