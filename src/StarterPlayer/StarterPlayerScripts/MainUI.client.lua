-- MainUI.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("GameRemotes")
local hatchResult = remotes:WaitForChild("HatchResult")
local upgradeEvent = remotes:WaitForChild("Upgrade")
local purchaseEvent = remotes:WaitForChild("PurchaseRobux")
local trailEvent = remotes:WaitForChild("BuyTrail")
local Config = require(ReplicatedStorage:WaitForChild("GameConfig"))

local gui = Instance.new("ScreenGui")
gui.Name = "LeoHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, text, size, position, textSize)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Size = size
	l.Position = position
	l.TextScaled = false
	l.TextSize = textSize or 20
	l.Font = Enum.Font.GothamBold
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Parent = parent
	return l
end

local panel = Instance.new("Frame")
panel.Name = "Status"
panel.Size = UDim2.fromOffset(280, 145)
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local cashLabel = label(panel, "$0", UDim2.new(1, -20, 0, 38), UDim2.fromOffset(10, 8), 28)
local zoneLabel = label(panel, "ZONE 1", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 52), 18)
local slotsLabel = label(panel, "BRAINROTS 0/5", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 80), 16)
local boostLabel = label(panel, "SPEED x1", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 108), 15)

local actions = Instance.new("Frame")
actions.Name = "Actions"
actions.AnchorPoint = Vector2.new(1, 1)
actions.Position = UDim2.new(1, -16, 1, -16)
actions.Size = UDim2.fromOffset(235, 330)
actions.BackgroundTransparency = 1
actions.Parent = gui

local function button(text, y, callback, height)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(235, height or 42)
	b.Position = UDim2.fromOffset(0, y)
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.Text = text
	b.Parent = actions
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b
	b.Activated:Connect(callback)
	return b
end

local function cashText(n)
	if n >= 1000000000 then return string.format("%.1fB", n / 1000000000) end
	if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
	if n >= 1000 then return string.format("%.1fK", n / 1000) end
	return tostring(n)
end

local function nextSpeedText()
	local data = player:FindFirstChild("GameData")
	local level = data and data:FindFirstChild("SpeedLevel")
	local current = level and level.Value or 1
	local nextLevel = current + 1
	local price = Config.TREADMILL_PRICES[nextLevel]
	if not price then return "⚡ MAX SPEED" end
	return string.format("⚡ LVL %d  $%s / %dR", nextLevel, cashText(price.cash), price.robux)
end

button(nextSpeedText(), 0, function()
	local data = player:FindFirstChild("GameData")
	local level = data and data:FindFirstChild("SpeedLevel")
	local nextLevel = (level and level.Value or 1) + 1
	if Config.TREADMILL_PRICES[nextLevel] then
		upgradeEvent:FireServer("Speed")
	end
end)
button("💎 SPEED x2  /  2R", 50, function() purchaseEvent:FireServer("SpeedX2") end)
button("💎 SPEED x3  /  4R", 100, function() purchaseEvent:FireServer("SpeedX3") end)
button("💎 SPEED x4  /  8R", 150, function() purchaseEvent:FireServer("SpeedX4") end)
button("⚡ +$1M INSTANT  /  40R", 200, function()
	purchaseEvent:FireServer("SpeedInstant1M")
end)
button("✨ TRAIL: NEON  $100K / 15R", 250, function()
	trailEvent:FireServer("Neon")
end)
button("🌌 TRAIL: GALAXY  $10M / 100R", 300, function()
	trailEvent:FireServer("Galaxy")
end)

local toast = label(gui, "", UDim2.fromOffset(520, 45), UDim2.new(0.5, -260, 0.82, 0), 20)
toast.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toast.BackgroundTransparency = 0.12
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 10)
toastCorner.Parent = toast

local function showToast(message)
	toast.Text = message
	task.delay(3, function()
		if toast then toast.Text = "" end
	end)
end

purchaseEvent.OnClientEvent:Connect(function(success, message)
	showToast((success and "✓ " or "⚠ ") .. tostring(message))
end)

hatchResult.OnClientEvent:Connect(function(success, message)
	showToast(success and ("🎉 " .. message .. " BRAINROT!") or ("⚠ " .. message))
end)

task.spawn(function()
	while gui.Parent do
		local stats = player:FindFirstChild("leaderstats")
		local data = player:FindFirstChild("GameData")
		local cash = stats and stats:FindFirstChild("Cash")
		local zone = data and data:FindFirstChild("Zone")
		local slots = data and data:FindFirstChild("EggSlots")
		local brainrots = data and data:FindFirstChild("Brainrots")
		local multiplier = player:GetAttribute("SpeedBoostMultiplier") or 1
		if cash then cashLabel.Text = "$" .. cashText(cash.Value) end
		if zone then zoneLabel.Text = "ZONE " .. tostring(zone.Value) end
		if slots and brainrots then slotsLabel.Text = "BRAINROTS " .. #brainrots:GetChildren() .. "/" .. slots.Value end
		boostLabel.Text = "SPEED x" .. tostring(multiplier)
		local speedButton = actions:FindFirstChildWhichIsA("TextButton")
		if speedButton then speedButton.Text = nextSpeedText() end
		task.wait(0.25)
	end
end)
