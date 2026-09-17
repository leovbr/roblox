local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MessagingService=game:GetService("MessagingService")
local HttpService=game:GetService("HttpService")

-- Leo / @Leovbriansyh
local OWNER_USER_IDS={[5703800829]=true}
local TOPIC="CuriBrainrot_OwnerPower_v1"
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes" remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("OwnerAdmin") or Instance.new("RemoteEvent")
remote.Name="OwnerAdmin" remote.Parent=remotes
local announceRemote=remotes:FindFirstChild("AdminAnnouncement") or Instance.new("RemoteEvent")
announceRemote.Name="AdminAnnouncement" announceRemote.Parent=remotes
local active={}
local seen={}
local function owner(p)return OWNER_USER_IDS[p.UserId]==true end
local function announce(text,global) announceRemote:FireAllClients(string.sub(tostring(text or ""),1,220),global==true) end
local function cash(p,n)local s=p:FindFirstChild("leaderstats");local c=s and s:FindFirstChild("Cash");if c then c.Value=math.max(0,c.Value+math.clamp(math.floor(tonumber(n)or 0),0,1e15))end end
local function speed(p,m,d)
 m=math.clamp(tonumber(m)or 1,1,100);d=math.clamp(tonumber(d)or 30,1,3600)
 local token=HttpService:GenerateGUID(false);active[p]=token;p:SetAttribute("AdminSpeedMultiplier",m)
 local function apply(char)local h=char and char:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16*m end end
 apply(p.Character)
 task.delay(d,function()if active[p]~=token then return end;active[p]=nil;p:SetAttribute("AdminSpeedMultiplier",nil);apply(p.Character)end)
end
local function execute(data,global)
 if typeof(data)~="table" then return end
 if data.id and seen[data.id] then return end
 if data.id then seen[data.id]=true end
 if data.action=="message" then announce(data.text,global)
 elseif data.action=="speed" then for _,p in ipairs(Players:GetPlayers())do speed(p,data.multiplier,data.duration)end
 elseif data.action=="cash" then for _,p in ipairs(Players:GetPlayers())do cash(p,data.amount)end end
end
local function publish(data)
 data.id=HttpService:GenerateGUID(false)
 local ok,err=pcall(function()MessagingService:PublishAsync(TOPIC,data)end)
 if not ok then warn("Global admin publish failed:",err)end
end
pcall(function()MessagingService:SubscribeAsync(TOPIC,function(msg)execute(msg.Data,true)end)end)
Players.PlayerAdded:Connect(function(p)
 if owner(p)then p:SetAttribute("IsOwner",true)end
 p.CharacterAdded:Connect(function(char)task.wait(.15);local m=p:GetAttribute("AdminSpeedMultiplier");if m then local h=char:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16*m end end end)
end)
for _,p in ipairs(Players:GetPlayers())do if owner(p)then p:SetAttribute("IsOwner",true)end end
remote.OnServerEvent:Connect(function(p,action,data)
 if not owner(p)or typeof(action)~="string" then return end
 data=typeof(data)=="table" and data or {}
 if action=="ServerMessage" then execute({action="message",text=data.text},false)
 elseif action=="GlobalMessage" then local x={action="message",text=data.text};execute(x,false);publish(x)
 elseif action=="ServerSpeed" then execute({action="speed",multiplier=data.multiplier,duration=data.duration},false)
 elseif action=="GlobalSpeed" then local x={action="speed",multiplier=data.multiplier,duration=data.duration};execute(x,false);publish(x)
 elseif action=="ServerCash" then execute({action="cash",amount=data.amount},false)
 elseif action=="GlobalCash" then local x={action="cash",amount=data.amount};execute(x,false);publish(x) end
end)
print("GlobalAdmin loaded")
