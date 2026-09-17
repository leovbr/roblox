-- EggSystem.server.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(script.Parent.GameConfig)

local rng = Random.new()
local eggFolder = Workspace:FindFirstChild("Eggs") or Instance.new("Folder")
eggFolder.Name = "Eggs"
eggFolder.Parent = Workspace

local function rollTier(zone)
	local roll = rng:NextNumber(0, 100)
	if zone >= Config.SECRET_ZONE_MIN and roll <= 0.1 then return "Secret" end
	if zone >= Config.MYTHIC_ZONE_MIN and roll <= 1 then return "Mythic" end
	if zone >= Config.SPECIAL_ZONE_MIN and roll <= 5 then return "Legendary" end
	if roll <= 15 then return "Epic" end
	if roll <= 40 then return "Rare" end
	return "Common"
end

local function spawnEgg(zone, index)
	local egg = Instance.new("Part")
	egg.Name = string.format("Zone%d_Egg%d", zone, index)
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(4, 4, 4)
	egg.Anchored = true
	egg.Position = Vector3.new((index - 3) * 7, 3, -(zone - 1) * 45)
	egg:SetAttribute("Zone", zone)
	egg:SetAttribute("Tier", rollTier(zone))
	egg.Parent = eggFolder
end

for zone = 1, Config.TOTAL_ZONES do
	for index = 1, Config.EGGS_PER_ZONE do
		spawnEgg(zone, index)
	end
end

local function payIncome(player, tier)
	local stats = player:FindFirstChild("leaderstats")
	local cash = stats and stats:FindFirstChild("Cash")
	local info = Config.EGG_TIERS[tier]
	if cash and info then cash.Value += info.income end
end

local function setupEgg(egg)
	egg.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or egg:GetAttribute("Collected") then return end
		egg:SetAttribute("Collected", true)
		payIncome(player, egg:GetAttribute("Tier"))
		egg.Transparency = 1
		egg.CanTouch = false
		task.delay(3, function()
			if egg.Parent then
				egg.Transparency = 0
				egg.CanTouch = true
				egg:SetAttribute("Collected", false)
			end
		end)
	end)
end

for _, egg in ipairs(eggFolder:GetChildren()) do
	setupEgg(egg)
end
