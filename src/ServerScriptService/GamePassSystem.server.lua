-- GamePassSystem.server.lua
-- Server-authoritative permanent Game Pass ownership and benefits.

local Players=game:GetService("Players")
local MarketplaceService=game:GetService("MarketplaceService")
local Config=require(script.Parent.GameConfig)

local function dataOf(player)return player:FindFirstChild("GameData")end
local function claimFolder(player)local data=dataOf(player);return data and data:FindFirstChild("PassClaims")end
local function claimOnce(player,name)
	local folder=claimFolder(player);if not folder or folder:FindFirstChild(name)then return false end
	local flag=Instance.new("BoolValue");flag.Name=name;flag.Value=true;flag.Parent=folder;return true
end
local function ownsPass(player,id)
	if type(id)~="number"or id<=0 then return false end
	local ok,owns=pcall(function()return MarketplaceService:UserOwnsGamePassAsync(player.UserId,id)end)
	return ok and owns==true
end
local function highestOwned(player,prefix)
	local highest=0
	for action,id in pairs(Config.GAME_PASSES)do
		local n=tonumber(action:match("^"..prefix.."(%d+)$"))
		if n and ownsPass(player,id)and n>highest then highest=n end
	end
	return highest
end

local function grant(player,action)
	local data=dataOf(player);if not data then return end
	local level=tonumber(action:match("^Treadmill(%d+)$"))
	if level then
		local speed=data:FindFirstChild("SpeedLevel")
		if speed then speed.Value=math.max(speed.Value,math.clamp(level,1,#Config.TREADMILL_SPEEDS))end
		return
	end
	local multiplier=tonumber(action:match("^SpeedX(%d+)$"))
	if multiplier then
		local stored=data:FindFirstChild("SpeedMultiplier")
		if stored then stored.Value=math.max(stored.Value,multiplier)end
		player:SetAttribute("SpeedBoostMultiplier",stored and stored.Value or multiplier)
		return
	end
	local trailName=action:match("^Trail(.+)$")
	if trailName and Config.TRAILS[trailName] then
		local owned=data:FindFirstChild("OwnedTrails")
		if owned and not owned:FindFirstChild(trailName)then
			local flag=Instance.new("BoolValue");flag.Name=trailName;flag.Value=true;flag.Parent=owned
		end
		if not player:GetAttribute("EquippedTrail")then player:SetAttribute("EquippedTrail",trailName)end
		return
	end
	if action=="InstantMoney1M"then
		local cash=player:FindFirstChild("leaderstats")and player.leaderstats:FindFirstChild("Cash")
		if cash and claimOnce(player,action)then cash.Value+=Config.INSTANT_MONEY.cash end
		return
	end
	if action=="SpeedInstant1M"then
		local speed=data:FindFirstChild("SpeedLevel")
		if speed and claimOnce(player,action)then speed.Value=math.min(speed.Value+1,#Config.TREADMILL_SPEEDS)end
		return
	end
	if action=="MysticEggZone7"then
		local brainrots=data:FindFirstChild("Brainrots");local slots=data:FindFirstChild("EggSlots")
		if not brainrots or not slots then return end
		for _,brainrot in ipairs(brainrots:GetChildren())do if brainrot:GetAttribute("PassId")==Config.GAME_PASSES.MysticEggZone7 then return end end
		if #brainrots:GetChildren()>=slots.Value then slots.Value+=1 end
		local cfg=Config.MYSTIC_EGG_ZONE7
		local brainrot=Instance.new("StringValue")
		brainrot.Name="Mystic_Celestial_Pink_Dragon_Pass";brainrot.Value=cfg.creature
		brainrot:SetAttribute("Tier",cfg.tier);brainrot:SetAttribute("Income",cfg.income);brainrot:SetAttribute("Zone",cfg.zone)
		brainrot:SetAttribute("Habitat",Config.ZONES[cfg.zone].habitat);brainrot:SetAttribute("EggColor","Mystic")
		brainrot:SetAttribute("SizeName","SuperBig");brainrot:SetAttribute("DisplayScale",1.35)
		brainrot:SetAttribute("PassId",Config.GAME_PASSES.MysticEggZone7);brainrot.Parent=brainrots
	end
end

local function applyAll(player)
	if not dataOf(player)then return end
	local bestTreadmill=highestOwned(player,"Treadmill");if bestTreadmill>0 then grant(player,"Treadmill"..bestTreadmill)end
	local bestSpeed=highestOwned(player,"SpeedX");if bestSpeed>0 then grant(player,"SpeedX"..bestSpeed)end
	for action,id in pairs(Config.GAME_PASSES)do
		if not action:match("^Treadmill%d+$")and not action:match("^SpeedX%d+$")and ownsPass(player,id)then grant(player,action)end
	end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		repeat task.wait()until player:FindFirstChild("GameData")or not player.Parent
		if player.Parent then applyAll(player)end
	end)
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
	if not purchased then return end
	for action,id in pairs(Config.GAME_PASSES)do if id==passId then grant(player,action);break end end
end)
for _,player in ipairs(Players:GetPlayers())do task.spawn(function()applyAll(player)end)end
print("GamePassSystem loaded: 24 permanent passes.")
