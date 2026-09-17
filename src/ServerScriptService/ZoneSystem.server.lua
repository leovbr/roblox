-- ZoneSystem.server.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local TOTAL_ZONES = 12
local ZONE_DISTANCE = 90
local REQUIREMENT_PER_ZONE = 100

local folder = Workspace:FindFirstChild("Zones") or Instance.new("Folder")
folder.Name = "Zones"
folder.Parent = Workspace

for zone = 1, TOTAL_ZONES do
	local existing = folder:FindFirstChild("Zone_" .. zone)
	if not existing then
		local model = Instance.new("Model")
		model.Name = "Zone_" .. zone
		model:SetAttribute("RequiredCash", math.max(0, (zone - 1) * REQUIREMENT_PER_ZONE))
		model:SetAttribute("ZoneType", zone >= 7 and "MythicSecret" or (zone >= 5 and "Special" or "Normal"))
		model.Parent = folder
	end
end

local function updateZone(player)
	local data = player:FindFirstChild("GameData")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not data or not root then return end

	local zoneValue = data:FindFirstChild("Zone")
	if not zoneValue then return end

	local zone = math.clamp(math.floor((root.Position.Z + ZONE_DISTANCE * 2) / ZONE_DISTANCE) + 1, 1, TOTAL_ZONES)
	zoneValue.Value = zone
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.spawn(function()
			while character.Parent and player.Parent do
				updateZone(player)
				task.wait(1)
			end
		end)
	end)
end)
