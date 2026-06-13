--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
local MoodService = require(script.Parent.MoodService)
local HealthService = {}

function HealthService.NewState()
	local state = {Stats = table.clone(Config.Stats), Parts = {}}
	for _, name in ipairs(Config.BodyParts) do
		state.Parts[name] = {Muscle=100, Infection=0, Pain=0, Skin=100, Bleeding=0, Amputated=false}
	end
	return state
end

function HealthService.AveragePain(state): number
	local total, count = 0, 0
	for _, part in pairs(state.Parts) do
		if not part.Amputated then total += part.Pain; count += 1 end
	end
	return count == 0 and 0 or total / count
end

function HealthService.Tick(state, dt: number)
	local stats = state.Stats
	stats.Hunger = math.max(0, stats.Hunger - 0.015 * dt)
	stats.Thirst = math.max(0, stats.Thirst - 0.025 * dt)
	stats.Mood = MoodService.Clamp(stats.Mood + MoodService.CalculateDrift(stats, HealthService.AveragePain(state)) * dt)
	if stats.Sickness >= 100 then stats.Hunger = math.max(0, stats.Hunger - 8); stats.Thirst = math.max(0, stats.Thirst - 8); stats.Sickness = 70 end
	for _, part in pairs(state.Parts) do
		if part.Infection > 70 then part.Muscle = math.max(0, part.Muscle - 0.02 * dt) end
		if part.Pain > 30 then part.Pain = math.min(100, part.Pain + 0.004 * dt) end
		if part.Bleeding > 0 then stats.Stamina = math.max(0, stats.Stamina - part.Bleeding * 0.001 * dt) end
	end
	return not (stats.Radiation >= 100 or state.Parts.Chest.Infection >= 100 or stats.Brain <= 0)
end

function HealthService.HighlightColor(part): Color3
	if part.Bleeding and part.Bleeding > 0 then return Color3.fromRGB(170, 0, 0) end
	if part.Pain and part.Pain > 15 then return Color3.fromRGB(255, 45, 45) end
	return Color3.fromRGB(0, 0, 0)
end

return HealthService
