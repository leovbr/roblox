-- MonetizationSystem.server.lua
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.GameConfig)

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes" remotes.Parent=ReplicatedStorage
local purchaseEvent=remotes:FindFirstChild("PurchaseRobux") or Instance.new("RemoteEvent") purchaseEvent.Name="PurchaseRobux" purchaseEvent.Parent=remotes
local trailEvent=remotes:FindFirstChild("BuyTrail") or Instance.new("RemoteEvent") trailEvent.Name="BuyTrail" trailEvent.Parent=remotes
local productToAction={}
for action,id in pairs(Config.DEVELOPER_PRODUCTS) do if typeof(id)=="number" and id>0 then productToAction[id]=action end end
local function dataOf(p) return p:FindFirstChild("GameData") end
local function cashOf(p) local s=p:FindFirstChild("leaderstats"); return s and s:FindFirstChild("Cash") end

local function award(player,action)
	local data,cash=dataOf(player),cashOf(player) if not data then return false end
	if action:match("^Treadmill%d+$") then local level=tonumber(action:match("%d+$")); local speed=data:FindFirstChild("SpeedLevel"); if not speed or not level or level~=speed.Value+1 or level>#Config.TREADMILL_SPEEDS then return false end; speed.Value=level; return true end
	if action:match("^SpeedX%d+$") then local multiplier=tonumber(action:match("%d+$")); local boost=Config.SPEED_BOOSTS["X"..multiplier]; local sm=data:FindFirstChild("SpeedMultiplier"); if not boost or not sm or multiplier<=sm.Value then return false end; sm.Value=multiplier; player:SetAttribute("SpeedBoostMultiplier",multiplier); return true end
	if action=="InstantMoney1M" then if not cash then return false end; cash.Value+=Config.INSTANT_MONEY.cash; return true end
	if action=="SpeedInstant1M" then local speed=data:FindFirstChild("SpeedLevel"); if not speed or speed.Value>=#Config.TREADMILL_SPEEDS then return false end; speed.Value+=1; return true end
	if action=="MysticEggZone7" then
		local brainrots=data:FindFirstChild("Brainrots") local slots=data:FindFirstChild("EggSlots")
		if not brainrots or not slots or #brainrots:GetChildren()>=slots.Value then return false end
		local cfg=Config.MYSTIC_EGG_ZONE7
		local b=Instance.new("StringValue") b.Name="Mystic_Celestial_Pink_Dragon_"..tostring(math.floor(os.clock()*1000)) b.Value=cfg.creature
		b:SetAttribute("Tier",cfg.tier) b:SetAttribute("Income",cfg.income) b:SetAttribute("Zone",cfg.zone) b:SetAttribute("Habitat",Config.ZONES[cfg.zone].habitat) b:SetAttribute("EggColor",Config.RARITY_COLORS.Mystic) b:SetAttribute("SizeName","SuperBig") b.Parent=brainrots
		return true
	end
	if action:match("^Trail") then local name=action:sub(6); if not Config.TRAILS[name] then return false end; local owned=data:FindFirstChild("OwnedTrails") or Instance.new("Folder"); owned.Name="OwnedTrails" owned.Parent=data; local flag=owned:FindFirstChild(name); if not flag then flag=Instance.new("BoolValue"); flag.Name=name; flag.Value=true; flag.Parent=owned end; player:SetAttribute("EquippedTrail",name); return true end
	return false
end

purchaseEvent.OnServerEvent:Connect(function(player,action)
	if typeof(action)~="string" then return end local id=Config.DEVELOPER_PRODUCTS[action]
	if typeof(id)~="number" or id<=0 then purchaseEvent:FireClient(player,false,"Product ID belum dipasang: "..action); return end
	MarketplaceService:PromptProductPurchase(player,id)
end)
trailEvent.OnServerEvent:Connect(function(player,name)
	if typeof(name)~="string" then return end local cfg,cash,data=Config.TRAILS[name],cashOf(player),dataOf(player); if not cfg or not cash or not data then return end
	local owned=data:FindFirstChild("OwnedTrails") or Instance.new("Folder"); owned.Name="OwnedTrails" owned.Parent=data
	if owned:FindFirstChild(name) then player:SetAttribute("EquippedTrail",name); return end
	if cash.Value<cfg.cash then return end cash.Value-=cfg.cash local flag=Instance.new("BoolValue"); flag.Name=name flag.Value=true flag.Parent=owned player:SetAttribute("EquippedTrail",name)
end)
MarketplaceService.ProcessReceipt=function(info)
	local player=Players:GetPlayerByUserId(info.PlayerId) if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local action=productToAction[info.ProductId] if not action then return Enum.ProductPurchaseDecision.NotProcessedYet end
	if award(player,action) then return Enum.ProductPurchaseDecision.PurchaseGranted end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
