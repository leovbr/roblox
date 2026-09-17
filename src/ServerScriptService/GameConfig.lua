-- GameConfig.lua
local Config = {}

Config.BASE_COUNT = 5
Config.STARTING_EGG_SLOTS = 5
Config.TOTAL_ZONES = 12
Config.EGGS_PER_ZONE = 5
Config.SPECIAL_ZONE_MIN = 4
Config.SPECIAL_ZONE_MAX = 7
Config.MYTHIC_ZONE_MIN = 4
Config.SECRET_ZONE_MIN = 4
Config.SPECIAL_RESPAWN_SECONDS = 600

Config.TREADMILL_SPEEDS = {5, 10, 20, 50, 100, 200, 500, 750, 1000}
Config.TREADMILL_PRICES = {
	[2] = {cash = 15000, robux = 15}, [3] = {cash = 100000, robux = 40}, [4] = {cash = 1000000, robux = 100},
	[5] = {cash = 10000000, robux = 250}, [6] = {cash = 100000000, robux = 500}, [7] = {cash = 1000000000, robux = 1000},
	[8] = {cash = 10000000000, robux = 2500}, [9] = {cash = 100000000000, robux = 5000},
}

-- Permanent benefits: replace every 0 with the real Game Pass ID after creating the passes.
Config.GAME_PASSES = {
	Treadmill2 = 0, Treadmill3 = 0, Treadmill4 = 0, Treadmill5 = 0, Treadmill6 = 0, Treadmill7 = 0, Treadmill8 = 0, Treadmill9 = 0,
	SpeedX2 = 0, SpeedX3 = 0, SpeedX4 = 0, SpeedX5 = 0, SpeedX6 = 0, SpeedX7 = 0, SpeedX8 = 0,
	SpeedX9 = 0, SpeedX10 = 0, SpeedX11 = 0, SpeedX12 = 0, SpeedX13 = 0, SpeedX14 = 0, SpeedX15 = 0, SpeedX16 = 0,
	InstantMoney1M = 0, SpeedInstant1M = 0,
	TrailBasic = 0, TrailNeon = 0, TrailPlasma = 0, TrailGalaxy = 0, TrailVoid = 0,
	MysticEggZone7 = 0,
}

Config.DEVELOPER_PRODUCTS = {
	InstantMoney1M = 0,
}

-- Permanent speed Game Pass prices. Capped at 1,500 Robux.
Config.SPEED_BOOSTS = {}
local speedPassPrices = {
	[2] = 2,
	[3] = 5,
	[4] = 10,
	[5] = 20,
	[6] = 35,
	[7] = 60,
	[8] = 100,
	[9] = 150,
	[10] = 225,
	[11] = 325,
	[12] = 450,
	[13] = 600,
	[14] = 800,
	[15] = 1100,
	[16] = 1500,
}
for multiplier = 2, 16 do
	Config.SPEED_BOOSTS["X" .. multiplier] = {multiplier = multiplier, robux = speedPassPrices[multiplier]}
end

Config.INSTANT_MONEY = {cash = 1000000, robux = 40}
Config.INSTANT_SPEED = {cash = 1000000, robux = 40}
Config.MYSTIC_EGG_ZONE7 = {robux = 299, income = 1500000, tier = "Mystic", zone = 7, creature = "Celestial Pink Dragon"}

Config.TRAILS = {
	Basic = {cash = 10000, robux = 5, color = Color3.fromRGB(255, 255, 255), width = 0.35},
	Neon = {cash = 100000, robux = 15, color = Color3.fromRGB(0, 255, 255), width = 0.45},
	Plasma = {cash = 1000000, robux = 40, color = Color3.fromRGB(255, 80, 220), width = 0.55},
	Galaxy = {cash = 10000000, robux = 100, color = Color3.fromRGB(120, 90, 255), width = 0.65},
	Void = {cash = 100000000, robux = 250, color = Color3.fromRGB(180, 70, 255), width = 0.75},
}

Config.DAY_SECONDS = 240
Config.NIGHT_SECONDS = 10
Config.NIGHT_HATCH_MULTIPLIER = 30

