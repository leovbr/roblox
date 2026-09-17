-- LeaderboardSystem.server.lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local incomeStore = DataStoreService:GetOrderedDataStore("CuriBrainrot_IncomePerSecond_v1")
local speedStore = DataStoreService:GetOrderedDataStore("CuriBrainrot_TopSpeed_v1")
local activeStore = DataStoreService:GetOrderedDataStore("CuriBrainrot_ActiveTime_v1")

local REFRESH_SECONDS = 300
local boards = {}
local activeSeconds = {}
local savedActive = {}

local function formatNumber(n)
	n = tonumber(n) or 0
	local suffixes = {"", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
	local i = 1
	while math.abs(n) >= 1000 and i < #suffixes do
		n /= 1000
		i += 1
	end
	if i == 1 then return tostring(math.floor(n)) end
	return string.format("%.2f%s", n, suffixes[i])
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	local days = math.floor(seconds / 86400)
	seconds %= 86400
	local hours = math.floor(seconds / 3600)
	seconds %= 3600
	local mins = math.floor(seconds / 60)
	return string.format("%dd %02dh %02dm", days, hours, mins)
end

local function getIncome(player)
	local data = player:FindFirstChild("GameData")
	local brainrots = data and data:FindFirstChild("Brainrots")
	local total = 0
	if brainrots then
		for _, brainrot in ipairs(brainrots:GetChildren()) do
			total += tonumber(brainrot:GetAttribute("Income")) or 0
		end
	end
	return total
end

local function makeBoard(name, title, position)
	local folder = workspace:FindFirstChild("Leaderboards") or Instance.new("Folder")
	folder.Name = "Leaderboards"
	folder.Parent = workspace

	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = Vector3.new(15, 9, 0.7)
	part.Position = position
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = folder

	local gui = Instance.new("SurfaceGui")
	gui.Name = "BoardGui"
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 650)
	gui.Parent = part

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, 0, 0, 100)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.Parent = gui

	local body = Instance.new("TextLabel")
	body.Name = "Entries"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(25, 105)
	body.Size = UDim2.new(1, -50, 1, -125)
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Font = Enum.Font.GothamBold
	body.TextSize = 30
	body.TextColor3 = Color3.new(1, 1, 1)
	body.Text = "Loading..."
	body.Parent = gui
	return body
end

boards.Income = makeBoard("IncomeBoard", "TOP INCOME / SECOND", Vector3.new(-18, 7, -28))
boards.Speed = makeBoard("SpeedBoard", "TOP SPEED", Vector3.new(0, 7, -28))
boards.Active = makeBoard("ActiveBoard", "TOP ACTIVE TIME", Vector3.new(18, 7, -28))

local function nameForUserId(userId)
	local player = Players:GetPlayerByUserId(userId)
	if player then return player.DisplayName end
	local ok, name = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	return ok and name or ("User " .. tostring(userId))
end

local function readTop(store, formatter)
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, 10)
	end)
	if not ok then return "Leaderboard unavailable" end
	local lines = {}
	for rank, entry in ipairs(pages:GetCurrentPage()) do
		local userId = tonumber(entry.key)
		local name = nameForUserId(userId)
		lines[#lines + 1] = string.format("%d. %s — %s", rank, name, formatter(entry.value))
	end
	return #lines > 0 and table.concat(lines, "\n") or "No players yet"
end

local function savePlayer(player)
	local userId = tostring(player.UserId)
	local seconds = (savedActive[player] or 0) + (activeSeconds[player] or 0)
	activeSeconds[player] = 0
	savedActive[player] = seconds
	local data = player:FindFirstChild("GameData")
	local level = data and data:FindFirstChild("SpeedLevel")
	local speed = 5
	if level then
		local Config = require(script.Parent.GameConfig)
		speed = Config.TREADMILL_SPEEDS[math.clamp(level.Value, 1, #Config.TREADMILL_SPEEDS)] or 5
	end
	pcall(function() incomeStore:SetAsync(userId, getIncome(player)) end)
	pcall(function() speedStore:SetAsync(userId, speed * (player:GetAttribute("SpeedBoostMultiplier") or 1)) end)
	pcall(function() activeStore:SetAsync(userId, seconds) end)
end

local function refresh()
	boards.Income.Text = readTop(incomeStore, function(v) return formatNumber(v) .. "$/s" end)
	boards.Speed.Text = readTop(speedStore, function(v) return formatNumber(v) .. " Speed" end)
	boards.Active.Text = readTop(activeStore, formatTime)
end

Players.PlayerAdded:Connect(function(player)
	activeSeconds[player] = 0
	local ok, previous = pcall(function()
		return activeStore:GetAsync(tostring(player.UserId))
	end)
	savedActive[player] = ok and tonumber(previous) or 0
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	activeSeconds[player] = nil
	savedActive[player] = nil
end)

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			activeSeconds[player] = (activeSeconds[player] or 0) + 1
		end
	end
end)

task.spawn(function()
	while true do
		savePlayer
		for _, player in ipairs(Players:GetPlayers()) do savePlayer(player) end
		refresh()
		task.wait(REFRESH_SECONDS)
	end
end)
