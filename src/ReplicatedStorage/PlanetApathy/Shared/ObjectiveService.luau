--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
local ObjectiveService = {}

function ObjectiveService.GetObjective(firstRun: boolean, layer: number): string
	if firstRun then
		if layer < Config.FirstRunGoalLayer then return "Descend and recover corporate equipment." end
		return "Repair generators, wiring, and minor hull breaches before extraction." 
	end
	return "Scan every block, liquid, and creature sample. Extraction is optional because the corporation is distracted."
end

function ObjectiveService.ResolveEnding(state, completed: boolean, distanceFromSite: number): string
	if not completed then return "Failure: cardiac stop or critical collapse." end
	if state.DiedAfterCompletion then return "Memorial statue ending" end
	if distanceFromSite > 700 then return "Good ending, experiment absent" end
	if state.Stats.Mood < -40 then return "Good ending, containment transport" end
	if state.Stats.Brain < 25 then return "Good ending, medical bed" end
	return "Good ending, assisted recovery"
end
return ObjectiveService
