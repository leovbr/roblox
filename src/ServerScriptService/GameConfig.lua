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
	Common = {weight = 60, income = 1},
	Rare = {weight = 25, income = 3},
	Epic = {weight = 10, income = 8},
	Legendary = {weight = 4, income = 20},
	Mythic = {weight = 0.9, income = 60},
	Secret = {weight = 0.1, income = 200},
}

return Config
