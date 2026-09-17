-- EggSystem.server.lua
-- Habitat-aware eggs: size is randomized independently from tier, while hatch results come from the zone habitat.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.GameConfig)
local rng = Random.new()

local eggFolder = Workspace:FindFirstChild("Eggs") or Instance.new("Folder")
eggFolder.Name = "Eggs"
eggFolder.Parent = Workspace
eggFolder:ClearAllChildren()

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local hatchResult = remotes:FindFirstChild("HatchResult") or Instance.new("RemoteEvent")
hatchResult.Name = "HatchResult"
hatchResult.Parent = remotes

local TIER_COLORS = {
	Common = Color3.fromRGB(185, 185, 185),
	Rare = Color3.fromRGB(65, 145, 255),
	Epic = Color3.fromRGB(190, 75, 255),
	Legendary = Color3.fromRGB(255, 170, 45),
	Mythic = Color3.fromRGB(255, 55, 95),
	Secret = Color3.fromRGB(255, 230, 80),
}

local function rollTier(zone)
	local roll = rng:NextNumber(0, 100)
	if zone >= Config.SECRET_ZONE_MIN and roll <= 0.1 then return "Secret" end
	if zone >= Config.MYTHIC_ZONE_MIN and roll <= 1 then return "Mythic" end
	if zone >= Config.SPECIAL_ZONE_MIN and roll <= 5 then return "Legendary" end
	if roll <= 15 then return "Epic" end
	if roll <= 40 then return "Rare" end
	return "Common"
end

local function pickCreature(zone)
	local habitat = Config.ZONES[zone]
	local creatures = habitat.creatures
	return creatures[rng:NextInteger(1, #creatures)]
end

local function hatchEgg(player, egg)
	if egg:GetAttribute("Busy") then return end

	local data = player:FindFirstChild("GameData")
	local stats = player:FindFirstChild("leaderstats")
	local brainrots = data and data:FindFirstChild("Brainrots")
	local cash = stats and stats:FindFirstChild("Cash")
	local slots = data and data:FindFirstChild("EggSlots")
	local playerZone = data and data:FindFirstChild("Zone")
	if not data or not stats or not brainrots or not cash or not slots or not playerZone then return end

	if #brainrots:GetChildren() >= slots.Value then
		hatchResult:FireClient(player, false, "Cage penuh. Upgrade slot dulu!")
		return
	end

	local eggZone = egg:GetAttribute("Zone") or 1
	if playerZone.Value < eggZone then
		hatchResult:FireClient(player, false, "Zone ini belum terbuka!")
		return
	end

	local cost = 25 + ((eggZone - 1) * 25)
	if cash.Value < cost then
		hatchResult:FireClient(player, false, "Cash belum cukup: $" .. cost)
		return
	end

	egg:SetAttribute("Busy", true)
	cash.Value -= cost

	local tier = rollTier(eggZone)
	local creature = pickCreature(eggZone)
	local brainrot = Instance.new("StringValue")
	brainrot.Name = tier .. "_" .. creature:gsub("%s+", "_") .. "_" .. tostring(math.floor(os.clock() * 1000))
	brainrot.Value = creature
	brainrot:SetAttribute("Tier", tier)
	brainrot:SetAttribute("Income", Config.EGG_TIERS[tier].income)
	brainrot:SetAttribute("Zone", eggZone)
	brainrot:SetAttribute("Habitat", Config.ZONES[eggZone].habitat)
	brainrot:SetAttribute("EggColor", TIER_COLORS[tier])
	brainrot.Parent = brainrots

	hatchResult:FireClient(player, true, tier .. " " .. creature)

	task.delay(3, function()
		if egg.Parent then egg:SetAttribute("Busy", false) end
	end)
end

local function spawnEgg(zone, index)
	local zoneData = Config.ZONES[zone]
	local tierVisual = ({"Common", "Rare", "Epic", "Legendary", "Mythic"})[math.clamp(index, 1, 5)]

	-- Egg size is completely independent from rarity/tier.
	-- Every egg can randomly be tiny, small, medium, large, or huge.
	local eggHeight = rng:NextNumber(3.2, 8.5)
	local eggWidth = eggHeight * rng:NextNumber(0.68, 0.88)
	local eggDepth = eggWidth * rng:NextNumber(0.90, 1.10)

	local centerX = (zone - 1) * 78
	local egg = Instance.new("Part")
	egg.Name = string.format("Zone%d_%sEgg%d", zone, zoneData.habitat, index)
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(eggWidth, eggHeight, eggDepth)
	egg.Anchored = true
	egg.CanCollide = false
	egg.Position = Vector3.new(centerX + (index - 3) * 10, 5.0 + eggHeight * 0.2, 25)
	egg.Color = TIER_COLORS[tierVisual]
	egg.Material = tierVisual == "Mythic" and Enum.Material.Neon or Enum.Material.SmoothPlastic
	egg:SetAttribute("Zone", zone)
	egg:SetAttribute("Habitat", zoneData.habitat)
	egg:SetAttribute("Tier", tierVisual)
	egg:SetAttribute("EggSize", eggHeight)
	egg:SetAttribute("CreaturePool", table.concat(zoneData.creatures, ", "))
	egg.Parent = eggFolder

	local highlight = Instance.new("Highlight")
	highlight.FillColor = zoneData.color
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = TIER_COLORS[tierVisual]
	highlight.OutlineTransparency = 0.1
	highlight.Parent = egg

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Hatch $" .. (25 + ((zone - 1) * 25))
	prompt.ObjectText = tierVisual .. " Egg • " .. zoneData.habitat
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = egg
	prompt.Triggered:Connect(function(player)
		hatchEgg(player, egg)
	end)
end

for zone = 1, Config.TOTAL_ZONES do
	for index = 1, Config.EGGS_PER_ZONE do
		spawnEgg(zone, index)
	end
end

print("EggSystem loaded: 60 habitat-specific eggs with randomized sizes independent of tier.")
