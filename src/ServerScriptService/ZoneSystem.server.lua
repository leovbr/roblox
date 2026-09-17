-- ZoneSystem.server.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.GameConfig)

local TOTAL_ZONES = Config.TOTAL_ZONES
local ZONE_DISTANCE = 90
local REQUIREMENT_PER_ZONE = 100
local folder = Workspace:FindFirstChild("Zones") or Instance.new("Folder")
folder.Name = "Zones"; folder.Parent = Workspace

for zone=1,TOTAL_ZONES do
	local existing=folder:FindFirstChild("Zone_"..zone)
	if not existing then existing=Instance.new("Model");existing.Name="Zone_"..zone;existing.Parent=folder end
	local cfg=Config.ZONES[zone]
	existing:SetAttribute("RequiredCash",math.max(0,(zone-1)*REQUIREMENT_PER_ZONE))
	existing:SetAttribute("ZoneType",zone>=7 and "MythicSecret" or(zone>=5 and "Special" or "Normal"))
	existing:SetAttribute("RecommendedSpeed",cfg and cfg.recommendedSpeed or 5)
	existing:SetAttribute("GuardianPressureSpeed",cfg and cfg.recommendedSpeed or 5)
end

local function updateZone(player)
	local data=player:FindFirstChild("GameData");local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not data or not root then return end
	local zoneValue=data:FindFirstChild("Zone");if not zoneValue then return end
	zoneValue.Value=math.clamp(math.floor((root.Position.Z+ZONE_DISTANCE*2)/ZONE_DISTANCE)+1,1,TOTAL_ZONES)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.spawn(function()while character.Parent and player.Parent do updateZone(player);task.wait(1)end end)
	end)
end)
