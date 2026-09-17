-- MapBuilder.server.lua
-- Builds 12 visually distinct habitat zones, egg areas, speed requirement boards, and the premium Zone 7 egg showcase.

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(script.Parent.GameConfig)

local MAP_NAME = "LeoMap"
local oldMap = Workspace:FindFirstChild(MAP_NAME)
if oldMap then oldMap:Destroy() end

local map = Instance.new("Folder")
map.Name = MAP_NAME
map.Parent = Workspace

local function part(parent,name,size,position,material,color,shape)
	local p=Instance.new("Part")
	p.Name=name p.Size=size p.Position=position p.Anchored=true
	p.Material=material or Enum.Material.SmoothPlastic
	if color then p.Color=color end
	if shape then p.Shape=shape end
	p.Parent=parent
	return p
end

part(map,"Ground",Vector3.new(1000,2,220),Vector3.new(385,-1,0),Enum.Material.Grass,Color3.fromRGB(60,110,60))
local spawn=Instance.new("SpawnLocation")
spawn.Name="Spawn" spawn.Size=Vector3.new(14,1,14) spawn.Position=Vector3.new(-45,1,0) spawn.Anchored=true spawn.Neutral=true spawn.Parent=map

local zonesFolder=Instance.new("Folder")
zonesFolder.Name="HabitatZones" zonesFolder.Parent=map
local ZONE_LENGTH=78
local START_X=0

local function addSpeedBoard(folder,zone,center,data)
	local board=part(folder,"GuardianSpeedBoard",Vector3.new(25,7,1.5),Vector3.new(center.X,4.5,8),Enum.Material.SmoothPlastic,data.color)
	local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.Parent=board
	local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.TextScaled=true text.Font=Enum.Font.GothamBlack text.TextColor3=Color3.new(1,1,1)
	text.Text=string.format("GUARDIAN\nNEED SPEED %d",data.recommendedSpeed) text.Parent=gui
	board:SetAttribute("RequiredSpeed",data.recommendedSpeed)
end

local function addDecoration(zoneFolder,zone,center,data)
	local z=center.Z local x=center.X local c=data.color
	if data.habitat=="Forest" then
		for i=1,7 do local dx=((i*23)%55)-27 local trunk=part(zoneFolder,"TreeTrunk_"..i,Vector3.new(4,12,4),Vector3.new(x+dx,6,z+30),Enum.Material.Wood,Color3.fromRGB(105,70,40)); part(zoneFolder,"TreeTop_"..i,Vector3.new(13,13,13),trunk.Position+Vector3.new(0,8,0),Enum.Material.Grass,c,Enum.PartType.Ball) end
	elseif data.habitat=="Ocean" then
		part(zoneFolder,"Water",Vector3.new(65,.6,70),Vector3.new(x,.2,z+30),Enum.Material.Water,c); for i=1,6 do part(zoneFolder,"Coral_"..i,Vector3.new(3,8+i,3),Vector3.new(x-25+i*8,4,z+25),Enum.Material.Neon,c) end
	elseif data.habitat=="Lava" then
		part(zoneFolder,"LavaRiver",Vector3.new(12,.8,70),Vector3.new(x+25,.3,z+30),Enum.Material.Neon,c); for i=1,6 do part(zoneFolder,"MagmaRock_"..i,Vector3.new(7,8,7),Vector3.new(x-25+i*9,4,z+20),Enum.Material.Slate,c,Enum.PartType.Ball) end
	elseif data.habitat=="Ice" then for i=1,6 do part(zoneFolder,"IceSpike_"..i,Vector3.new(7,16,7),Vector3.new(x-25+i*10,8,z+30),Enum.Material.Ice,c) end
	elseif data.habitat=="Storm" then for i=1,5 do part(zoneFolder,"StormPillar_"..i,Vector3.new(5,22,5),Vector3.new(x-24+i*12,11,z+28),Enum.Material.Neon,c) end
	elseif data.habitat=="Crystal" then for i=1,7 do part(zoneFolder,"Crystal_"..i,Vector3.new(5,14,5),Vector3.new(x-27+i*9,7,z+28),Enum.Material.Neon,c) end
	elseif data.habitat=="Sky" then for i=1,5 do part(zoneFolder,"CloudIsland_"..i,Vector3.new(16,3,12),Vector3.new(x-25+i*12,10+(i%2)*7,z+25),Enum.Material.Cloud,c) end
	elseif data.habitat=="Ruins" then for i=1,6 do part(zoneFolder,"RuinPillar_"..i,Vector3.new(6,18-i,6),Vector3.new(x-25+i*10,8,z+30),Enum.Material.Sandstone,c) end
	elseif data.habitat=="Swamp" then
		part(zoneFolder,"SwampPool",Vector3.new(55,.7,45),Vector3.new(x,.3,z+32),Enum.Material.Mud,c); for i=1,8 do part(zoneFolder,"SwampRock_"..i,Vector3.new(5,5,5),Vector3.new(x-28+i*7,3,z+18),Enum.Material.Mud,c,Enum.PartType.Ball) end
	elseif data.habitat=="Galaxy" then for i=1,10 do part(zoneFolder,"Star_"..i,Vector3.new(2,2,2),Vector3.new(x-30+((i*17)%60),12+(i%4)*7,z+18+((i*11)%25)),Enum.Material.Neon,c,Enum.PartType.Ball) end
	elseif data.habitat=="Void" then
		part(zoneFolder,"VoidCore",Vector3.new(18,18,18),Vector3.new(x,10,z+32),Enum.Material.Neon,c,Enum.PartType.Ball); for i=1,5 do part(zoneFolder,"VoidPillar_"..i,Vector3.new(4,25,4),Vector3.new(x-25+i*12,12,z+28),Enum.Material.Neon,c) end
	else
		part(zoneFolder,"PinkyHeartCore",Vector3.new(20,24,20),Vector3.new(x,12,z+30),Enum.Material.Neon,c,Enum.PartType.Ball)
		for i=1,6 do local p=part(zoneFolder,"PinkHeartPillar_"..i,Vector3.new(4,16,4),Vector3.new(x-25+i*10,8,z+28),Enum.Material.Neon,Color3.fromRGB(255,180,225)); local light=Instance.new("PointLight") light.Color=Color3.fromRGB(255,105,190) light.Range=18 light.Brightness=2 light.Parent=p end
	end
