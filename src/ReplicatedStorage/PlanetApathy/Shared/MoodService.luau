--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
local MoodService = {}

function MoodService.Clamp(value: number): number
	return math.clamp(value, Config.Mood.Min, Config.Mood.Max)
end

function MoodService.CalculateDrift(stats: {[string]: number}, averagePain: number): number
	local drift = 0
	if stats.Hunger < 35 then drift -= 0.09 end
	if stats.Thirst < 35 then drift -= 0.12 end
	if stats.Sickness > 45 then drift -= 0.08 end
	if stats.Brain < 55 then drift -= 0.06 end
	drift -= math.clamp(averagePain / 100, 0, 1) * 0.08
	return drift
end

function MoodService.ShouldRefuse(mood: number, rng: Random?): boolean
	if mood > Config.Mood.LowThreshold then return false end
	return (rng or Random.new()):NextNumber() < Config.Mood.RefusalChance
end

function MoodService.ApplyWalkSpeed(baseSpeed: number, mood: number): number
	if mood <= Config.Mood.LowThreshold then return baseSpeed * Config.Mood.LowWalkSpeedMultiplier end
	return baseSpeed
end

function MoodService.PickRefusalLine(rng: Random?): string
	local r = rng or Random.new()
	return Config.Mood.ActionRefusals[r:NextInteger(1, #Config.Mood.ActionRefusals)]
end

function MoodService.PickGlobalLine(rng: Random?): string
	local r = rng or Random.new()
	return Config.Mood.GlobalLines[r:NextInteger(1, #Config.Mood.GlobalLines)]
end

return MoodService
