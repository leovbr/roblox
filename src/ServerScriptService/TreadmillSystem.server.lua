-- TreadmillSystem.server.lua
local Players = game:GetService("Players")
local Config = require(script.Parent.GameConfig)

local function getSpeed(player)
	local data = player:FindFirstChild("GameData")
	local level = data and data:FindFirstChild("SpeedLevel")
	if not level then return Config.TREADMILL_SPEEDS[1] end
	return Config.TREADMILL_SPEEDS[math.clamp(level.Value, 1, #Config.TREADMILL_SPEEDS)]
end

local function applySpeed(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = getSpeed(player)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		applySpeed(player, character)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then applySpeed(player, player.Character) end
end
