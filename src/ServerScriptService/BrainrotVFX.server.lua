-- BrainrotVFX.server.lua
-- Lightweight server animation for visible Brainrots.
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")
local function animate(model)
	if model:GetAttribute("VFXStarted") then return end
	model:SetAttribute("VFXStarted",true)
	task.spawn(function()
		local base=model:GetPivot()
		while model.Parent do
			local up=base*CFrame.new(0,.35,0)*CFrame.Angles(0,math.rad(4),0)
			local down=base*CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(-4),0)
			local info=TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
			local value=Instance.new("CFrameValue"); value.Value=model:GetPivot(); value:GetPropertyChangedSignal("Value"):Connect(function() if model.Parent then model:PivotTo(value.Value) end end)
			TweenService:Create(value,info,{Value=up}):Play(); task.wait(1.1)
			TweenService:Create(value,info,{Value=down}):Play(); task.wait(1.1); value:Destroy()
		end
	end)
end
local folder=Workspace:WaitForChild("Brainrots",20)
if folder then for _,m in ipairs(folder:GetChildren()) do animate(m) end; folder.ChildAdded:Connect(function(m) task.wait(.1); animate(m) end) end
print("BrainrotVFX loaded: idle bob animation.")
