-- GamePassSystem.server.lua
-- Checks permanent Game Pass ownership and applies benefits server-side.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(script.Parent.GameConfig)

local function dataOf(player) return player:FindFirstChild("GameData") end
local function claimFolder(player)
	local data = dataOf(player) if not data then return nil end
	return data:FindFirstChild("PassClaims")
end
local function claimOnce(player, name)
	local folder = claimFolder(player) if not folder then return false end
	if folder:FindFirstChild(name) then return false end
	local flag = Instance.new("BoolValue") flag.Name = name flag.Value = true flag.Parent = folder
	return true
end
local function highestOwned(player, prefix)
	local highest = 0
	for name, id in pairs(Config.GAME_PASSES) do
		local n = tonumber(name:match("^" .. prefix .. "(%d+)$"))
		if n and id > 0 then
			local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) end)
			if ok and owns and n > highest then highest = n end
		end
	end
	return highest
end

local function grant(player, action)
	local data = dataOf(player) if not data then return end
	if action:match("^Treadmill%d+$") then
		local level = tonumber(action:match("%d+$"))
		local speed = data:FindFirstChild("SpeedLevel")
		if speed and level and level > speed.Value then speed.Value = math.min(level, #Config.TREADMILL_SPEEDS) end
		return
	end
	if action:match("^SpeedX%d+$") then
		local mult = tonumber(action:match("%d+$"))
		local stored = data:FindFirstChild("SpeedMultiplier")
		if stored and mult and mult > stored.Value then stored.Value = mult end
		player:SetAttribute("SpeedBoostMultiplier", stored and stored.Value or mult)
		return
	end
	if action:match("^Trail") then
		local name = action:sub(6)
		if Config.TRAILS[name] then
			local owned = data:FindFirstChild("OwnedTrails")
			if owned and not owned:FindFirstChild(name) then local flag = Instance.new("BoolValue"); flag.Name = name; flag.Value = true; flag.Parent = owned end
			player:SetAttribute("EquippedTrail", name)
		end
		return
	end
	if action == "InstantMoney1M" then
		local cash = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash")
		if cash and claimOnce(player, action) then cash.Value += Config.INSTANT_MONEY.cash end
		return
	end
	if action == "SpeedInstant1M" then
		local speed = data:FindFirstChild("SpeedLevel")
		if speed and claimOnce(player, action) then speed.Value = math.min(speed.Value + 1, #Config.TREADMILL_SPEEDS) end
		return
	end
	if action == "MysticEggZone7" then
		local brainrots, slots = data:FindFirstChild("Brainrots"), data:FindFirstChild("EggSlots")
		if not brainrots or not slots or #brainrots:GetChildren() >= slots.Value then return end
		for _, b in ipairs(brainrots:GetChildren()) do if b:GetAttribute("Tier") == "Mystic" and b:GetAttribute("Zone") == 7 then return end end
		local cfg = Config.MYSTIC_EGG_ZONE7
		local b = Instance.new("StringValue")
		b.Name = "Mystic_Celestial_Pink_Dragon_Pass"
		b.Value = cfg.creature
		b:SetAttribute("Tier", cfg.tier)
		b:SetAttribute("Income", cfg.income)
		b:SetAttribute("Zone", cfg.zone)
		b:SetAttribute("Habitat", Config.ZONES[cfg.zone].habitat)
		b:SetAttribute("EggColor", Config.RARITY_COLORS.Mystic)
		b:SetAttribute("SizeName", "SuperBig")
		b.Parent = brainrots
	end
end

local function applyAll(player)
	local data = dataOf(player) if not data then return end
	local bestTreadmill = highestOwned(player, "Treadmill")
	if bestTreadmill > 0 then grant(player, "Treadmill" .. bestTreadmill) end
	local bestSpeed = highestOwned(player, "SpeedX")
	if bestSpeed > 0 then grant(player, "SpeedX" .. bestSpeed) end
	for action, id in pairs(Config.GAME_PASSES) do
		if id > 0 and not action:match("^Treadmill%d+$") and not action:match("^SpeedX%d+$") then
			local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) end)
			if ok and owns then grant(player, action) end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		repeat task.wait() until player:FindFirstChild("GameData")
		applyAll(player)
	end)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if not purchased then return end
	for action, id in pairs(Config.GAME_PASSES) do
		if id == passId then
			grant(player, action)
			break
		end
	end
end)

for _, player in ipairs(Players:GetPlayers()) do task.spawn(function() applyAll(player) end) end

print("GamePassSystem loaded: permanent treadmill, speed, trails, instant upgrades, and Mystic Egg entitlements.")
