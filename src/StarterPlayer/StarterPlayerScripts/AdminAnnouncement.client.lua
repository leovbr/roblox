local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local event=remotes:WaitForChild("AdminAnnouncement")
local gui=Instance.new("ScreenGui");gui.Name="AdminAnnouncements";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(.5,0);frame.Position=UDim2.new(.5,0,-.2,0);frame.Size=UDim2.new(.8,0,0,72);frame.BackgroundColor3=Color3.fromRGB(12,12,16);frame.Visible=false;frame.Parent=gui;Instance.new("UICorner",frame).CornerRadius=UDim.new(0,16)
local text=Instance.new("TextLabel",frame);text.BackgroundTransparency=1;text.Size=UDim2.new(1,-24,1,-16);text.Position=UDim2.fromOffset(12,8);text.TextColor3=Color3.new(1,1,1);text.TextWrapped=true;text.Font=Enum.Font.GothamBold;text.TextSize=17;text.Text=""
event.OnClientEvent:Connect(function(msg,global)
 text.Text=(global and "🌎 GLOBAL • " or "📢 SERVER • ")..tostring(msg);frame.Visible=true
 TweenService:Create(frame,TweenInfo.new(.3,Enum.EasingStyle.Back),{Position=UDim2.new(.5,0,0,18)}):Play()
 task.delay(5,function()if frame.Visible then TweenService:Create(frame,TweenInfo.new(.25),{Position=UDim2.new(.5,0,-.2,0)}):Play();task.wait(.3);frame.Visible=false end end)
end)
