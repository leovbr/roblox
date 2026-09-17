-- TreadmillSystem.server.lua
local Players = game:GetService("Players")
local Config = require(script.Parent.GameConfig)

local function getSpeed(player)
	local data = player:FindFirstChild("GameData")
	local level = data and data:FindFirstChild("SpeedLevel")
	local base = Config.TREADMILL_SPEEDS[1]
	if level then
		base = Config.TREADMILL_SPEEDS[math.clamp(level.Value, 1, #Config.TREADMILL_SPEEDS)]
	end
	local untilTime = player:GetAttribute("SpeedBoostUntil") or 0
	local multiplier = 1
	if untilTime > os.time() then
		multiplier = player:GetAttribute("SpeedBoostMultiplier") or 1
	else
		player:SetAttribute("SpeedBoostMultiplier", 1)
	end
	return base * multiplier
end

local function applySpeed(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = getSpeed(player)
end

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("SpeedBoostMultiplier", 1)
	player:SetAttribute("SpeedBoostUntil", 0)
	player.CharacterAdded:Connect(function(character)
		applySpeed(player, character)
	end)
	player:GetAttributeChangedSignal("SpeedBoostMultiplier"):Connect(function()
		if player.Character then applySpeed(player, player.Character) end
	end)
	player:GetAttributeChangedSignal("SpeedBoostUntil"):Connect(function()
		if player.Character then applySpeed(player, player.Character) end
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player:GetAttribute("SpeedBoostMultiplier") == nil then player:SetAttribute("SpeedBoostMultiplier", 1) end
	if player:GetAttribute("SpeedBoostUntil") == nil then player:SetAttribute("SpeedBoostUntil", 0) end
	if player.Character then applySpeed(player, player.Character) end
end

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				applySpeed(player, player.Character)
			end
		end
	end
end)
