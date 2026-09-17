-- BatSystem.server.lua
-- Functional server-side bat. Activation targets the nearest player within range.
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local COOLDOWN=2
local RANGE=9
local cooldown={}

local function inOwnBase(player)
	local data=player:FindFirstChild("GameData"); local id=data and data:FindFirstChild("BaseId"); local bases=Workspace:FindFirstChild("Bases"); local base=id and bases and bases:FindFirstChild("Base_"..id.Value); local floor=base and base:FindFirstChild("Floor"); local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not floor or not root then return false end
	local p=root.Position-floor.Position; return math.abs(p.X)<=floor.Size.X/2 and math.abs(p.Z)<=floor.Size.Z/2 and math.abs(p.Y)<=12
end
local function steal(attacker,target)
	if target==attacker or inOwnBase(target) then return end
	local ad=attacker:FindFirstChild("GameData"); local td=target:FindFirstChild("GameData"); local ab=ad and ad:FindFirstChild("Brainrots"); local tb=td and td:FindFirstChild("Brainrots")
	if not ab or not tb or #tb:GetChildren()==0 then return end
	local item=tb:GetChildren()[math.random(1,#tb:GetChildren())]
	local clone=item:Clone(); clone.Parent=ab; item:Destroy()
	local hum=target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if hum then local old=hum.WalkSpeed; hum.WalkSpeed=6; task.delay(1,function() if hum.Parent then hum.WalkSpeed=old end end) end
end
local function add(player)
	local function create(container)
		if not container or container:FindFirstChild("StealBat") then return end
		local tool=Instance.new("Tool"); tool.Name="StealBat"; tool.RequiresHandle=true; tool.CanBeDropped=false
		local handle=Instance.new("Part"); handle.Name="Handle"; handle.Size=Vector3.new(.45,3.5,.45); handle.Color=Color3.fromRGB(105,65,35); handle.Material=Enum.Material.Wood; handle.CanCollide=false; handle.Parent=tool
		tool.Activated:Connect(function()
			if cooldown[player] and os.clock()-cooldown[player]<COOLDOWN then return end
			cooldown[player]=os.clock(); local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
			local nearest,best
			for _,other in ipairs(Players:GetPlayers()) do
				if other~=player then local r=other.Character and other.Character:FindFirstChild("HumanoidRootPart"); if r then local d=(r.Position-root.Position).Magnitude; if d<=RANGE and (not best or d<best) then nearest=other; best=d end end end
			end
			if nearest then steal(player,nearest) end
		end)
		tool.Parent=container
	end
	create(player:WaitForChild("Backpack")); player.CharacterAdded:Connect(function() task.wait(.5); create(player:FindFirstChild("Backpack")) end)
end
Players.PlayerAdded:Connect(add)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(add,p) end
print("BatSystem loaded: StealBat is server-authoritative.")
