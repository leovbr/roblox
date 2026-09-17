-- OwnerAdmin.server.lua
-- Server-authoritative owner-only event/gift tools.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

-- Replace with the owner's Roblox UserId before publishing.
local OWNER_USER_IDS={
	[0]=true,
}

local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes" remotes.Parent=ReplicatedStorage
local admin=remotes:FindFirstChild("OwnerAdmin") or Instance.new("RemoteEvent")
admin.Name="OwnerAdmin" admin.Parent=remotes

local function isOwner(player) return OWNER_USER_IDS[player.UserId]==true end
local function findPlayer(text)
	if typeof(text)~="string" then return nil end
	text=string.lower(text)
	for _,p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name)==text or string.lower(p.DisplayName)==text then return p end
	end
end
local function cash(p,amount)
	local s=p:FindFirstChild("leaderstats"); local c=s and s:FindFirstChild("Cash")
	if c then c.Value=math.max(0,c.Value+amount) end
end
local function speed(p,amount)
	local d=p:FindFirstChild("GameData"); local v=d and d:FindFirstChild("SpeedLevel")
	if v then v.Value=math.clamp(v.Value+amount,1,1000) end
end

admin.OnServerEvent:Connect(function(owner,action,targetName,value)
	if not isOwner(owner) or typeof(action)~="string" then return end
	local target=findPlayer(targetName)
	if action=="EventSpeedAll" then
		local amount=math.clamp(tonumber(value) or 1,1,100)
		for _,p in ipairs(Players:GetPlayers()) do speed(p,amount) end
	elseif action=="GiveSpeed" and target then
		speed(target,math.clamp(tonumber(value) or 1,1,100))
	elseif action=="GiveCash" and target then
		cash(target,math.clamp(math.floor(tonumber(value) or 0),0,1000000000000))
	elseif action=="GiveGift" and target then
		local gift=Instance.new("StringValue") gift.Name="Gift_"..os.time() gift.Value=tostring(value or "Mystery Gift") gift.Parent=target
		target:SetAttribute("LastGift",gift.Value)
	elseif action=="EventCashAll" then
		local amount=math.clamp(math.floor(tonumber(value) or 0),0,1000000000000)
		for _,p in ipairs(Players:GetPlayers()) do cash(p,amount) end
	end
end)

Players.PlayerAdded:Connect(function(player)
	if isOwner(player) then player:SetAttribute("IsOwner",true) end
end)
for _,p in ipairs(Players:GetPlayers()) do if isOwner(p) then p:SetAttribute("IsOwner",true) end end

print("OwnerAdmin loaded: owner-only event, speed, cash, and gift controls.")
