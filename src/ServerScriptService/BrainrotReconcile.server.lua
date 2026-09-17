-- BrainrotReconcile.server.lua
-- Re-checks persisted Brainrots when a player claims a base.
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local function reconcile(player)
	local data=player:FindFirstChild("GameData"); local id=data and data:FindFirstChild("BaseId"); local list=data and data:FindFirstChild("Brainrots")
	if not id or not list or id.Value==0 then return end
	local bases=Workspace:FindFirstChild("Bases"); local base=bases and bases:FindFirstChild("Base_"..id.Value); local slots=base and base:FindFirstChild("BrainrotEnclosures"); local world=Workspace:FindFirstChild("Brainrots")
	if not slots or not world then return end
	for _,b in ipairs(list:GetChildren()) do
		if not world:FindFirstChild(b.Name) then
			for _,slot in ipairs(slots:GetChildren()) do
				if slot:GetAttribute("Occupied")~=true then
					local model=Instance.new("Model"); model.Name=b.Name; model:SetAttribute("OwnerUserId",player.UserId); model:SetAttribute("BrainrotId",b.Name); model:SetAttribute("Tier",b:GetAttribute("Tier") or "Common"); model.Parent=world
					local zone=tonumber(b:GetAttribute("Zone")) or 1; local z=require(script.Parent.GameConfig).ZONES[zone] or require(script.Parent.GameConfig).ZONES[1]; local p=slot.Position+Vector3.new(0,2,0); local s=tonumber(b:GetAttribute("DisplayScale")) or 1; local c=z.color
					local body=Instance.new("Part"); body.Name="Body"; body.Shape=Enum.PartType.Ball; body.Size=Vector3.new(2.4,2.6,2)*s; body.Position=p; body.Anchored=true; body.CanCollide=false; body.Color=c; body.Parent=model
					local head=body:Clone(); head.Name="Head"; head.Size=Vector3.new(2.2,2,2)*s; head.Position=p+Vector3.new(0,1.6*s,0); head.Parent=model
					local h=Instance.new("Highlight"); h.FillColor=c; h.FillTransparency=.65; h.Parent=model
					slot:SetAttribute("Occupied",true); slot:SetAttribute("BrainrotId",b.Name); b:SetAttribute("Slot",slot:GetAttribute("Slot")); b:SetAttribute("BaseId",id.Value); break
				end
			end
		end
	end
end
local function watch(p)
	local data=p:WaitForChild("GameData",15); if not data then return end
	local id=data:WaitForChild("BaseId",15); if not id then return end
	id.Changed:Connect(function() if id.Value>0 then task.wait(.2); reconcile(p) end end)
	if id.Value>0 then task.defer(reconcile,p) end
end
Players.PlayerAdded:Connect(watch)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(watch,p) end
print("BrainrotReconcile loaded.")
