-- MainUI.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("GameRemotes")
local hatchResult = remotes:WaitForChild("HatchResult")
local upgradeEvent = remotes:WaitForChild("Upgrade")

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
panel.Size = UDim2.fromOffset(250, 120)
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
panel.BackgroundTransparency = 0.12
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local cashLabel = label(panel, "$0", UDim2.new(1, -20, 0, 38), UDim2.fromOffset(10, 8), 28)
local zoneLabel = label(panel, "ZONE 1", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 50), 18)
local slotsLabel = label(panel, "BRAINROTS 0/5", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 78), 16)

local actions = Instance.new("Frame")
actions.Name = "Actions"
actions.AnchorPoint = Vector2.new(1, 1)
actions.Position = UDim2.new(1, -16, 1, -16)
actions.Size = UDim2.fromOffset(180, 170)
actions.BackgroundTransparency = 1
actions.Parent = gui

local function button(text, y, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(180, 46)
	b.Position = UDim2.fromOffset(0, y)
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text
	b.Parent = actions
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b
	b.Activated:Connect(callback)
end

button("⚡ UPGRADE SPEED", 0, function() upgradeEvent:FireServer("Speed") end)
button("🥚 + SLOT", 56, function() upgradeEvent:FireServer("Slots") end)
button("✨ AURA", 112, function() upgradeEvent:FireServer("Aura") end)

local toast = label(gui, "", UDim2.fromOffset(420, 45), UDim2.new(0.5, -210, 0.82, 0), 22)
toast.BackgroundTransparency = 0.2

task.spawn(function()
	while gui.Parent do
		local stats = player:FindFirstChild("leaderstats")
		local data = player:FindFirstChild("GameData")
		local cash = stats and stats:FindFirstChild("Cash")
		local zone = data and data:FindFirstChild("Zone")
		local slots = data and data:FindFirstChild("EggSlots")
		local brainrots = data and data:FindFirstChild("Brainrots")
		if cash then cashLabel.Text = "$" .. tostring(cash.Value) end
		if zone then zoneLabel.Text = "ZONE " .. tostring(zone.Value) end
		if slots and brainrots then slotsLabel.Text = "BRAINROTS " .. #brainrots:GetChildren() .. "/" .. slots.Value end
		task.wait(0.25)
	end
end)

hatchResult.OnClientEvent:Connect(function(success, message)
	toast.Text = success and ("🎉 " .. message .. " BRAINROT!") or ("⚠ " .. message)
	task.delay(2.5, function()
		if toast then toast.Text = "" end
	end)
end)
