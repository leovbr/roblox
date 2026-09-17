-- TreadmillSystem.server.lua
local Players = game:GetService("Players")
local Config = require(script.Parent.GameConfig)

local function getSpeed(player)
	local data = player:FindFirstChild("GameData")
	local level = data and data:FindFirstChild("SpeedLevel")
	local base = Config.TREADMILL_SPEEDS[1]
	if level then base = Config.TREADMILL_SPEEDS[math.clamp(level.Value, 1, #Config.TREADMILL_SPEEDS)] end
	local multiplierValue = data and data:FindFirstChild("SpeedMultiplier")
	local multiplier = multiplierValue and multiplierValue.Value or (player:GetAttribute("SpeedBoostMultiplier") or 1)
	return base * math.max(1, multiplier)
end

local function applySpeed(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = getSpeed(player)
end

local function hook(player)
	player.CharacterAdded:Connect(function(character) applySpeed(player, character) end)
	local data = player:FindFirstChild("GameData")
	local multiplier = data and data:FindFirstChild("SpeedMultiplier")
	if multiplier then
		multiplier.Changed:Connect(function(value)
			player:SetAttribute("SpeedBoostMultiplier", value)
			if player.Character then applySpeed(player, player.Character) end
		end)
	end
	if player.Character then applySpeed(player, player.Character) end
end

Players.PlayerAdded:Connect(function(player) task.defer(hook, player) end)
for _, player in ipairs(Players:GetPlayers()) do task.defer(hook, player) end
