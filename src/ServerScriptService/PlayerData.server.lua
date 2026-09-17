-- PlayerData.server.lua
local Players = game:GetService("Players")

local DEFAULT = {
	Cash = 0,
	Zone = 1,
	SpeedLevel = 1,
	EggSlots = 5,
	AuraLevel = 0,
	CageLevel = 1,
	BaseId = 0,
}

local function setupPlayer(player)
	if player:FindFirstChild("GameData") then return end

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DEFAULT.Cash
	cash.Parent = stats

	local data = Instance.new("Folder")
	data.Name = "GameData"
	data.Parent = player

	for name, value in pairs(DEFAULT) do
		if name ~= "Cash" then
			local v = Instance.new("IntValue")
			v.Name = name
			v.Value = value
			v.Parent = data
		end
	end

	local brainrots = Instance.new("Folder")
	brainrots.Name = "Brainrots"
	brainrots.Parent = data
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end
