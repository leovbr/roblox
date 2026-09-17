-- BrainrotSystem.server.lua
-- Turns hatched Brainrot StringValues into visible 3D creatures inside the owner's enclosure.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.GameConfig)

local brainrotWorld = Workspace:FindFirstChild("Brainrots")
if brainrotWorld then brainrotWorld:Destroy() end
brainrotWorld = Instance.new("Folder")
brainrotWorld.Name = "Brainrots"
brainrotWorld.Parent = Workspace

local TIER_COLOR = {
	Common = Color3.fromRGB(190,190,190), Rare = Color3.fromRGB(70,150,255), Epic = Color3.fromRGB(190,70,255),
	Legendary = Color3.fromRGB(255,170,45), Mythic = Color3.fromRGB(255,60,100), Secret = Color3.fromRGB(255,225,70)
}

local function findBase(id)
	local bases = Workspace:FindFirstChild("Bases")
	return bases and bases:FindFirstChild("Base_" .. tostring(id))
end

local function freeSlot(base)
	local slots = base and base:FindFirstChild("BrainrotEnclosures")
	if not slots then return end
	for _, slot in ipairs(slots:GetChildren()) do
		if slot:GetAttribute("Occupied") ~= true then return slot end
	end
end

local function makePart(model, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Anchored = true; p.CanCollide = false
	p.Color = color; p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Parent = model
	return p
end

local function buildCreature(valueObject, slot)
	local player = Players:GetPlayerFromCharacter(slot.Parent.Parent.Parent)
	local base = slot.Parent.Parent
	local worldBase = findBase(base:GetAttribute("BaseId"))
	if not worldBase then return end
	local pos = slot.Position + Vector3.new(0, 2, 0)
	local tier = valueObject:GetAttribute("Tier") or "Common"
	local habitat = valueObject:GetAttribute("Habitat") or "Forest"
	local zone = tonumber(valueObject:GetAttribute("Zone")) or 1
	local info = Config.ZONES[zone] or Config.ZONES[1]
	local model = Instance.new("Model")
	model.Name = valueObject.Name
	model:SetAttribute("OwnerUserId", player and player.UserId or worldBase:GetAttribute("OwnerUserId") or 0)
	model:SetAttribute("BrainrotId", valueObject.Name)
	model:SetAttribute("Tier", tier)
	model:SetAttribute("SafeZone", true)
	model.Parent = brainrotWorld

	local scale = tonumber(valueObject:GetAttribute("DisplayScale")) or Random.new():NextNumber(0.75, 1.35)
	valueObject:SetAttribute("DisplayScale", scale)
	local bodyColor = info.color
	local accent = TIER_COLOR[tier] or bodyColor
	local body = makePart(model, "Body", Vector3.new(2.4, 2.6, 2.0) * scale, CFrame.new(pos), bodyColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	local head = makePart(model, "Head", Vector3.new(2.2, 2.0, 2.0) * scale, CFrame.new(pos + Vector3.new(0, 1.65 * scale, -0.05)), bodyColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "EyeL", Vector3.new(.32,.42,.18) * scale, CFrame.new(pos + Vector3.new(-.45*scale,1.8*scale,-.95*scale)), accent, Enum.Material.Neon, Enum.PartType.Ball)
	makePart(model, "EyeR", Vector3.new(.32,.42,.18) * scale, CFrame.new(pos + Vector3.new(.45*scale,1.8*scale,-.95*scale)), accent, Enum.Material.Neon, Enum.PartType.Ball)
	makePart(model, "FootL", Vector3.new(.75,.35,.9) * scale, CFrame.new(pos + Vector3.new(-.65*scale,-1.25*scale,-.1)), accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "FootR", Vector3.new(.75,.35,.9) * scale, CFrame.new(pos + Vector3.new(.65*scale,-1.25*scale,-.1)), accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)

	local highlight = Instance.new("Highlight")
	highlight.FillColor = accent; highlight.FillTransparency = tier == "Secret" and .35 or .7
	highlight.OutlineColor = accent; highlight.OutlineTransparency = .05; highlight.Parent = model
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Info"; billboard.Size = UDim2.fromOffset(180,55); billboard.StudsOffset = Vector3.new(0,3.2,0); billboard.AlwaysOnTop = true; billboard.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1); label.BackgroundTransparency = 1; label.Text = tier .. " • " .. valueObject.Value .. "\n+$" .. tostring(valueObject:GetAttribute("Income") or 0) .. "/s"; label.TextColor3 = accent; label.TextStrokeTransparency = .35; label.Font = Enum.Font.GothamBold; label.TextScaled = true; label.Parent = billboard

	slot:SetAttribute("Occupied", true); slot:SetAttribute("BrainrotId", valueObject.Name)
	valueObject:SetAttribute("Slot", slot:GetAttribute("Slot"))
	valueObject:SetAttribute("BaseId", base:GetAttribute("BaseId"))
	valueObject:GetPropertyChangedSignal("Parent"):Connect(function()
		if not valueObject.Parent then
			if slot.Parent then slot:SetAttribute("Occupied", false); slot:SetAttribute("BrainrotId", nil) end
			if model.Parent then model:Destroy() end
		end
	end)
end

local function placeBrainrot(player, b)
	local data = player:FindFirstChild("GameData")
	local baseId = data and data:FindFirstChild("BaseId")
	if not baseId or baseId.Value == 0 then return end
	local base = findBase(baseId.Value)
	local slots = base and base:FindFirstChild("BrainrotEnclosures")
	if not slots then return end
	for _, old in ipairs(slots:GetChildren()) do
		if old:GetAttribute("BrainrotId") == b.Name then old:SetAttribute("Occupied", false); old:SetAttribute("BrainrotId", nil) end
	end
	local preferred = b:GetAttribute("Slot") and slots:FindFirstChild("Enclosure_" .. tostring(b:GetAttribute("Slot")))
	local slot = preferred and preferred:GetAttribute("Occupied") ~= true and preferred or freeSlot(base)
	if slot then buildCreature(b, slot) else warn("No enclosure slot for " .. b.Name .. " owned by " .. player.Name) end
end

local function watchPlayer(player)
	local data = player:WaitForChild("GameData", 15)
	if not data then return end
	local brainrots = data:WaitForChild("Brainrots", 15)
	if not brainrots then return end
	brainrots.ChildAdded:Connect(function(b) task.wait(.1); placeBrainrot(player, b) end)
	for _, b in ipairs(brainrots:GetChildren()) do task.defer(placeBrainrot, player, b) end
end

Players.PlayerAdded:Connect(watchPlayer)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(watchPlayer, p) end
Players.PlayerRemoving:Connect(function(player)
	for _, model in ipairs(brainrotWorld:GetChildren()) do
		if model:GetAttribute("OwnerUserId") == player.UserId then model:Destroy() end
	end
end)

print("BrainrotSystem loaded: visible creature models + 5-slot enclosure placement.")
