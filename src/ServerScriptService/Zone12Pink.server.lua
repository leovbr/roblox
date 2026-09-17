-- Zone12Pink.server.lua
-- Adds a cute pink finale habitat without replacing the base map builder.
local Workspace=game:GetService("Workspace")
local pink=Color3.fromRGB(255,105,190)
local light=Color3.fromRGB(255,185,230)
local function part(parent,name,size,pos,material,color,shape)
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.CanCollide=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or pink;if shape then p.Shape=shape end;p.Parent=parent;return p
end

task.spawn(function()
	local map=Workspace:WaitForChild("LeoMap",30);if not map then return end
	local habitats=map:WaitForChild("HabitatZones",30);if not habitats then return end
	local zone
	for _,folder in ipairs(habitats:GetChildren()) do if folder:GetAttribute("Zone")==12 then zone=folder;break end end
	if not zone then return end
	for i=1,7 do
		local x=zone:GetPivot().Position.X-28+i*8
		local y=5+(i%3)*2
		local heart=part(zone,"PinkHeart_"..i,Vector3.new(4,4,2),Vector3.new(x,y,52),Enum.Material.Neon,light,Enum.PartType.Ball)
		local sparkle=Instance.new("PointLight");sparkle.Color=pink;sparkle.Brightness=1.5;sparkle.Range=12;sparkle.Parent=heart
	end
	for i=1,8 do
		local x=zone:GetPivot().Position.X-30+i*8
		local cloud=part(zone,"CottonCloud_"..i,Vector3.new(10,4,7),Vector3.new(x,2,8+(i%2)*8),Enum.Material.SmoothPlastic,light,Enum.PartType.Ball)
		cloud.Transparency=.15
	end
	local sign=zone:FindFirstChild("ZoneSign")
	if sign then
		local gui=sign:FindFirstChildOfClass("SurfaceGui");local text=gui and gui:FindFirstChildOfClass("TextLabel")
		if text then text.Text="ZONE 12\nPINKY DREAMLAND 💗";text.TextColor3=light end
	end
end)
