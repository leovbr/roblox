-- EggSystem.server.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.GameConfig)
local rng = Random.new()

local eggFolder = Workspace:FindFirstChild("Eggs") or Instance.new("Folder")
eggFolder.Name = "Eggs"
eggFolder.Parent = Workspace

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local hatchResult = remotes:FindFirstChild("HatchResult") or Instance.new("RemoteEvent")
hatchResult.Name = "HatchResult"
hatchResult.Parent = remotes

local function rollTier(zone)
	local roll = rng:NextNumber(0, 100)
	if zone >= Config.SECRET_ZONE_MIN and roll <= 0.1 then return "Secret" end
	if zone >= Config.MYTHIC_ZONE_MIN and roll <= 1 then return "Mythic" end
	if zone >= Config.SPECIAL_ZONE_MIN and roll <= 5 then return "Legendary" end
	if roll <= 15 then return "Epic" end
	if roll <= 40 then return "Rare" end
	return "Common"
end

local function hatchEgg(player, egg)
	if egg:GetAttribute("Busy") then return end

	local data = player:FindFirstChild("GameData")
	local stats = player:FindFirstChild("leaderstats")
	local brainrots = data and data:FindFirstChild("Brainrots")
	local cash = stats and stats:FindFirstChild("Cash")
	local slots = data and data:FindFirstChild("EggSlots")
	local zone = data and data:FindFirstChild("Zone")
	if not data or not stats or not brainrots or not cash or not slots or not zone then return end
	if #brainrots:GetChildren() >= slots.Value then
		hatchResult:FireClient(player, false, "Cage penuh. Upgrade slot dulu!")
		return
	end

	local eggZone = egg:GetAttribute("Zone") or 1
	if zone.Value < eggZone then
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
	local brainrot = Instance.new("StringValue")
	brainrot.Name = tier .. "_" .. tostring(os.clock()):gsub("%.", "_")
	brainrot.Value = tier
	brainrot:SetAttribute("Income", Config.EGG_TIERS[tier].income)
	brainrot:SetAttribute("Zone", eggZone)
	brainrot.Parent = brainrots

	hatchResult:FireClient(player, true, tier)

	task.delay(3, function()
		if egg.Parent then egg:SetAttribute("Busy", false) end
	end)
end

local function spawnEgg(zone, index)
	local egg = Instance.new("Part")
	egg.Name = string.format("Zone%d_Egg%d", zone, index)
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(4, 4, 4)
	egg.Anchored = true
	egg.Position = Vector3.new((index - 3) * 7, 4, -(zone - 1) * 45)
	egg:SetAttribute("Zone", zone)
	egg:SetAttribute("Tier", "Unknown")
	egg.Parent = eggFolder

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Hatch"
	prompt.ObjectText = "Egg - Zone " .. zone
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = egg
	prompt.Triggered:Connect(function(player)
		hatchEgg(player, egg)
	end)
end

for _, child in ipairs(eggFolder:GetChildren()) do child:Destroy() end
for zone = 1, Config.TOTAL_ZONES do
	for index = 1, Config.EGGS_PER_ZONE do
		spawnEgg(zone, index)
	end
end
