-- StealSystem.server.lua
-- Server-side hooks for stealing outside the Safe Zone.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remoteFolder.Name = "GameRemotes"
remoteFolder.Parent = ReplicatedStorage

local stealEvent = remoteFolder:FindFirstChild("StealAttempt") or Instance.new("RemoteEvent")
stealEvent.Name = "StealAttempt"
stealEvent.Parent = remoteFolder

local cooldown = {}
local COOLDOWN = 2

local function inSafeZone(player)
	local data = player:FindFirstChild("GameData")
	local zone = data and data:FindFirstChild("Zone")
	return zone and zone.Value <= 1
end

stealEvent.OnServerEvent:Connect(function(player, target)
	if typeof(target) ~= "Instance" or not target:IsA("Player") then return end
	if target == player or inSafeZone(player) then return end
	if cooldown[player] and os.clock() - cooldown[player] < COOLDOWN then return end
	cooldown[player] = os.clock()

	-- Theft resolution will be expanded when the cage/inventory system is added.
	local targetData = target:FindFirstChild("GameData")
	local playerData = player:FindFirstChild("GameData")
	if not targetData or not playerData then return end

	local cage = targetData:FindFirstChild("CageLevel")
	local aura = playerData:FindFirstChild("AuraLevel")
	if cage and aura and aura.Value > 0 then
		cage.Value = math.max(1, cage.Value - 1)
	end
end)
