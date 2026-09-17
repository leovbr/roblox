-- MapBuilder.server.lua
-- Generates a simple Roblox map foundation when placed in ServerScriptService.

local Workspace = game:GetService("Workspace")

local MAP_NAME = "LeoMap"

local oldMap = Workspace:FindFirstChild(MAP_NAME)
if oldMap then
	oldMap:Destroy()
end

local map = Instance.new("Folder")
map.Name = MAP_NAME
map.Parent = Workspace

local function part(name, size, position, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Parent = map
	return p
end

-- Ground
part("Ground", Vector3.new(220, 2, 220), Vector3.new(0, -1, 0), Enum.Material.Grass)

-- Spawn platform
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(14, 1, 14)
spawn.Position = Vector3.new(0, 1, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = map

-- Simple central platform
part("CenterPlatform", Vector3.new(40, 2, 40), Vector3.new(0, 2, 0), Enum.Material.Concrete)

-- Four corner obstacles / landmarks
local landmarks = {
	{"NorthTower", Vector3.new(8, 24, 8), Vector3.new(0, 13, -70)},
	{"SouthTower", Vector3.new(8, 24, 8), Vector3.new(0, 13, 70)},
	{"EastTower", Vector3.new(8, 24, 8), Vector3.new(70, 13, 0)},
	{"WestTower", Vector3.new(8, 24, 8), Vector3.new(-70, 13, 0)},
}

for _, data in ipairs(landmarks) do
	part(data[1], data[2], data[3], Enum.Material.Brick)
end

-- Basic paths
part("NorthPath", Vector3.new(10, 0.4, 100), Vector3.new(0, 1.2, -35), Enum.Material.Cobblestone)
part("SouthPath", Vector3.new(10, 0.4, 100), Vector3.new(0, 1.2, 35), Enum.Material.Cobblestone)
part("EastPath", Vector3.new(100, 0.4, 10), Vector3.new(35, 1.2, 0), Enum.Material.Cobblestone)
part("WestPath", Vector3.new(100, 0.4, 10), Vector3.new(-35, 1.2, 0), Enum.Material.Cobblestone)

print("LeoMap generated successfully.")