end

for zone=1,Config.TOTAL_ZONES do
	local data=Config.ZONES[zone] local centerX=START_X+(zone-1)*ZONE_LENGTH
	local folder=Instance.new("Folder") folder.Name=string.format("Zone_%02d_%s",zone,data.name:gsub(" ","")) folder:SetAttribute("Zone",zone) folder:SetAttribute("Habitat",data.habitat) folder:SetAttribute("ZoneName",data.name) folder:SetAttribute("RecommendedSpeed",data.recommendedSpeed) folder.Parent=zonesFolder
	part(folder,"HabitatGround",Vector3.new(ZONE_LENGTH-4,1,82),Vector3.new(centerX,0,25),data.material,data.color)
	local sign=part(folder,"ZoneSign",Vector3.new(34,10,2),Vector3.new(centerX,6,-15),Enum.Material.SmoothPlastic,data.color)
	local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.Parent=sign
	local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.TextScaled=true text.Font=Enum.Font.GothamBlack text.TextColor3=Color3.new(1,1,1) text.Text=string.format("ZONE %02d\n%s",zone,data.name) text.Parent=gui
	addSpeedBoard(folder,zone,Vector3.new(centerX,0,25),data)
	local eggArea=Instance.new("Folder") eggArea.Name="EggArea" eggArea.Parent=folder
	for i=1,Config.EGGS_PER_ZONE do local px=centerX+(i-3)*10 part(eggArea,"EggPedestal_"..i,Vector3.new(7,2,7),Vector3.new(px,2,25),Enum.Material.Marble,data.color) end
	addDecoration(folder,zone,Vector3.new(centerX,0,25),data)
end

-- Premium Zone 7 Mystic Egg showcase: visible in the safe/spawn area near the shop area.
local showcase=Instance.new("Folder") showcase.Name="PremiumMysticEggShowcase" showcase.Parent=map
local pedestal=part(showcase,"MysticPedestal",Vector3.new(10,2,10),Vector3.new(-25,2,-5),Enum.Material.Neon,Color3.fromRGB(255,105,190),Enum.PartType.Cylinder)
local egg=part(showcase,"MysticEgg299R",Vector3.new(6,8,6),Vector3.new(-25,8,-5),Enum.Material.Neon,Color3.fromRGB(255,70,170),Enum.PartType.Ball)
egg:SetAttribute("Zone",7) egg:SetAttribute("Tier","Mystic") egg:SetAttribute("Income",Config.MYSTIC_EGG_ZONE7.income) egg:SetAttribute("PriceRobux",Config.MYSTIC_EGG_ZONE7.robux)
local hi=Instance.new("Highlight") hi.FillColor=Color3.fromRGB(255,80,200) hi.FillTransparency=.25 hi.OutlineColor=Color3.fromRGB(255,255,255) hi.Parent=egg
local emitter=Instance.new("ParticleEmitter") emitter.Rate=20 emitter.Lifetime=NumberRange.new(.8,1.6) emitter.Speed=NumberRange.new(1,3) emitter.SpreadAngle=Vector2.new(360,360) emitter.LightEmission=1 emitter.Color=ColorSequence.new(Color3.fromRGB(255,180,235)) emitter.Parent=egg
TweenService:Create(egg,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Size=Vector3.new(6.5,8.6,6.5),Position=Vector3.new(-25,9,-5)}):Play()
local bill=Instance.new("BillboardGui") bill.Size=UDim2.fromOffset(260,100) bill.StudsOffset=Vector3.new(0,6,0) bill.AlwaysOnTop=true bill.Parent=egg
local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.TextScaled=true label.Font=Enum.Font.GothamBlack label.TextColor3=Color3.new(1,1,1) label.TextStrokeTransparency=.15 label.Text="🌸 MYSTIC EGG\n1.5M$/s • 299 R$" label.Parent=bill
local prompt=Instance.new("ProximityPrompt") prompt.ActionText="BUY 299 R$" prompt.ObjectText="Zone 7 Mystic Egg" prompt.HoldDuration=.5 prompt.MaxActivationDistance=12 prompt.Parent=egg
prompt.Triggered:Connect(function(player)
	local id=Config.DEVELOPER_PRODUCTS.MysticEggZone7
	if id and id>0 then MarketplaceService:PromptProductPurchase(player,id) end
end)

print("LeoMap generated: 12 habitats, guardian speed boards, and Zone 7 Mystic Egg showcase.")
