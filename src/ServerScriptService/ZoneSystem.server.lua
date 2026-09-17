-- ZoneSystem.server.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.GameConfig)

local TOTAL_ZONES=Config.TOTAL_ZONES
local ZONE_LENGTH=78
local START_X=0
local folder=Workspace:FindFirstChild("Zones") or Instance.new("Folder")
folder.Name="Zones" folder.Parent=Workspace

for zone=1,TOTAL_ZONES do
	local existing=folder:FindFirstChild("Zone_"..zone)
	if not existing then existing=Instance.new("Model") existing.Name="Zone_"..zone existing.Parent=folder end
	local cfg=Config.ZONES[zone]
	existing:SetAttribute("RequiredCash",math.max(0,(zone-1)*100))
	existing:SetAttribute("ZoneType",zone>=7 and "MythicSecret" or (zone>=5 and "Special" or "Normal"))
	existing:SetAttribute("RecommendedSpeed",cfg and cfg.recommendedSpeed or 0)
	existing:SetAttribute("GuardianPressureSpeed",cfg and cfg.recommendedSpeed or 0)
end

local function updateZone(player)
	local data=player:FindFirstChild("GameData")
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not data or not root then return end
	local zoneValue=data:FindFirstChild("Zone") if not zoneValue then return end
	local zone=math.clamp(math.floor((root.Position.X-(START_X-ZONE_LENGTH/2))/ZONE_LENGTH)+1,1,TOTAL_ZONES)
	zoneValue.Value=zone
	local cfg=Config.ZONES[zone]
	player:SetAttribute("ZoneRecommendedSpeed",cfg and cfg.recommendedSpeed or 0)
	player:SetAttribute("GuardianPressureSpeed",cfg and cfg.recommendedSpeed or 0)
	player:SetAttribute("SpeedReadyForZone",(player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 0) >= (cfg and cfg.recommendedSpeed or 0))
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.spawn(function()
			while character.Parent and player.Parent do updateZone(player) task.wait(0.25) end
		end)
	end)
end)

for _,player in ipairs(Players:GetPlayers()) do
	if player.Character then
		task.spawn(function() while player.Character and player.Parent do updateZone(player) task.wait(0.25) end end)
	end
end
