--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Root = ReplicatedStorage:WaitForChild("PlanetApathy")
local Config = require(Root.Config.GameConfig)
local ExperimentService = require(Root.Shared.ExperimentService)
local HealthService = require(Root.Shared.HealthService)
local MoodService = require(Root.Shared.MoodService)
local BloodService = require(Root.Shared.BloodService)
local WorldGenerationService = require(Root.Shared.WorldGenerationService)

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = Root
local dialogueRemote = Instance.new("RemoteEvent"); dialogueRemote.Name = "Dialogue"; dialogueRemote.Parent = remotes
local actionRemote = Instance.new("RemoteFunction"); actionRemote.Name = "AttemptApatheticAction"; actionRemote.Parent = remotes
local bloodRemote = Instance.new("RemoteFunction"); bloodRemote.Name = "ChooseBloodColor"; bloodRemote.Parent = remotes

local playerStates = {}
local worldFolder = Instance.new("Folder")
worldFolder.Name = "GeneratedPlanetLayers"
worldFolder.Parent = workspace
WorldGenerationService.BuildLayerModel(1, os.time() % 100000, worldFolder)

local function setupCharacter(player: Player, character: Model)
	local runDigits = player:GetAttribute("RunDigits") or ExperimentService.GenerateRunDigits(player.UserId + os.time())
	player:SetAttribute("RunDigits", runDigits)
	local state = HealthService.NewState()
	state.ExperimentNumber = ExperimentService.GenerateExperimentNumber(character, runDigits)
	state.BloodColor = Config.Blood.DefaultPlayerColor
	playerStates[player] = state
	player:SetAttribute("ExperimentNumber", state.ExperimentNumber)
	player:SetAttribute("BloodColor", state.BloodColor:ToHex())
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.CameraOffset = Vector3.new(0, 1.2, 0)
		humanoid.WalkSpeed = MoodService.ApplyWalkSpeed(16, state.Stats.Mood)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character) setupCharacter(player, character) end)
end)

bloodRemote.OnServerInvoke = function(player: Player, color: Color3)
	local clean, ok = BloodService.SanitizePlayerBloodColor(color)
	local state = playerStates[player]
	if state then state.BloodColor = clean end
	player:SetAttribute("BloodColor", clean:ToHex())
	return ok, clean
end

actionRemote.OnServerInvoke = function(player: Player, actionName: string)
	local state = playerStates[player]
	if not state then return true end
	local rng = Random.new(os.clock() * 1000)
	if MoodService.ShouldRefuse(state.Stats.Mood, rng) then
		local line = MoodService.PickRefusalLine(rng)
		dialogueRemote:FireClient(player, line)
		return false, line
	end
	return true
end

local dialogueTimers = {}
RunService.Heartbeat:Connect(function(dt)
	for player, state in pairs(playerStates) do
		local alive = HealthService.Tick(state, dt)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = MoodService.ApplyWalkSpeed(16, state.Stats.Mood) end
		dialogueTimers[player] = (dialogueTimers[player] or 0) + dt
		if state.Stats.Mood <= Config.Mood.LowThreshold and dialogueTimers[player] >= Config.Mood.DialogueInterval then
			dialogueTimers[player] = 0
			dialogueRemote:FireClient(player, MoodService.PickGlobalLine())
		end
		if not alive then player:Kick("Run ended: critical corporate asset failure.") end
	end
end)
