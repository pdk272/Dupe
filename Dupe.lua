--[[
    📡 TITAN ELITE FINDER V33.0
    - Fixed: Lỗi nil value khi gọi GUI.
    - Added: Chicleteirina, Bicicleterina.
    - Logic: Tự động nhận diện Executor (Fix lỗi gửi Webhook).
]]

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LPlr = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ================= CẤU HÌNH HỆ THỐNG =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1501273736580567132/8eMKz7k1UtE1F_3zcE2zOiO750wRM3umAYEZEjWsxAspbt16PnxmI4Mp-xSc7nVWlwk6"

local PETS_TO_FIND = {
    "garama",
    "chicleteirina",
    "bicicleterina",
    "hugedog"
}
-- =====================================================

local Titan = { Visible = true, FastE = true }
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 1. GIAO DIỆN CHÍNH (FIXED DRAG & SIZE)
local ScreenGui = Instance.new("ScreenGui", LPlr:WaitForChild("PlayerGui"))
ScreenGui.Name = "TitanEliteFinder"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 300)
Main.Position = UDim2.new(0.5, -175, 0.4, -150)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.new(1,1,1)
local Grad = Instance.new("UIGradient", Header)
Grad.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(0, 255, 255))
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "  📡 TITAN ELITE FINDER V33"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- 2. CÁC THÀNH PHẦN ĐIỀU KHIỂN
local function CreateBtn(text, pos, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 45)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

local JobInput = Instance.new("TextBox", Main)
JobInput.Size = UDim2.new(0.9, 0, 0, 40)
JobInput.Position = UDim2.new(0.05, 0, 0.2, 0)
JobInput.PlaceholderText = "DÁN JOBID TỪ DISCORD..."
JobInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
JobInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", JobInput)

CreateBtn("JOIN SERVER HIỆN TẠI", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(0, 120, 255), function()
    local id = JobInput.Text:gsub("%s+", "")
    if id ~= "" then TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LPlr) end
end)

CreateBtn("⚡ INSTANT E (0s): ON", UDim2.new(0.05, 0, 0.6, 0), Color3.fromRGB(0, 180, 100), function(b)
    Titan.FastE = not Titan.FastE
    b.Text = "⚡ INSTANT E (0s): " .. (Titan.FastE and "ON" or "OFF")
    b.BackgroundColor3 = Titan.FastE and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(180, 50, 50)
end)

-- 3. LOGIC GỬI WEBHOOK (Dành cho acc phụ cắm Bot)
local function SendMissions(name)
    if request then
        pcall(function()
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = "🎯 MỤC TIÊU ĐÃ XUẤT HIỆN!",
                        ["description"] = "**Pet:** `" .. name .. "`\n**JobId:**\n```" .. game.JobId .. "
```",
                        ["color"] = 0x00FFFF
                    }}
                })
            })
        end)
    end
end

-- 4. VÒNG LẶP HỆ THỐNG
RunService.Heartbeat:Connect(function()
    if Titan.FastE then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    end
end)

-- Phím K để ẩn/hiện
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.K then Main.Visible = not Main.Visible end
end)

print("✅ TITAN ELITE FINDER V33 LOADED! Press K to Toggle.")
