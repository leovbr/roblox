-- EggSystem.server.lua
-- Eggs have independent random sizes, size-based hatch times, zone progression, and special rarity events.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

local function rarityColor(tier)
	return Config.RARITY_COLORS[tier] or Color3.new(1,1,1)
end

local function randomSize()
	local names = {"Tiny","Small","Medium","Large","SuperBig"}
	local name = names[rng:NextInteger(1,#names)]
	local cfg = Config.EGG_SIZES[name]
	return name, rng:NextNumber(cfg.min, cfg.max)
end

local function hatchSeconds(zone, sizeName)
	if zone >= 6 and sizeName == "SuperBig" then
		return Config.SUPERBIG_LATE_ZONE_SECONDS
	end
	local size = Config.EGG_SIZES[sizeName]
	local seconds = Config.BASE_HATCH_SECONDS * (Config.ZONE_HATCH_MULTIPLIER ^ math.max(0, zone - 1)) * size.hatchMultiplier
	return math.min(seconds, Config.SUPERBIG_LATE_ZONE_SECONDS)
end

local function rollTier(zone)
	if zone <= 5 then
		local r = rng:NextNumber(0,100)
		if r < 50 then return "Common" end
		if r < 80 then return "Uncommon" end
		if r < 94 then return "Rare" end
		if r < 99 then return "Epic" end
		return "Legendary"
	end
	local r = rng:NextNumber(0,100)
	if zone >= 7 and r < 0.5 then return "Divine" end
	if r < 2 then return "Secret" end
	if r < 6 then return "Mythic" end
	if r < 12 then return "Legendary" end
	if r < 30 then return "Epic" end
	if r < 58 then return "Rare" end
	if r < 80 then return "Uncommon" end
	return "Common"
end

local function pickCreature(zone)
	local data = Config.ZONES[zone]
	local creatures = data.creatures
	return creatures[rng:NextInteger(1,#creatures)]
end

local function addRarityEffects(egg, tier)
	if tier ~= "Mythic" and tier ~= "Secret" and tier ~= "Divine" then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = rarityColor(tier)
	highlight.FillTransparency = 0.3
	highlight.OutlineColor = rarityColor(tier)
	highlight.OutlineTransparency = 0
	highlight.Parent = egg
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = tier == "Divine" and 18 or 10
	emitter.Lifetime = NumberRange.new(0.7,1.4)
	emitter.Speed = NumberRange.new(1,3)
	emitter.SpreadAngle = Vector2.new(360,360)
	emitter.LightEmission = 1
	emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.18),NumberSequenceKeypoint.new(1,0)})
	emitter.Color = ColorSequence.new(rarityColor(tier))
	emitter.Parent = egg
	TweenService:Create(egg, TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true), {Size = egg.Size * 1.08}):Play()
end

local function makeEggBillboard(egg, tier, zone, sizeName, duration)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220,80)
	gui.StudsOffset = Vector3.new(0,5,0)
	gui.AlwaysOnTop = true
	gui.Parent = egg
	local label = Instance.new("TextLabel")
	label.Name = "Info"
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = rarityColor(tier)
	label.TextStrokeTransparency = 0.25
	label.Text = string.format("%s • %s\nHatch: %s", tier, sizeName, duration >= 3600 and "1h" or (duration < 60 and (duration.."s") or (math.floor(duration/60).."m")))
	label.Parent = gui
	return label
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
		hatchResult:FireClient(player,false,"Cage penuh. Upgrade slot dulu!")
		return
	end
	local eggZone = egg:GetAttribute("Zone") or 1
	if playerZone.Value < eggZone then
		hatchResult:FireClient(player,false,"Zone ini belum terbuka!")
		return
	end
	local cost = egg:GetAttribute("HatchCost") or (25 + ((eggZone - 1) * 25))
	if cash.Value < cost then
		hatchResult:FireClient(player,false,"Cash belum cukup: $"..cost)
		return
	end
	egg:SetAttribute("Busy",true)
	cash.Value -= cost
	local tier = egg:GetAttribute("Tier") or "Common"
	local creature = pickCreature(eggZone)
	local sizeName = egg:GetAttribute("SizeName") or "Small"
	local duration = egg:GetAttribute("HatchSeconds") or 5
	local label = egg:FindFirstChild("HatchInfo",true)
	local remaining = duration
	while remaining > 0 and egg.Parent do
		task.wait(1)
		local speed = Workspace:GetAttribute("IsNight") and Config.NIGHT_HATCH_MULTIPLIER or 1
		remaining = math.max(0, remaining - speed)
		if label and label:IsA("TextLabel") then
			label.Text = string.format("%s • %s\n%s", tier, sizeName, remaining <= 0 and "HATCHING!" or ("Hatch: " .. (remaining >= 3600 and "1h" or (remaining >= 60 and (math.floor(remaining/60).."m") or (math.ceil(remaining).."s")))))
		end
	end
	if not egg.Parent then return end
	local brainrot = Instance.new("StringValue")
	brainrot.Name = tier .. "_" .. creature:gsub("%s+","_") .. "_" .. tostring(math.floor(os.clock()*1000))
	brainrot.Value = creature
	brainrot:SetAttribute("Tier",tier)
	brainrot:SetAttribute("Income",Config.EGG_TIERS[tier].income)
	brainrot:SetAttribute("Zone",eggZone)
	brainrot:SetAttribute("Habitat",Config.ZONES[eggZone].habitat)
	brainrot:SetAttribute("EggColor",rarityColor(tier))
	brainrot:SetAttribute("EggSize",egg:GetAttribute("EggSize") or 5)
	brainrot:SetAttribute("SizeName",sizeName)
	brainrot.Parent = brainrots
	hatchResult:FireClient(player,true,tier.." "..creature.." hatched!")
	egg:Destroy()
