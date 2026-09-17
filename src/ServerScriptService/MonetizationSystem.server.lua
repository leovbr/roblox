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

local boostEvent = remotes:FindFirstChild("SpeedBoost") or Instance.new("RemoteEvent")
boostEvent.Name = "SpeedBoost"
boostEvent.Parent = remotes

local trailEvent = remotes:FindFirstChild("BuyTrail") or Instance.new("RemoteEvent")
trailEvent.Name = "BuyTrail"
trailEvent.Parent = remotes

local productToAction = {}
for action, id in pairs(Config.DEVELOPER_PRODUCTS) do
	if typeof(id) == "number" and id > 0 then
		productToAction[id] = action
	end
end

local function dataOf(player)
	return player:FindFirstChild("GameData")
end

local function cashOf(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

local function award(player, action)
	local data = dataOf(player)
	local cash = cashOf(player)
	if not data then return false end

	if action:match("^Treadmill%d+$") then
		local level = tonumber(action:match("%d+$"))
		local speedLevel = data:FindFirstChild("SpeedLevel")
		if not speedLevel or not level or level ~= speedLevel.Value + 1 then return false end
		if level > #Config.TREADMILL_SPEEDS then return false end
		speedLevel.Value = level
		return true
	end

	if action == "SpeedX2" or action == "SpeedX3" or action == "SpeedX4" then
		local multiplier = tonumber(action:sub(6))
		local boost = Config.SPEED_BOOSTS["X" .. multiplier]
		if not boost then return false end
		local expires = player:GetAttribute("SpeedBoostUntil") or 0
		player:SetAttribute("SpeedBoostMultiplier", multiplier)
		player:SetAttribute("SpeedBoostUntil", math.max(os.time(), expires) + boost.duration)
		return true
	end

	if action == "SpeedInstant1M" then
		if not cash then return false end
		cash.Value += Config.INSTANT_SPEED.cash
		return true
	end

	if action:match("^Trail") then
		local trailName = action:sub(6)
		if not Config.TRAILS[trailName] then return false end
		local owned = data:FindFirstChild("OwnedTrails")
		if not owned then
			owned = Instance.new("Folder")
			owned.Name = "OwnedTrails"
			owned.Parent = data
		end
		if not owned:FindFirstChild(trailName) then
			local flag = Instance.new("BoolValue")
			flag.Name = trailName
			flag.Value = true
			flag.Parent = owned
		end
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

boostEvent.OnServerEvent:Connect(function(player, multiplier)
	if typeof(multiplier) ~= "number" then return end
	local key = "X" .. tostring(math.floor(multiplier))
	local boost = Config.SPEED_BOOSTS[key]
	if not boost then return end
	local cash = cashOf(player)
	if not cash then return end
	local cost = boost.robux
	-- Robux purchases are handled through Developer Products; this event only exists for future UI compatibility.
	purchaseEvent:FireClient(player, true, "Use the Robux purchase button for " .. key)
end)

trailEvent.OnServerEvent:Connect(function(player, trailName)
	if typeof(trailName) ~= "string" then return end
	local cfg = Config.TRAILS[trailName]
	if not cfg then return end
	local cash = cashOf(player)
	local data = dataOf(player)
	if not cash or not data then return end
	local owned = data:FindFirstChild("OwnedTrails")
	if not owned then
		owned = Instance.new("Folder")
		owned.Name = "OwnedTrails"
		owned.Parent = data
	end
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
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local action = productToAction[receiptInfo.ProductId]
	if not action then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if award(player, action) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
