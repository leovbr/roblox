-- DayNight.server.lua
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local DAY_LENGTH = 240
local NIGHT_LENGTH = 10
local TOTAL_LENGTH = DAY_LENGTH + NIGHT_LENGTH
local clock = 8

RunService.Heartbeat:Connect(function(dt)
	clock = (clock + (24 / TOTAL_LENGTH) * dt) % 24
	Lighting.ClockTime = clock
end)

Lighting.ClockTime = clock
Lighting.Brightness = 2
Lighting.GlobalShadows = true
