-- MainUI.client.lua
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local hatchResult=remotes:WaitForChild("HatchResult")
local upgradeEvent=remotes:WaitForChild("Upgrade")
local purchaseEvent=remotes:WaitForChild("PurchaseRobux")
local trailEvent=remotes:WaitForChild("BuyTrail")
local TREADMILL_PRICES={[2]={cash=15000,robux=15},[3]={cash=100000,robux=40},[4]={cash=1000000,robux=100},[5]={cash=10000000,robux=250},[6]={cash=100000000,robux=500},[7]={cash=1000000000,robux=1000},[8]={cash=10000000000,robux=2500},[9]={cash=100000000000,robux=5000}}
local gui=Instance.new("ScreenGui");gui.Name="LeoHUD";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local function label(p,t,s,pos,ts)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=t;l.Size=s;l.Position=pos;l.Font=Enum.Font.GothamBold;l.TextSize=ts or 18;l.TextColor3=Color3.new(1,1,1);l.Parent=p;return l end
local panel=Instance.new("Frame");panel.Size=UDim2.fromOffset(280,145);panel.Position=UDim2.fromOffset(16,16);panel.BackgroundColor3=Color3.fromRGB(15,15,20);panel.BackgroundTransparency=.08;panel.Parent=gui;Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
local cashLabel=label(panel,"$0",UDim2.new(1,-20,0,38),UDim2.fromOffset(10,8),28);local zoneLabel=label(panel,"ZONE 1",UDim2.new(1,-20,0,25),UDim2.fromOffset(10,52),18);local slotsLabel=label(panel,"BRAINROTS 0/5",UDim2.new(1,-20,0,25),UDim2.fromOffset(10,80),16);local boostLabel=label(panel,"SPEED x1",UDim2.new(1,-20,0,25),UDim2.fromOffset(10,108),15)
local shop=Instance.new("ScrollingFrame");shop.AnchorPoint=Vector2.new(1,1);shop.Position=UDim2.new(1,-16,1,-16);shop.Size=UDim2.fromOffset(270,470);shop.BackgroundColor3=Color3.fromRGB(12,12,16);shop.BackgroundTransparency=.08;shop.CanvasSize=UDim2.fromOffset(0,1500);shop.ScrollBarThickness=5;shop.Parent=gui;Instance.new("UICorner",shop).CornerRadius=UDim.new(0,12)
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.Parent=shop;local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,8);pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8);pad.Parent=shop
local function cashText(n)if n>=1e12 then return string.format("%.1fT",n/1e12)elseif n>=1e9 then return string.format("%.1fB",n/1e9)elseif n>=1e6 then return string.format("%.1fM",n/1e6)elseif n>=1e3 then return string.format("%.1fK",n/1e3)end return tostring(n)end
local function button(text,cb)local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,42);b.BackgroundColor3=Color3.fromRGB(25,25,32);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=13;b.Text=text;b.Parent=shop;Instance.new("UICorner",b).CornerRadius=UDim.new(0,9);b.Activated:Connect(cb);return b end
local speedButton=button("⚡ TREADMILL",function()local d=player:FindFirstChild("GameData");local s=d and d:FindFirstChild("SpeedLevel");local n=(s and s.Value or 1)+1;if TREADMILL_PRICES[n] then upgradeEvent:FireServer("Speed")end end)
button("⚡ INSTANT SPEED +1 LVL  $1M",function()upgradeEvent:FireServer("InstantSpeed")end)
button("💰 INSTANT MONEY +$1M  /  40R",function()purchaseEvent:FireServer("InstantMoney1M")end)
button("⚡ INSTANT SPEED +1  /  40R",function()purchaseEvent:FireServer("SpeedInstant1M")end)
for m=2,16 do local r=2^(m-1);button(string.format("💎 PERMANENT SPEED x%d  /  %dR",m,r),function()purchaseEvent:FireServer("SpeedX"..m)end)end
local trailCfg={Basic={cash=10000,r=5},Neon={cash=100000,r=15},Plasma={cash=1000000,r=40},Galaxy={cash=10000000,r=100},Void={cash=100000000,r=250}}
for name,cfg in pairs(trailCfg)do button(string.format("✨ TRAIL %s  $%s / %dR",name,cashText(cfg.cash),cfg.r),function()trailEvent:FireServer(name)end)end
local toast=label(gui,"",UDim2.fromOffset(520,45),UDim2.new(.5,-260,.82,0),20);toast.BackgroundColor3=Color3.fromRGB(20,20,25);toast.BackgroundTransparency=.12;Instance.new("UICorner",toast).CornerRadius=UDim.new(0,10)
local function showToast(m)toast.Text=m;task.delay(3,function()if toast then toast.Text=""end end)end
purchaseEvent.OnClientEvent:Connect(function(ok,msg)showToast((ok and "✓ " or "⚠ ")..tostring(msg))end);hatchResult.OnClientEvent:Connect(function(ok,msg)showToast(ok and("🎉 "..msg.." BRAINROT!")or("⚠ "..msg))end)
task.spawn(function()while gui.Parent do local stats=player:FindFirstChild("leaderstats");local data=player:FindFirstChild("GameData");local cash=stats and stats:FindFirstChild("Cash");local zone=data and data:FindFirstChild("Zone");local slots=data and data:FindFirstChild("EggSlots");local brainrots=data and data:FindFirstChild("Brainrots");local mult=player:GetAttribute("SpeedBoostMultiplier")or 1;if cash then cashLabel.Text="$"..cashText(cash.Value)end;if zone then zoneLabel.Text="ZONE "..zone.Value end;if slots and brainrots then slotsLabel.Text="BRAINROTS "..#brainrots:GetChildren().."/"..slots.Value end;boostLabel.Text="SPEED x"..mult;local s=data and data:FindFirstChild("SpeedLevel");local n=(s and s.Value or 1)+1;local p=TREADMILL_PRICES[n];speedButton.Text=p and string.format("⚡ TREADMILL LVL %d  $%s / %dR",n,cashText(p.cash),p.robux)or"⚡ TREADMILL MAX";task.wait(.25)end end)