Config.EGG_SIZES = {
	Tiny = {min = 3.0, max = 3.8, hatchMultiplier = 1},
	Small = {min = 3.8, max = 4.8, hatchMultiplier = 2},
	Medium = {min = 4.8, max = 6.0, hatchMultiplier = 4},
	Large = {min = 6.0, max = 7.2, hatchMultiplier = 8},
	SuperBig = {min = 7.2, max = 9.5, hatchMultiplier = 12},
}
Config.BASE_HATCH_SECONDS = 5
Config.ZONE_HATCH_MULTIPLIER = 5
Config.SUPERBIG_LATE_ZONE_SECONDS = 3600

Config.EGG_TIERS = {
	Common = {weight = 50, income = 1},
	Uncommon = {weight = 30, income = 2},
	Rare = {weight = 14, income = 5},
	Epic = {weight = 5, income = 15},
	Legendary = {weight = 1, income = 40},
	Mythic = {weight = 0.08, income = 60},
	Secret = {weight = 0.015, income = 200},
	Divine = {weight = 0.005, income = 1000},
}

Config.RARITY_COLORS = {
	Common = Color3.fromRGB(185,185,185), Uncommon = Color3.fromRGB(90,210,110), Rare = Color3.fromRGB(65,145,255),
	Epic = Color3.fromRGB(190,75,255), Legendary = Color3.fromRGB(255,170,45), Mythic = Color3.fromRGB(255,55,95),
	Secret = Color3.fromRGB(255,230,80), Divine = Color3.fromRGB(255,255,255),
}

Config.ZONES = {
	[1] = {name="Emerald Forest", habitat="Forest", color=Color3.fromRGB(55,170,75), material=Enum.Material.Grass, recommendedSpeed=0, creatures={"Mossy Monkey","Leafy Slime","Forest Bunny"}},
	[2] = {name="Coral Ocean", habitat="Ocean", color=Color3.fromRGB(35,150,210), material=Enum.Material.Sand, recommendedSpeed=10, creatures={"Coral Crab","Bubble Fish","Tiny Shark"}},
	[3] = {name="Inferno Lava", habitat="Lava", color=Color3.fromRGB(230,65,25), material=Enum.Material.Slate, recommendedSpeed=20, creatures={"Lava Lizard","Ember Bat","Magma Golem"}},
	[4] = {name="Frozen Glacier", habitat="Ice", color=Color3.fromRGB(130,220,255), material=Enum.Material.Ice, recommendedSpeed=30, creatures={"Snow Fox","Ice Penguin","Frost Yeti"}},
	[5] = {name="Thunder Valley", habitat="Storm", color=Color3.fromRGB(120,90,210), material=Enum.Material.Rock, recommendedSpeed=40, creatures={"Storm Crow","Volt Bunny","Thunder Golem"}},
	[6] = {name="Crystal Cavern", habitat="Crystal", color=Color3.fromRGB(220,80,230), material=Enum.Material.CrackedLava, recommendedSpeed=50, creatures={"Crystal Bat","Gem Slime","Prism Dragon"}},
	[7] = {name="Sky Islands", habitat="Sky", color=Color3.fromRGB(90,170,255), material=Enum.Material.Cloud, recommendedSpeed=60, creatures={"Cloud Cat","Sky Ray","Celestial Bird"}},
	[8] = {name="Ancient Ruins", habitat="Ruins", color=Color3.fromRGB(170,145,95), material=Enum.Material.Sandstone, recommendedSpeed=70, creatures={"Ruin Golem","Relic Rat","Ancient Serpent"}},
	[9] = {name="Shadow Swamp", habitat="Swamp", color=Color3.fromRGB(75,95,70), material=Enum.Material.Mud, recommendedSpeed=80, creatures={"Shadow Frog","Bog Beast","Swamp Witchling"}},
	[10] = {name="Star Galaxy", habitat="Galaxy", color=Color3.fromRGB(75,55,180), material=Enum.Material.Neon, recommendedSpeed=90, creatures={"Star Cat","Cosmic Blob","Galaxy Dragon"}},
	[11] = {name="Void Dimension", habitat="Void", color=Color3.fromRGB(45,20,70), material=Enum.Material.Neon, recommendedSpeed=100, creatures={"Void Eye","Null Beast","Void Serpent"}},
	[12] = {name="Pinky Dreamland", habitat="Pinky", color=Color3.fromRGB(255,105,190), material=Enum.Material.Neon, recommendedSpeed=120, creatures={"Pinky Bunny","Cotton Candy Slime","Love Dragon"}},
}

return Config
