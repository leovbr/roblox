-- StealSystem.server.lua
-- Bat combat: hit a nearby player who is outside their own safe zone and transfer one Brainrot.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder"); remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local event=remotes:FindFirstChild("StealAttempt") or Instance.new("RemoteEvent"); event.Name="StealAttempt"; event.Parent=remotes
local cooldown={}
local COOLDOWN=2

local function insideBase(player,base)
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); local floor=base and base:FindFirstChild("Floor")
	if not root or not floor then return false end
	local p=root.Position-floor.Position
	return math.abs(p.X)<=floor.Size.X/2 and math.abs(p.Z)<=floor.Size.Z/2 and math.abs(p.Y)<=12
end
local function targetInSafeZone(player)
	local data=player:FindFirstChild("GameData"); local id=data and data:FindFirstChild("BaseId")
	local bases=Workspace:FindFirstChild("Bases"); local base=id and bases and bases:FindFirstChild("Base_"..id.Value)
	return base and insideBase(player,base)
end
local function giveBat(player)
	local function create(container)
		if container:FindFirstChild("Bat") then return end
		local tool=Instance.new("Tool"); tool.Name="Bat"; tool.RequiresHandle=true; tool.CanBeDropped=false
		local handle=Instance.new("Part"); handle.Name="Handle"; handle.Size=Vector3.new(.45,3.5,.45); handle.Color=Color3.fromRGB(105,65,35); handle.Material=Enum.Material.Wood; handle.CanCollide=false; handle.Parent=tool
		tool.Activated:Connect(function()
			if cooldown[player] and os.clock()-cooldown[player]<COOLDOWN then return end
			cooldown[player]=os.clock()
			local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
			local nearest,best
			for _,other in ipairs(Players:GetPlayers()) do
				if other~=player then local r=other.Character and other.Character:FindFirstChild("HumanoidRootPart"); if r then local d=(r.Position-root.Position).Magnitude; if d<=9 and (not best or d<best) then nearest=other; best=d end end end
			end
			if nearest then event:FireServer(nearest) end
		end)
		tool.Parent=container
	end
	create(player:WaitForChild("Backpack")); player.CharacterAdded:Connect(function() task.wait(.5); create(player.Backpack) end)
end

Players.PlayerAdded:Connect(giveBat)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(giveBat,p) end

event.OnServerEvent:Connect(function(player,target)
	if typeof(target)~="Instance" or not target:IsA("Player") or target==player then return end
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); local troot=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not root or not troot or (root.Position-troot.Position).Magnitude>10 then return end
	if targetInSafeZone(target) then return end
	local tdata=target:FindFirstChild("GameData"); local pdata=player:FindFirstChild("GameData"); local tb=tdata and tdata:FindFirstChild("Brainrots"); local pb=pdata and pdata:FindFirstChild("Brainrots")
	if not tb or not pb or #tb:GetChildren()==0 then return end
	local list=tb:GetChildren(); local stolen=list[math.random(1,#list)]
	if stolen then
		local clone=stolen:Clone(); clone.Parent=pb; stolen:Destroy()
		local hum=target.Character and target.Character:FindFirstChildOfClass("Humanoid")
		if hum then local old=hum.WalkSpeed; hum.WalkSpeed=7; task.delay(.8,function() if hum.Parent then hum.WalkSpeed=old end end) end
	end
end)
print("StealSystem loaded: Bat + safe-zone protected Brainrot theft.")
