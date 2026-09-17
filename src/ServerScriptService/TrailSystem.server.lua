-- TrailSystem.server.lua
local Players = game:GetService("Players")
local Config = require(script.Parent.GameConfig)

local function clearTrail(character)
	local old = character:FindFirstChild("PlayerTrail")
	if old then old:Destroy() end
end

local function applyTrail(player, character)
	clearTrail(character)
	local name = player:GetAttribute("EquippedTrail")
	local cfg = name and Config.TRAILS[name]
	if not cfg then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local a0 = Instance.new("Attachment")
	a0.Name = "TrailAttachment0"
	a0.Position = Vector3.new(-0.7, 0, 0.15)
	a0.Parent = root
	local a1 = Instance.new("Attachment")
	a1.Name = "TrailAttachment1"
	a1.Position = Vector3.new(0.7, 0, 0.15)
	a1.Parent = root

	local trail = Instance.new("Trail")
	trail.Name = "PlayerTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(cfg.color)
	trail.Lifetime = 0.45
	trail.MinLength = 0.1
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, cfg.width),
		NumberSequenceKeypoint.new(0.7, cfg.width * 0.75),
		NumberSequenceKeypoint.new(1, 0),
	})
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Parent = character
end

local function hook(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.wait(0.1)
		applyTrail(player, character)
	end)
	player:GetAttributeChangedSignal("EquippedTrail"):Connect(function()
		if player.Character then applyTrail(player, player.Character) end
	end)
end

Players.PlayerAdded:Connect(hook)
for _, player in ipairs(Players:GetPlayers()) do hook(player) end
