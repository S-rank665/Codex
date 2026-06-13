--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local Root = ReplicatedStorage:WaitForChild("PlanetApathy")
local Config = require(Root.Config.GameConfig)
local ExperimentService = require(Root.Shared.ExperimentService)
local HealthService = require(Root.Shared.HealthService)
local MoodService = require(Root.Shared.MoodService)
local BloodService = require(Root.Shared.BloodService)
local WorldGenerationService = require(Root.Shared.WorldGenerationService)
local DebugCatalog = require(Root.Shared.DebugCatalog)

pcall(function() TextChatService.ChatWindowConfiguration.Enabled = false end)

local remotes = Root:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = Root
local dialogueRemote = remotes:FindFirstChild("Dialogue") or Instance.new("RemoteEvent")
dialogueRemote.Name = "Dialogue"; dialogueRemote.Parent = remotes
local actionRemote = remotes:FindFirstChild("AttemptApatheticAction") or Instance.new("RemoteFunction")
actionRemote.Name = "AttemptApatheticAction"; actionRemote.Parent = remotes
local bloodRemote = remotes:FindFirstChild("ChooseBloodColor") or Instance.new("RemoteFunction")
bloodRemote.Name = "ChooseBloodColor"; bloodRemote.Parent = remotes
local stateRemote = remotes:FindFirstChild("StateUpdate") or Instance.new("RemoteEvent")
stateRemote.Name = "StateUpdate"; stateRemote.Parent = remotes
local adminRemote = remotes:FindFirstChild("AdminCommand") or Instance.new("RemoteFunction")
adminRemote.Name = "AdminCommand"; adminRemote.Parent = remotes

local playerStates = {}
local currentLayer = 1
local workspaceRoot = workspace:FindFirstChild("PlanetApathyWorkspace") or Instance.new("Folder")
workspaceRoot.Name = "PlanetApathyWorkspace"
workspaceRoot.Parent = workspace
local worldFolder = workspaceRoot:FindFirstChild("GeneratedPlanetLayers") or Instance.new("Folder")
worldFolder.Name = "GeneratedPlanetLayers"
worldFolder.Parent = workspaceRoot
WorldGenerationService.BuildLayerModel(currentLayer, os.time() % 100000, worldFolder)

local function isConfiguredAdmin(userId: number): boolean
	for _, id in ipairs(Config.AdminUserIds) do
		if id == userId then return true end
	end
	return false
end

local function isAdmin(player: Player): boolean
	if isConfiguredAdmin(player.UserId) then return true end
	if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then return true end
	if Config.AdminGroup.UseExperienceGroup and game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function() return player:GetRankInGroup(game.CreatorId) end)
		return ok and rank >= Config.AdminGroup.MinRank
	end
	return false
end

local function publicStateFor(player: Player)
	local state = playerStates[player]
	if not state then return nil end
	return {
		ExperimentNumber = state.ExperimentNumber,
		BloodColor = state.BloodColor,
		Stats = state.Stats,
		Parts = state.Parts,
		Layer = currentLayer,
		Objective = state.Objective,
		IsAdmin = isAdmin(player),
		DebugCatalog = DebugCatalog,
	}
end

local function pushState(player: Player)
	local public = publicStateFor(player)
	if public then stateRemote:FireClient(player, public) end
end

local function setupCharacter(player: Player, character: Model)
	local runDigits = player:GetAttribute("RunDigits") or ExperimentService.GenerateRunDigits(player.UserId + os.time())
	player:SetAttribute("RunDigits", runDigits)
	local state = HealthService.NewState()
	state.ExperimentNumber = ExperimentService.GenerateExperimentNumber(character, runDigits)
	state.BloodColor = Config.Blood.DefaultPlayerColor
	state.Objective = "Descend into the planet, recover the equipment, and prove the corporation had a terrible idea."
	playerStates[player] = state
	player:SetAttribute("ExperimentNumber", state.ExperimentNumber)
	player:SetAttribute("BloodColor", state.BloodColor:ToHex())
	player:SetAttribute("IsPlanetApathyAdmin", isAdmin(player))
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.CameraOffset = Vector3.new(0, 1.2, 0)
		humanoid.WalkSpeed = MoodService.ApplyWalkSpeed(16, state.Stats.Mood)
	end
	pushState(player)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character) setupCharacter(player, character) end)
