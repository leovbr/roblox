-- TrapSystem.server.lua
-- Each base gets 3 reusable traps. Touching an active trap temporarily stuns an intruder.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TRAPS_PER_BASE = 3
local COOLDOWN = 8
local STUN_TIME = 2

local function getPlayerFromPart(part)
	local model = part and part:FindFirstAncestorOfClass("Model")
	return model and Players:GetPlayerFromCharacter(model)
end
local function setupBase(base)
	local folder = base:FindFirstChild("Traps") or Instance.new("Folder")
	folder.Name = "Traps"; folder.Parent = base
	for i=1,TRAPS_PER_BASE do
		local trap=Instance.new("Part"); trap.Name="Trap_"..i; trap.Size=Vector3.new(5,.25,5); trap.Anchored=true; trap.CanCollide=false; trap.Transparency=.25; trap.Material=Enum.Material.Neon; trap.Color=Color3.fromRGB(170,60,60); trap.Position=base.PrimaryPart and base.PrimaryPart.Position+Vector3.new((i-2)*10,1,10) or Vector3.new(0,2,0); trap:SetAttribute("Active",true); trap:SetAttribute("Cooldown",false); trap.Parent=folder
		local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Toggle Trap"; prompt.ObjectText="Trap "..i; prompt.HoldDuration=.2; prompt.MaxActivationDistance=9; prompt.RequiresLineOfSight=false; prompt.Parent=trap
		prompt.Triggered:Connect(function(player)
			if base:GetAttribute("OwnerUserId")~=player.UserId then return end
			local active=not trap:GetAttribute("Active"); trap:SetAttribute("Active",active); trap.Transparency=active and .25 or .7; prompt.ObjectText=active and "Trap "..i.." • ON" or "Trap "..i.." • OFF"
		end)
		trap.Touched:Connect(function(hit)
			if not trap:GetAttribute("Active") or trap:GetAttribute("Cooldown") then return end
			local intruder=getPlayerFromPart(hit); if not intruder then return end
			local owner=base:GetAttribute("OwnerUserId") or 0
			if owner==0 or intruder.UserId==owner then return end
			trap:SetAttribute("Cooldown",true); trap.Transparency=.75
			local hum=intruder.Character and intruder.Character:FindFirstChildOfClass("Humanoid")
			if hum then local old=hum.WalkSpeed; hum.WalkSpeed=0; task.delay(STUN_TIME,function() if hum.Parent then hum.WalkSpeed=old end end) end
			task.delay(COOLDOWN,function() if trap.Parent then trap:SetAttribute("Cooldown",false); trap:SetAttribute("Active",true); trap.Transparency=.25 end end)
		end)
	end
end

local function watch()
	local bases=Workspace:WaitForChild("Bases",20); if not bases then return end
	for _,base in ipairs(bases:GetChildren()) do setupBase(base) end
	bases.ChildAdded:Connect(setupBase)
end
watch()
print("TrapSystem loaded: 3 auto-reset traps per base.")
