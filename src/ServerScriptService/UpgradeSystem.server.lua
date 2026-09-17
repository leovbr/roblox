-- UpgradeSystem.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.GameConfig)

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local upgradeEvent = remotes:FindFirstChild("Upgrade") or Instance.new("RemoteEvent")
upgradeEvent.Name = "Upgrade"
upgradeEvent.Parent = remotes

local purchaseEvent = remotes:FindFirstChild("PurchaseRobux") or Instance.new("RemoteEvent")
purchaseEvent.Name = "PurchaseRobux"
purchaseEvent.Parent = remotes

local cooldown = {}

local function upgrade(player, kind)
	if cooldown[player] and os.clock() - cooldown[player] < 0.25 then return end
	cooldown[player] = os.clock()

	local stats = player:FindFirstChild("leaderstats")
	local data = player:FindFirstChild("GameData")
	local cash = stats and stats:FindFirstChild("Cash")
	if not data or not cash then return end

	local value
	local cost

	if kind == "Speed" then
		value = data:FindFirstChild("SpeedLevel")
		if not value or value.Value >= #Config.TREADMILL_SPEEDS then return end
		local nextLevel = value.Value + 1
		local price = Config.TREADMILL_PRICES[nextLevel]
		cost = price and price.cash or 0
	elseif kind == "Slots" then
		value = data:FindFirstChild("EggSlots")
		if not value or value.Value >= 15 then return end
		cost = 500 * (value.Value - 4)
	elseif kind == "Aura" then
		value = data:FindFirstChild("AuraLevel")
		if not value or value.Value >= 10 then return end
		cost = 1000 * (value.Value + 1)
	else
		return
	end

	if cost <= 0 or cash.Value < cost then return end
	cash.Value -= cost
	value.Value += 1
end

upgradeEvent.OnServerEvent:Connect(upgrade)

Players.PlayerRemoving:Connect(function(player)
	cooldown[player] = nil
end)
