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
Config.TREADMILL_PRICES = {
	[2] = {cash = 15000, robux = 15},
	[3] = {cash = 100000, robux = 40},
	[4] = {cash = 1000000, robux = 100},
	[5] = {cash = 10000000, robux = 250},
	[6] = {cash = 100000000, robux = 500},
	[7] = {cash = 1000000000, robux = 1000},
	[8] = {cash = 10000000000, robux = 2500},
	[9] = {cash = 100000000000, robux = 5000},
}

-- Developer Product IDs are intentionally 0 until the products are created in Roblox Creator Dashboard.
Config.DEVELOPER_PRODUCTS = {
	Treadmill2 = 0,
	Treadmill3 = 0,
	Treadmill4 = 0,
	Treadmill5 = 0,
	Treadmill6 = 0,
	Treadmill7 = 0,
	Treadmill8 = 0,
	Treadmill9 = 0,
	SpeedX2 = 0,
	SpeedX3 = 0,
	SpeedX4 = 0,
	SpeedInstant1M = 0,
	TrailBasic = 0,
	TrailNeon = 0,
	TrailPlasma = 0,
	TrailGalaxy = 0,
	TrailVoid = 0,
}

Config.SPEED_BOOSTS = {
	X2 = {multiplier = 2, robux = 2, duration = 300},
	X3 = {multiplier = 3, robux = 4, duration = 300},
	X4 = {multiplier = 4, robux = 8, duration = 300},
}
Config.INSTANT_SPEED = {cash = 1000000, robux = 40}

Config.TRAILS = {
	Basic = {cash = 10000, robux = 5, color = Color3.fromRGB(255, 255, 255), width = 0.35},
	Neon = {cash = 100000, robux = 15, color = Color3.fromRGB(0, 255, 255), width = 0.45},
	Plasma = {cash = 1000000, robux = 40, color = Color3.fromRGB(255, 80, 220), width = 0.55},
	Galaxy = {cash = 10000000, robux = 100, color = Color3.fromRGB(120, 90, 255), width = 0.65},
	Void = {cash = 100000000, robux = 250, color = Color3.fromRGB(180, 70, 255), width = 0.75},
}

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
