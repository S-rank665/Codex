--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
local ExperimentService = {}

local function firstLetter(name: string): string?
	local match = string.match(name, "%a")
	return match and string.upper(match) or nil
end

function ExperimentService.BuildAccessoryCode(accessories: {Instance}): string
	table.sort(accessories, function(a, b)
		return (a:GetAttribute("AssetId") or 0) < (b:GetAttribute("AssetId") or 0)
	end)
	local letters = {}
	for _, accessory in ipairs(accessories) do
		local letter = firstLetter(accessory.Name)
		if letter then table.insert(letters, letter) end
	end
	return #letters > 0 and table.concat(letters) or "X"
end

function ExperimentService.GenerateRunDigits(seed: number?): string
	local rng = Random.new(seed or os.time())
	return string.format("%0" .. tostring(Config.RunNumberDigits) .. "d", rng:NextInteger(0, 999999))
end

function ExperimentService.GenerateExperimentNumber(character: Model, runDigits: string): string
	local accessories = {}
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") then table.insert(accessories, child) end
	end
	return ExperimentService.BuildAccessoryCode(accessories) .. "-" .. runDigits
end

function ExperimentService.GetAccessoryEffects(character: Model): {[string]: number}
	local effects = {Hearing = 1, TailPhysics = 0, Accuracy = 1}
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			local lower = string.lower(child.Name)
			if string.find(lower, "ear") or string.find(lower, "furry") then effects.Hearing += 0.1 end
			if string.find(lower, "tail") or string.find(lower, "хвост") then effects.TailPhysics = 1 end
			if string.find(lower, "visor") or string.find(lower, "scope") then effects.Accuracy += 0.05 end
		end
	end
	return effects
end

return ExperimentService
