-- BaseSystem.server.lua
-- Creates 5 claimable player plots with fences, displays and safe-zone attributes.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.GameConfig)

local basesFolder = Workspace:FindFirstChild("Bases")
if basesFolder then
	basesFolder:Destroy()
end
basesFolder = Instance.new("Folder")
basesFolder.Name = "Bases"
basesFolder.Parent = Workspace

local BASES = {
	{color = Color3.fromRGB(70, 190, 85), accent = Color3.fromRGB(150, 255, 100), material = Enum.Material.Grass, name = "Forest Base"},
	{color = Color3.fromRGB(45, 150, 220), accent = Color3.fromRGB(120, 235, 255), material = Enum.Material.Sand, name = "Ocean Base"},
	{color = Color3.fromRGB(225, 75, 35), accent = Color3.fromRGB(255, 190, 50), material = Enum.Material.Slate, name = "Lava Base"},
	{color = Color3.fromRGB(150, 95, 230), accent = Color3.fromRGB(230, 150, 255), material = Enum.Material.Glass, name = "Crystal Base"},
	{color = Color3.fromRGB(245, 190, 55), accent = Color3.fromRGB(255, 245, 150), material = Enum.Material.Marble, name = "Golden Base"},
}

local positions = {
	Vector3.new(-72, 2, -52),
	Vector3.new(72, 2, -52),
	Vector3.new(-82, 2, 48),
	Vector3.new(0, 2, 76),
	Vector3.new(82, 2, 48),
}

local SIZE = Vector3.new(48, 1, 38)
local WALL_HEIGHT = 5
local WALL_THICKNESS = 1
local claims = {}

local function makePart(parent, name, size, position, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	p.Parent = parent
	return p
end

local function textSign(parent, text, position, color)
	local sign = makePart(parent, "Sign", Vector3.new(12, 4, 0.5), position, Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = true
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

local function buildBase(id, info, center)
	local model = Instance.new("Model")
	model.Name = "Base_" .. id
	model:SetAttribute("BaseId", id)
	model:SetAttribute("OwnerUserId", 0)
	model:SetAttribute("OwnerName", "Unclaimed")
	model:SetAttribute("SafeZone", true)
	model.Parent = basesFolder

	makePart(model, "Floor", SIZE, center, info.color, info.material)

	makePart(model, "BackFence", Vector3.new(SIZE.X, WALL_HEIGHT, WALL_THICKNESS), center + Vector3.new(0, WALL_HEIGHT / 2, SIZE.Z / 2), info.accent, Enum.Material.Wood)
	makePart(model, "LeftFence", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, SIZE.Z), center + Vector3.new(-SIZE.X / 2, WALL_HEIGHT / 2, 0), info.accent, Enum.Material.Wood)
	makePart(model, "RightFence", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, SIZE.Z), center + Vector3.new(SIZE.X / 2, WALL_HEIGHT / 2, 0), info.accent, Enum.Material.Wood)
	makePart(model, "FrontFenceLeft", Vector3.new(15, WALL_HEIGHT, WALL_THICKNESS), center + Vector3.new(-16.5, WALL_HEIGHT / 2, -SIZE.Z / 2), info.accent, Enum.Material.Wood)
	makePart(model, "FrontFenceRight", Vector3.new(15, WALL_HEIGHT, WALL_THICKNESS), center + Vector3.new(16.5, WALL_HEIGHT / 2, -SIZE.Z / 2), info.accent, Enum.Material.Wood)

	local claimPad = makePart(model, "ClaimPad", Vector3.new(12, 0.5, 7), center + Vector3.new(0, 0.8, -13), info.accent, Enum.Material.Neon)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ClaimPrompt"
	prompt.ActionText = "Claim Base"
	prompt.ObjectText = info.name
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = claimPad

	local ownerSign = makePart(model, "OwnerSign", Vector3.new(18, 5, 0.5), center + Vector3.new(0, 7, SIZE.Z / 2 + 0.4), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = true
	gui.Parent = ownerSign
	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Name = "OwnerLabel"
	ownerLabel.Size = UDim2.fromScale(1, 1)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.Text = "CLAIM!"
	ownerLabel.TextColor3 = info.accent
	ownerLabel.TextScaled = true
	ownerLabel.Font = Enum.Font.GothamBlack
	ownerLabel.Parent = gui

	local slots = Instance.new("Folder")
	slots.Name = "BrainrotEnclosures"
	slots.Parent = model
	for slot = 1, Config.STARTING_EGG_SLOTS do
		local x = ((slot - 3) * 7)
		local enclosure = makePart(slots, "Enclosure_" .. slot, Vector3.new(6, 0.35, 6), center + Vector3.new(x, 1, 4), info.accent, Enum.Material.SmoothPlastic)
		enclosure:SetAttribute("Slot", slot)
		enclosure:SetAttribute("Occupied", false)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "BaseSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = center + Vector3.new(0, 1, -6)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Transparency = 0.65
	spawn.Color = info.accent
	spawn.Parent = model

	textSign(model, "SAFE ZONE", center + Vector3.new(0, 3.5, -SIZE.Z / 2 - 1), info.accent)

	claims[id] = {model = model, prompt = prompt, label = ownerLabel, spawn = spawn}

	prompt.Triggered:Connect(function(player)
		local data = player:FindFirstChild("GameData")
		local baseId = data and data:FindFirstChild("BaseId")
		if not baseId or baseId.Value ~= 0 then return end
		if model:GetAttribute("OwnerUserId") ~= 0 then return end

		baseId.Value = id
		model:SetAttribute("OwnerUserId", player.UserId)
		model:SetAttribute("OwnerName", player.Name)
		ownerLabel.Text = player.Name .. "'S BASE"
		prompt.Enabled = false
		spawn.Neutral = false
		spawn.Enabled = true
		player.RespawnLocation = spawn

		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character:PivotTo(spawn.CFrame + Vector3.new(0, 4, 0))
		end
	end)
end

for id = 1, Config.BASE_COUNT do
	buildBase(id, BASES[id], positions[id])
end

local function releaseBase(player)
	local data = player:FindFirstChild("GameData")
	local baseId = data and data:FindFirstChild("BaseId")
	if not baseId or baseId.Value == 0 then return end

	local claim = claims[baseId.Value]
	if claim and claim.model then
		claim.model:SetAttribute("OwnerUserId", 0)
		claim.model:SetAttribute("OwnerName", "Unclaimed")
		claim.label.Text = "CLAIM!"
		claim.prompt.Enabled = true
		claim.spawn.Neutral = true
		claim.spawn.Enabled = false
	end
	baseId.Value = 0
end

Players.PlayerRemoving:Connect(releaseBase)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		local data = player:FindFirstChild("GameData")
		local baseId = data and data:FindFirstChild("BaseId")
		if baseId and baseId.Value ~= 0 and claims[baseId.Value] then
			local spawn = claims[baseId.Value].spawn
			character:PivotTo(spawn.CFrame + Vector3.new(0, 4, 0))
		end
	end)
end)

print("BaseSystem loaded: 5 claimable bases with fenced brainrot enclosures.")