end

local function spawnEgg(zone,index,tierOverride)
	local zoneData = Config.ZONES[zone]
	local tier = tierOverride or ({"Common","Uncommon","Rare","Epic","Legendary"})[math.clamp(index,1,5)]
	local sizeName, eggHeight = randomSize()
	local eggWidth = eggHeight * rng:NextNumber(0.68,0.88)
	local eggDepth = eggWidth * rng:NextNumber(0.90,1.10)
	local centerX = (zone-1)*78
	local egg = Instance.new("Part")
	egg.Name = string.format("Zone%d_%sEgg%d",zone,zoneData.habitat,index)
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(eggWidth,eggHeight,eggDepth)
	egg.Anchored = true
	egg.CanCollide = false
	egg.Position = Vector3.new(centerX+(index-3)*10,5+eggHeight*0.2,25)
	egg.Color = rarityColor(tier)
	egg.Material = (tier == "Mythic" or tier == "Secret" or tier == "Divine") and Enum.Material.Neon or Enum.Material.SmoothPlastic
	egg:SetAttribute("Zone",zone)
	egg:SetAttribute("Habitat",zoneData.habitat)
	egg:SetAttribute("Tier",tier)
	egg:SetAttribute("EggSize",eggHeight)
	egg:SetAttribute("SizeName",sizeName)
	egg:SetAttribute("HatchSeconds",hatchSeconds(zone,sizeName))
	egg:SetAttribute("HatchCost",25+((zone-1)*25))
	egg:SetAttribute("CreaturePool",table.concat(zoneData.creatures,", "))
	egg.Parent = eggFolder
	local highlight = Instance.new("Highlight")
	highlight.FillColor = zoneData.color
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = rarityColor(tier)
	highlight.OutlineTransparency = 0.1
	highlight.Parent = egg
	local duration = egg:GetAttribute("HatchSeconds")
	local label = makeEggBillboard(egg,tier,zone,sizeName,duration)
	label.Name = "HatchInfo"
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Hatch $"..egg:GetAttribute("HatchCost")
	prompt.ObjectText = tier.." Egg • "..sizeName
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = egg
	prompt.Triggered:Connect(function(player) hatchEgg(player,egg) end)
	addRarityEffects(egg,tier)
end

for zone=1,Config.TOTAL_ZONES do
	for index=1,Config.EGGS_PER_ZONE do spawnEgg(zone,index) end
end

-- One mystery egg is rolled immediately, then a new mystery egg appears every 10 minutes in Zones 4-7.
local function spawnMysteryEgg()
	local zone = rng:NextInteger(4,7)
	local roll = rng:NextNumber()
	local tier = roll < 0.55 and "Mythic" or (roll < 0.97 and "Secret" or "Divine")
	spawnEgg(zone,6,tier)
	local egg = eggFolder:FindFirstChild(string.format("Zone%d_%sEgg6",zone,Config.ZONES[zone].habitat))
	if egg then egg:SetAttribute("MysteryEgg",true) end
end
spawnMysteryEgg()
task.spawn(function()
	while true do
		task.wait(Config.SPECIAL_RESPAWN_SECONDS)
		spawnMysteryEgg()
	end
end)

print("EggSystem loaded: size-based hatch timers, 30x night hatch, Zones 1-5 Common/Uncommon/Rare/Epic/Legendary, and 10-minute mystery eggs in Zones 4-7.")
