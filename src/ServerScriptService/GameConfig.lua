-- GameConfig.lua
local Config = {}

Config.BASE_COUNT = 5
Config.STARTING_EGG_SLOTS = 5
Config.TOTAL_ZONES = 12
Config.EGGS_PER_ZONE = 5
Config.SPECIAL_ZONE_MIN = 5
Config.SPECIAL_ZONE_MAX = 6
Config.MYTHIC_ZONE_MIN = 7
Config.SECRET_ZONE_MIN = 7
Config.SPECIAL_RESPAWN_SECONDS = 600

Config.TREADMILL_SPEEDS = {5, 10, 20, 50, 100, 200, 500, 750, 1000}
Config.DAY_SECONDS = 240
Config.NIGHT_SECONDS = 10

Config.EGG_TIERS = {
	Common = {weight = 60, income = 1, size = 4.0},
	Rare = {weight = 25, income = 3, size = 4.5},
	Epic = {weight = 10, income = 8, size = 5.0},
	Legendary = {weight = 4, income = 20, size = 5.6},
	Mythic = {weight = 0.9, income = 60, size = 6.4},
	Secret = {weight = 0.1, income = 200, size = 7.2},
}

-- Every zone has its own habitat, palette, materials and creature pool.
Config.ZONES = {
	[1] = {name = "Emerald Forest", habitat = "Forest", color = Color3.fromRGB(55, 170, 75), material = Enum.Material.Grass, creatures = {"Mossy Monkey", "Leafy Slime", "Forest Bunny"}},
	[2] = {name = "Coral Ocean", habitat = "Ocean", color = Color3.fromRGB(35, 150, 210), material = Enum.Material.Sand, creatures = {"Coral Crab", "Bubble Fish", "Tiny Shark"}},
	[3] = {name = "Inferno Lava", habitat = "Lava", color = Color3.fromRGB(230, 65, 25), material = Enum.Material.Slate, creatures = {"Lava Lizard", "Ember Bat", "Magma Golem"}},
	[4] = {name = "Frozen Glacier", habitat = "Ice", color = Color3.fromRGB(130, 220, 255), material = Enum.Material.Ice, creatures = {"Snow Fox", "Ice Penguin", "Frost Yeti"}},
	[5] = {name = "Thunder Valley", habitat = "Storm", color = Color3.fromRGB(120, 90, 210), material = Enum.Material.Rock, creatures = {"Storm Crow", "Volt Bunny", "Thunder Golem"}},
	[6] = {name = "Crystal Cavern", habitat = "Crystal", color = Color3.fromRGB(220, 80, 230), material = Enum.Material.CrackedLava, creatures = {"Crystal Bat", "Gem Slime", "Prism Dragon"}},
	[7] = {name = "Sky Islands", habitat = "Sky", color = Color3.fromRGB(90, 170, 255), material = Enum.Material.Cloud, creatures = {"Cloud Cat", "Sky Ray", "Celestial Bird"}},
	[8] = {name = "Ancient Ruins", habitat = "Ruins", color = Color3.fromRGB(170, 145, 95), material = Enum.Material.Sandstone, creatures = {"Ruin Golem", "Relic Rat", "Ancient Serpent"}},
	[9] = {name = "Shadow Swamp", habitat = "Swamp", color = Color3.fromRGB(75, 95, 70), material = Enum.Material.Mud, creatures = {"Shadow Frog", "Bog Beast", "Swamp Witchling"}},
	[10] = {name = "Star Galaxy", habitat = "Galaxy", color = Color3.fromRGB(75, 55, 180), material = Enum.Material.Neon, creatures = {"Star Cat", "Cosmic Blob", "Galaxy Dragon"}},
	[11] = {name = "Void Dimension", habitat = "Void", color = Color3.fromRGB(45, 20, 70), material = Enum.Material.Neon, creatures = {"Void Eye", "Null Beast", "Void Serpent"}},
	[12] = {name = "Secret Paradise", habitat = "Secret", color = Color3.fromRGB(255, 215, 70), material = Enum.Material.Marble, creatures = {"Golden Monkey", "Secret Angel", "Heaven Dragon"}},
}

return Config
