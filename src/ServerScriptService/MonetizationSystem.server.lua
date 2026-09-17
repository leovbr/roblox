-- MonetizationSystem.server.lua
-- Permanent Robux upgrades use Game Passes. Cash purchases remain server-side.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.GameConfig)

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local purchaseEvent = remotes:FindFirstChild("PurchaseRobux") or Instance.new("RemoteEvent")
purchaseEvent.Name = "PurchaseRobux"
purchaseEvent.Parent = remotes

local trailEvent = remotes:FindFirstChild("BuyTrail") or Instance.new("RemoteEvent")
trailEvent.Name = "BuyTrail"
trailEvent.Parent = remotes

local function dataOf(p) return p:FindFirstChild("GameData") end
local function cashOf(p)
	local s = p:FindFirstChild("leaderstats")
	return s and s:FindFirstChild("Cash")
end

local function promptPass(player, action)
	local id = Config.GAME_PASSES[action]
	if typeof(id) ~= "number" or id <= 0 then
		purchaseEvent:FireClient(player, false, "Game Pass ID belum dipasang: " .. action)
		return
	end
	local owns = false
	local ok = pcall(function()
		owns = MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
	end)
	if ok and owns then
		purchaseEvent:FireClient(player, false, "Game Pass ini sudah kamu punya.")
		return
	end
	MarketplaceService:PromptGamePassPurchase(player, id)
end

purchaseEvent.OnServerEvent:Connect(function(player, action)
	if typeof(action) ~= "string" then return end
	if Config.GAME_PASSES[action] ~= nil then
		promptPass(player, action)
		return
	end
	purchaseEvent:FireClient(player, false, "Pembelian belum dikonfigurasi: " .. action)
end)

trailEvent.OnServerEvent:Connect(function(player, name)
	if typeof(name) ~= "string" then return end
	local cfg, cash, data = Config.TRAILS[name], cashOf(player), dataOf(player)
	if not cfg or not cash or not data then return end
	local owned = data:FindFirstChild("OwnedTrails") or Instance.new("Folder")
	owned.Name = "OwnedTrails"
	owned.Parent = data
	if owned:FindFirstChild(name) then
		player:SetAttribute("EquippedTrail", name)
		return
	end
	if cash.Value < cfg.cash then return end
	cash.Value -= cfg.cash
	local flag = Instance.new("BoolValue")
	flag.Name = name
	flag.Value = true
	flag.Parent = owned
	player:SetAttribute("EquippedTrail", name)
end)

-- Developer Products can be added later for consumables. No permanent upgrade is granted here.
MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

print("MonetizationSystem loaded: permanent Robux upgrades use Game Passes.")
