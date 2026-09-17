-- MonetizationSystem.server.lua
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.GameConfig)

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local purchaseEvent = remotes:FindFirstChild("PurchaseRobux") or Instance.new("RemoteEvent")
purchaseEvent.Name = "PurchaseRobux"
purchaseEvent.Parent = remotes

local trailEvent = remotes:FindFirstChild("BuyTrail") or Instance.new("RemoteEvent")
trailEvent.Name = "BuyTrail"
trailEvent.Parent = remotes

local productToAction = {}
for action, id in pairs(Config.DEVELOPER_PRODUCTS) do
	if typeof(id) == "number" and id > 0 then productToAction[id] = action end
end

local function dataOf(player) return player:FindFirstChild("GameData") end
local function cashOf(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

local function award(player, action)
	local data, cash = dataOf(player), cashOf(player)
	if not data then return false end

	if action:match("^Treadmill%d+$") then
		local level = tonumber(action:match("%d+$"))
		local speedLevel = data:FindFirstChild("SpeedLevel")
		if not speedLevel or not level or level ~= speedLevel.Value + 1 or level > #Config.TREADMILL_SPEEDS then return false end
		speedLevel.Value = level
		return true
	end

	if action:match("^SpeedX%d+$") then
		local multiplier = tonumber(action:match("%d+$"))
		local boost = Config.SPEED_BOOSTS["X" .. multiplier]
		if not boost then return false end
		local current = player:GetAttribute("SpeedBoostMultiplier") or 1
		if multiplier <= current then return false end
		player:SetAttribute("SpeedBoostMultiplier", multiplier)
		return true
	end

	if action == "InstantMoney1M" then
		if not cash then return false end
		cash.Value += Config.INSTANT_MONEY.cash
		return true
	end

	if action == "SpeedInstant1M" then
		if not cash then return false end
		local speedLevel = data:FindFirstChild("SpeedLevel")
		if not speedLevel or speedLevel.Value >= #Config.TREADMILL_SPEEDS then return false end
		if cash.Value < Config.INSTANT_SPEED.cash then return false end
		cash.Value -= Config.INSTANT_SPEED.cash
		speedLevel.Value += 1
		return true
	end

	if action:match("^Trail") then
		local trailName = action:sub(6)
		if not Config.TRAILS[trailName] then return false end
		local owned = data:FindFirstChild("OwnedTrails") or Instance.new("Folder")
		owned.Name = "OwnedTrails"
		owned.Parent = data
		local flag = owned:FindFirstChild(trailName)
		if not flag then
			flag = Instance.new("BoolValue")
			flag.Name = trailName
			flag.Value = true
			flag.Parent = owned
		end
		player:SetAttribute("EquippedTrail", trailName)
		return true
	end

	return false
end

purchaseEvent.OnServerEvent:Connect(function(player, action)
	if typeof(action) ~= "string" then return end
	local productId = Config.DEVELOPER_PRODUCTS[action]
	if typeof(productId) ~= "number" or productId <= 0 then
		purchaseEvent:FireClient(player, false, "Product ID belum dipasang: " .. action)
		return
	end
	MarketplaceService:PromptProductPurchase(player, productId)
end)

trailEvent.OnServerEvent:Connect(function(player, trailName)
	if typeof(trailName) ~= "string" then return end
	local cfg = Config.TRAILS[trailName]
	local cash, data = cashOf(player), dataOf(player)
	if not cfg or not cash or not data then return end
	local owned = data:FindFirstChild("OwnedTrails") or Instance.new("Folder")
	owned.Name = "OwnedTrails"
	owned.Parent = data
	if owned:FindFirstChild(trailName) then
		player:SetAttribute("EquippedTrail", trailName)
		return
	end
	if cash.Value < cfg.cash then return end
	cash.Value -= cfg.cash
	local flag = Instance.new("BoolValue")
	flag.Name = trailName
	flag.Value = true
	flag.Parent = owned
	player:SetAttribute("EquippedTrail", trailName)
end)

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local action = productToAction[receiptInfo.ProductId]
	if not action then return Enum.ProductPurchaseDecision.NotProcessedYet end
	if award(player, action) then return Enum.ProductPurchaseDecision.PurchaseGranted end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
