-- PlayerData.server.lua
-- Persistent player progression. BaseId is session-only and is never saved.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("CuriBrainrot_PlayerData_v1")

local DEFAULT = {
	Cash = 0,
	Zone = 1,
	SpeedLevel = 1,
	SpeedMultiplier = 1,
	EggSlots = 5,
	AuraLevel = 0,
	CageLevel = 1,
	BaseId = 0,
}

local function makeValue(parent, name, value)
	local v = Instance.new("IntValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function setupPlayer(player)
	if player:FindFirstChild("GameData") then return end
	local stats = Instance.new("Folder"); stats.Name = "leaderstats"; stats.Parent = player
	local cash = makeValue(stats, "Cash", DEFAULT.Cash)
	local data = Instance.new("Folder"); data.Name = "GameData"; data.Parent = player
	for name, value in pairs(DEFAULT) do if name ~= "Cash" then makeValue(data, name, value) end end
	local brainrots = Instance.new("Folder"); brainrots.Name = "Brainrots"; brainrots.Parent = data
	local ownedTrails = Instance.new("Folder"); ownedTrails.Name = "OwnedTrails"; ownedTrails.Parent = data

	local ok, saved = pcall(function() return store:GetAsync("Player_" .. player.UserId) end)
	if ok and type(saved) == "table" then
		cash.Value = tonumber(saved.Cash) or DEFAULT.Cash
		for name, default in pairs(DEFAULT) do
			if name ~= "Cash" and name ~= "BaseId" then
				local value = data:FindFirstChild(name)
				if value then value.Value = tonumber(saved[name]) or default end
			end
		end
		if type(saved.Brainrots) == "table" then
			for _, entry in ipairs(saved.Brainrots) do
				if type(entry) == "table" and entry.Name and entry.Value then
					local b = Instance.new("StringValue"); b.Name = tostring(entry.Name); b.Value = tostring(entry.Value)
					for attr, attrValue in pairs(entry.Attributes or {}) do
						if type(attrValue) == "number" or type(attrValue) == "string" or type(attrValue) == "boolean" then b:SetAttribute(attr, attrValue) end
					end
					b.Parent = brainrots
				end
			end
		end
		if type(saved.OwnedTrails) == "table" then
			for trailName, owned in pairs(saved.OwnedTrails) do
				if owned == true then
					local flag = Instance.new("BoolValue"); flag.Name = tostring(trailName); flag.Value = true; flag.Parent = ownedTrails
				end
			end
		end
		if type(saved.EquippedTrail) == "string" and saved.EquippedTrail ~= "" and ownedTrails:FindFirstChild(saved.EquippedTrail) then
			player:SetAttribute("EquippedTrail", saved.EquippedTrail)
		end
	elseif not ok then
		warn("DataStore load failed for " .. player.Name .. ": " .. tostring(saved))
	end
	player:SetAttribute("SpeedBoostMultiplier", data.SpeedMultiplier.Value)
end

local function serializeBrainrots(brainrots)
	local result = {}
	for _, b in ipairs(brainrots:GetChildren()) do
		local attrs = {}
		for _, attrName in ipairs({"Tier", "Income", "Zone", "Habitat", "EggColor", "DisplayScale", "Slot"}) do
			local value = b:GetAttribute(attrName)
			if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then attrs[attrName] = value end
		end
		result[#result + 1] = {Name = b.Name, Value = b.Value, Attributes = attrs}
	end
	return result
end

local function serializeTrails(ownedTrails)
	local result = {}
	for _, trail in ipairs(ownedTrails:GetChildren()) do if trail:IsA("BoolValue") and trail.Value then result[trail.Name] = true end end
	return result
end

local function savePlayer(player)
	local stats, data = player:FindFirstChild("leaderstats"), player:FindFirstChild("GameData")
	if not stats or not data then return end
	local cash = stats:FindFirstChild("Cash")
	local multiplier = data:FindFirstChild("SpeedMultiplier")
	local payload = {
		Cash = cash and cash.Value or 0,
		Brainrots = serializeBrainrots(data.Brainrots),
		OwnedTrails = serializeTrails(data.OwnedTrails),
		EquippedTrail = player:GetAttribute("EquippedTrail") or "",
	}
	for name, default in pairs(DEFAULT) do
		if name ~= "Cash" and name ~= "BaseId" then
			local value = data:FindFirstChild(name); payload[name] = value and value.Value or default
		end
	end
	payload.SpeedMultiplier = multiplier and multiplier.Value or (player:GetAttribute("SpeedBoostMultiplier") or 1)
	pcall(function() store:SetAsync("Player_" .. player.UserId, payload) end)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(savePlayer)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
game:BindToClose(function() for _, player in ipairs(Players:GetPlayers()) do savePlayer(player) end end)
