-- TrapPositionFix.server.lua
-- Positions trap pads from each base Floor so no PrimaryPart is required.
local Workspace=game:GetService("Workspace")
local bases=Workspace:WaitForChild("Bases",20)
if bases then
	for _,base in ipairs(bases:GetChildren()) do
		local floor=base:FindFirstChild("Floor"); local traps=base:FindFirstChild("Traps")
		if floor and traps then
			local spots={Vector3.new(-12,1.2,9),Vector3.new(0,1.2,12),Vector3.new(12,1.2,9)}
			for i=1,3 do local t=traps:FindFirstChild("Trap_"..i); if t then t.Position=floor.Position+spots[i] end end
		end
	end
	bases.ChildAdded:Connect(function(base)
		task.wait(.2); local floor=base:FindFirstChild("Floor"); local traps=base:FindFirstChild("Traps"); if not floor or not traps then return end
		for i,pos in ipairs({Vector3.new(-12,1.2,9),Vector3.new(0,1.2,12),Vector3.new(12,1.2,9)}) do local t=traps:FindFirstChild("Trap_"..i); if t then t.Position=floor.Position+pos end end
	end)
end