end)

bloodRemote.OnServerInvoke = function(player: Player, color: Color3)
	local clean, ok = BloodService.SanitizePlayerBloodColor(color)
	local state = playerStates[player]
	if state then state.BloodColor = clean end
	player:SetAttribute("BloodColor", clean:ToHex())
	pushState(player)
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

local function spawnDebugItem(player: Player, itemId: string): (boolean, string)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false, "No character root" end
	local selected = DebugCatalog.SpawnableItems[1]
	for _, item in ipairs(DebugCatalog.SpawnableItems) do
		if item.Id == itemId then selected = item end
	end
	local itemTemplates = workspaceRoot:FindFirstChild("ItemTemplates")
	local template = itemTemplates and itemTemplates:FindFirstChild(selected.TemplateName or "")
	local part = template and template:Clone() or Instance.new("Part")
	part.Name = selected.Name
	part.Size = Vector3.new(2, 1, 2)
	part.Position = rootPart.Position + Vector3.new(0, Config.Debug.SpawnHeight, 0)
	part.Color = selected.Color
	part.Anchored = false
	part:SetAttribute("ItemId", selected.Id)
	part:SetAttribute("Kind", selected.Kind)
	part.Parent = workspace
	return true, "Spawned " .. selected.Name
end

adminRemote.OnServerInvoke = function(player: Player, command: string, payload)
	if not Config.Debug.Enabled or not isAdmin(player) then return false, "Admin debug is unavailable" end
	local state = playerStates[player]
	if not state then return false, "No run state" end
	if command == "Mood" then
		state.Stats.Mood = MoodService.Clamp(state.Stats.Mood + (payload or 0))
	elseif command == "Damage" then
		state.Parts.Chest.Pain = math.clamp(state.Parts.Chest.Pain + 15, 0, 100)
		state.Stats.Mood = MoodService.Clamp(state.Stats.Mood - 10)
	elseif command == "Heal" then
		state.Stats = table.clone(Config.Stats)
		for _, part in pairs(state.Parts) do
			part.Muscle = 100; part.Infection = 0; part.Pain = 0; part.Skin = 100; part.Bleeding = 0; part.Amputated = false
		end
	elseif command == "NextLayer" then
		currentLayer = math.min(currentLayer + 1, #Config.Layers)
		worldFolder:ClearAllChildren()
		WorldGenerationService.BuildLayerModel(currentLayer, os.time() % 100000, worldFolder)
	elseif command == "SpawnItem" then
		local ok, message = spawnDebugItem(player, tostring(payload))
		pushState(player)
		return ok, message
	elseif command == "Dialogue" then
		dialogueRemote:FireClient(player, tostring(payload or "The experiment sighs in corporate-approved confusion."))
	elseif command == "Minigame" then
		state.Objective = "Debug minigame loaded: " .. tostring(payload)
	elseif command == "StructureRole" then
		state.Objective = "Debug structure role selected: " .. tostring(payload)
	else
		return false, "Unknown command"
	end
	pushState(player)
	return true, "OK"
end

local dialogueTimers = {}
local stateTimers = {}
RunService.Heartbeat:Connect(function(dt)
	for player, state in pairs(playerStates) do
		local alive = HealthService.Tick(state, dt)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = MoodService.ApplyWalkSpeed(16, state.Stats.Mood) end
		dialogueTimers[player] = (dialogueTimers[player] or 0) + dt
		stateTimers[player] = (stateTimers[player] or 0) + dt
		if state.Stats.Mood <= Config.Mood.LowThreshold and dialogueTimers[player] >= Config.Mood.DialogueInterval then
			dialogueTimers[player] = 0
			dialogueRemote:FireClient(player, MoodService.PickGlobalLine())
		end
		if stateTimers[player] >= 1 then
			stateTimers[player] = 0
			pushState(player)
		end
		if not alive then player:Kick("Run ended: critical corporate asset failure.") end
	end
end)
