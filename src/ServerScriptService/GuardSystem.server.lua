-- GuardSystem.server.lua
-- A simple non-player guardian protects each base perimeter.
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RANGE=14
local COOLDOWN=5
local busy={}
local function getRoot(player) return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function setup(base)
	local floor=base:FindFirstChild("Floor"); if not floor then return end
	local guard=Instance.new("Part"); guard.Name="BaseGuard"; guard.Shape=Enum.PartType.Ball; guard.Size=Vector3.new(3,4,3); guard.Anchored=true; guard.CanCollide=false; guard.Material=Enum.Material.Neon; guard.Color=Color3.fromRGB(255,210,70); guard.Position=floor.Position+Vector3.new(0,3,12); guard.Parent=base
	local light=Instance.new("PointLight"); light.Range=14; light.Brightness=1.5; light.Parent=guard
	local bill=Instance.new("BillboardGui"); bill.Size=UDim2.fromOffset(130,35); bill.StudsOffset=Vector3.new(0,3,0); bill.AlwaysOnTop=true; bill.Parent=guard
	local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text="GUARD"; label.TextColor3=Color3.fromRGB(255,235,120); label.TextScaled=true; label.Font=Enum.Font.GothamBlack; label.Parent=bill
	task.spawn(function()
		while guard.Parent do
			local owner=base:GetAttribute("OwnerUserId") or 0
			if owner~=0 then
				for _,player in ipairs(Players:GetPlayers()) do
					if player.UserId~=owner and not busy[player] then
						local root=getRoot(player)
						if root and (root.Position-guard.Position).Magnitude<=RANGE then
							busy[player]=true
							local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
							if hum then local old=hum.WalkSpeed; hum.WalkSpeed=5; task.delay(1.5,function() if hum.Parent then hum.WalkSpeed=old end end) end
							task.delay(COOLDOWN,function() busy[player]=nil end)
						end
					end
				end
			end
			task.wait(.25)
		end
	end)
end
local bases=Workspace:WaitForChild("Bases",20)
if bases then for _,b in ipairs(bases:GetChildren()) do setup(b) end; bases.ChildAdded:Connect(function(b) task.wait(.1); setup(b) end) end
print("GuardSystem loaded.")
