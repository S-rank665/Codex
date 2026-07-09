--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
local BloodService = {}

function BloodService.IsForbiddenRed(color: Color3): boolean
	local h, s, v = color:ToHSV()
	local redHue = h >= Config.Blood.RedHueMin or h <= Config.Blood.RedHueMax
	return redHue and s >= Config.Blood.MinSaturationForRedBan and v >= Config.Blood.MinValueForRedBan
end

function BloodService.SanitizePlayerBloodColor(color: Color3): (Color3, boolean)
	if not BloodService.IsForbiddenRed(color) then return color, true end
	return Config.Blood.DefaultPlayerColor, false
end

function BloodService.ForMood(color: Color3, mood: number): Color3
	if mood >= Config.Mood.LowThreshold then return color end
	return color:Lerp(Color3.fromRGB(210, 210, 190), Config.Blood.LowMoodFade)
end

function BloodService.Mix(a: Color3, b: Color3): Color3
	local mixed = Color3.new((a.R + b.R) / 2, (a.G + b.G) / 2, (a.B + b.B) / 2)
	return BloodService.SanitizePlayerBloodColor(mixed)
end

return BloodService
