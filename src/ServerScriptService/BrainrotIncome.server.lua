-- BrainrotIncome.server.lua
local Players = game:GetService("Players")

local TICK = 1

local function collectIncome(player)
	local stats = player:FindFirstChild("leaderstats")
	local data = player:FindFirstChild("GameData")
	local cash = stats and stats:FindFirstChild("Cash")
	local brainrots = data and data:FindFirstChild("Brainrots")
	if not cash or not brainrots then return end

	local total = 0
	for _, brainrot in ipairs(brainrots:GetChildren()) do
		total += brainrot:GetAttribute("Income") or 0
	end

	cash.Value += total
end

while true do
	task.wait(TICK)
	for _, player in ipairs(Players:GetPlayers()) do
		collectIncome(player)
	end
end
