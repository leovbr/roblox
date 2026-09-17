local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local admin=remotes:WaitForChild("OwnerAdmin")
local gui=Instance.new("ScreenGui");gui.Name="OwnerPanel";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local toggle=Instance.new("TextButton");toggle.Size=UDim2.fromOffset(52,52);toggle.Position=UDim2.new(0,16,1,-70);toggle.Text="👑";toggle.TextSize=24;toggle.Font=Enum.Font.GothamBold;toggle.BackgroundColor3=Color3.fromRGB(20,20,26);toggle.TextColor3=Color3.new(1,1,1);toggle.Visible=false;toggle.Parent=gui;Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,14)
local panel=Instance.new("Frame");panel.Size=UDim2.fromOffset(360,590);panel.Position=UDim2.new(0,78,0.5,-295);panel.BackgroundColor3=Color3.fromRGB(10,10,14);panel.Visible=false;panel.Parent=gui;Instance.new("UICorner",panel).CornerRadius=UDim.new(0,18)
local title=Instance.new("TextLabel",panel);title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(18,12);title.Size=UDim2.new(1,-36,0,34);title.Text="👑 OWNER GOD PANEL";title.Font=Enum.Font.GothamBlack;title.TextSize=20;title.TextColor3=Color3.new(1,1,1);title.TextXAlignment=Enum.TextXAlignment.Left
local sub=Instance.new("TextLabel",panel);sub.BackgroundTransparency=1;sub.Position=UDim2.fromOffset(18,44);sub.Size=UDim2.new(1,-36,0,22);sub.Text="Server control • Cross-server control";sub.Font=Enum.Font.Gotham;sub.TextSize=12;sub.TextColor3=Color3.fromRGB(170,170,180);sub.TextXAlignment=Enum.TextXAlignment.Left
local scroll=Instance.new("ScrollingFrame",panel);scroll.Position=UDim2.fromOffset(14,74);scroll.Size=UDim2.new(1,-28,1,-88);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=4;scroll.CanvasSize=UDim2.fromOffset(0,900)
local layout=Instance.new("UIListLayout",scroll);layout.Padding=UDim.new(0,8)
local pad=Instance.new("UIPadding",scroll);pad.PaddingLeft=UDim.new(0,3);pad.PaddingRight=UDim.new(0,3);pad.PaddingBottom=UDim.new(0,12)
local function box(placeholder,value)local b=Instance.new("TextBox");b.Size=UDim2.new(1,0,0,38);b.BackgroundColor3=Color3.fromRGB(25,25,32);b.TextColor3=Color3.new(1,1,1);b.PlaceholderColor3=Color3.fromRGB(125,125,135);b.PlaceholderText=placeholder;b.Text=value or "";b.Font=Enum.Font.Gotham;b.TextSize=13;b.ClearTextOnFocus=false;b.Parent=scroll;Instance.new("UICorner",b).CornerRadius=UDim.new(0,9);return b end
local function btn(text,cb)local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,40);b.BackgroundColor3=Color3.fromRGB(28,28,36);b.TextColor3=Color3.new(1,1,1);b.Text=text;b.Font=Enum.Font.GothamBold;b.TextSize=13;b.Parent=scroll;Instance.new("UICorner",b).CornerRadius=UDim.new(0,9);b.Activated:Connect(cb);return b end
local function section(text)local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,25);l.BackgroundTransparency=1;l.Text=text;l.Font=Enum.Font.GothamBlack;l.TextSize=13;l.TextColor3=Color3.fromRGB(210,210,220);l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=scroll end
local message=box("Message / announcement...")
section("📢 CHAT / ANNOUNCEMENT")
btn("💬 ONLY THIS SERVER",function()admin:FireServer("ServerMessage",{text=message.Text})end)
btn("🌎 ALL SERVERS",function()admin:FireServer("GlobalMessage",{text=message.Text})end)
section("⚡ TEMPORARY ADMIN SPEED")
local multiplier=box("Speed multiplier, e.g. 20","20")
local duration=box("Duration in seconds, e.g. 60","60")
btn("⚡ SERVER: SPEED x MULTIPLIER",function()admin:FireServer("ServerSpeed",{multiplier=tonumber(multiplier.Text),duration=tonumber(duration.Text)})end)
btn("🌎 ALL SERVERS: SPEED x MULTIPLIER",function()admin:FireServer("GlobalSpeed",{multiplier=tonumber(multiplier.Text),duration=tonumber(duration.Text)})end)
section("💰 ADMIN CASH")
local amount=box("Cash to give each player","1000000")
btn("💰 SERVER: GIVE CASH TO ALL",function()admin:FireServer("ServerCash",{amount=tonumber(amount.Text)})end)
btn("🌎 ALL SERVERS: GIVE CASH TO ALL",function()admin:FireServer("GlobalCash",{amount=tonumber(amount.Text)})end)
section("🛠 OWNER NOTE")
local note=Instance.new("TextLabel");note.Size=UDim2.new(1,0,0,55);note.BackgroundTransparency=1;note.TextWrapped=true;note.Text="Owner-only and server-authoritative. Global commands use MessagingService. Replace OWNER_USER_IDS with your Roblox UserId.";note.Font=Enum.Font.Gotham;note.TextSize=11;note.TextColor3=Color3.fromRGB(145,145,155);note.Parent=scroll
local function refresh()local on=player:GetAttribute("IsOwner")==true;toggle.Visible=on;if not on then panel.Visible=false end end
player:GetAttributeChangedSignal("IsOwner"):Connect(refresh)
toggle.Activated:Connect(function()panel.Visible=not panel.Visible end)
refresh()
