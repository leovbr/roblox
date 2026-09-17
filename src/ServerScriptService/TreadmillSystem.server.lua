-- TreadmillSystem.server.lua
local Players = game:GetService("Players")
local Config = require(script.Parent.GameConfig)

local function getSpeed(player)
	local data=player:FindFirstChild("GameData")
	local level=data and data:FindFirstChild("SpeedLevel")
	local base=Config.TREADMILL_SPEEDS[math.clamp(level and level.Value or 1,1,#Config.TREADMILL_SPEEDS)] or Config.TREADMILL_SPEEDS[1]
	local multiplierValue=data and data:FindFirstChild("SpeedMultiplier")
	local permanent=multiplierValue and multiplierValue.Value or (player:GetAttribute("SpeedBoostMultiplier") or 1)
	local admin=tonumber(player:GetAttribute("AdminSpeedMultiplier")) or 1
	return base*math.max(1,permanent)*math.max(1,admin)
end

local function applySpeed(player,character)
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed=getSpeed(player) end
end

local function hook(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		applySpeed(player,character)
	end)

	local data=player:FindFirstChild("GameData")
	local multiplier=data and data:FindFirstChild("SpeedMultiplier")
	if multiplier then
		multiplier.Changed:Connect(function(value)
			player:SetAttribute("SpeedBoostMultiplier",value)
			applySpeed(player,player.Character)
		end)
	end

	player:GetAttributeChangedSignal("AdminSpeedMultiplier"):Connect(function()
		applySpeed(player,player.Character)
	end)
	player:GetAttributeChangedSignal("SpeedBoostMultiplier"):Connect(function()
		applySpeed(player,player.Character)
	end)
	applySpeed(player,player.Character)
end

Players.PlayerAdded:Connect(function(player)task.defer(hook,player)end)
for _,player in ipairs(Players:GetPlayers())do task.defer(hook,player)end
