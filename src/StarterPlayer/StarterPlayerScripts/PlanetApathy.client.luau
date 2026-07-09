--!strict
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local Root = ReplicatedStorage:WaitForChild("PlanetApathy")
local Config = require(Root.Config.GameConfig)
local ChatService = require(Root.Shared.ChatService)
local BloodService = require(Root.Shared.BloodService)
local AnimationService = require(Root.Shared.AnimationService)
local remotes = Root:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("StateUpdate") :: RemoteEvent
local adminRemote = remotes:WaitForChild("AdminCommand") :: RemoteFunction
local pickupRemote = remotes:WaitForChild("PickupItem") :: RemoteFunction
local actionRemote = remotes:WaitForChild("AttemptApatheticAction") :: RemoteFunction

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
player.CameraMode = Config.Camera.Mode
player.CameraMinZoomDistance = Config.Camera.MinZoomDistance
player.CameraMaxZoomDistance = Config.Camera.MaxZoomDistance

local gui = player:WaitForChild("PlayerGui"):WaitForChild("PlanetApathyGui")
local openMenu: string? = nil
local latestState = nil
local activeMovementTrack: AnimationTrack? = nil
local activeMovementName: string? = nil
local ragdollEnabled = false

local function panel(name: string): GuiObject?
	local found = gui:FindFirstChild(name)
	return found and found:IsA("GuiObject") and found or nil
end

local function setOnlyPanel(name: string?)
	openMenu = name
	for _, child in ipairs(gui:GetChildren()) do
		if child:IsA("GuiObject") and string.find(child.Name, "Panel") then
			child.Visible = child.Name == openMenu
		end
	end
	local adminButton = gui:FindFirstChild("AdminOpenButton")
	if adminButton and adminButton:IsA("GuiObject") then
		adminButton.Visible = player:GetAttribute("IsPlanetApathyAdmin") == true
	end
end

local function toggleMenu(name: string)
	local existing = panel(name)
	if existing and existing.Visible then
		setOnlyPanel(nil)
	else
		setOnlyPanel(name)
	end
end

local function updateText(pathName: string, value: string)
	local target = gui:FindFirstChild(pathName, true)
	if target and target:IsA("TextLabel") then target.Text = value end
end

local function updateAdminStatus(value: string)
	updateText("AdminStatus", value)
end

local function invokeAdmin(command: string, payload: any?)
	local ok, result = adminRemote:InvokeServer(command, payload)
	updateAdminStatus((ok and "OK: " or "NO: ") .. tostring(result))
end


ContextActionService:BindActionAtPriority("PlanetApathyRightMousePickup", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		local mouse = player:GetMouse()
		local target = mouse.Target
		if target and target:GetAttribute("ItemId") then
			local ok, message = pickupRemote:InvokeServer(target)
			updateAdminStatus((ok and "Pickup: " or "Pickup failed: ") .. tostring(message))
		end
	end
	return Enum.ContextActionResult.Sink
end, false, 3000, Enum.UserInputType.MouseButton2)

local adminButtons = {
	MoodPlus = {"Mood", 20},
	MoodMinus = {"Mood", -20},
	Damage = {"Damage", nil},
	Heal = {"Heal", nil},
	NextLayer = {"NextLayer", nil},
	Dialogue = {"Dialogue", "This is a test dialogue bubble."},
	SpawnMedkit = {"SpawnItem", "test_medkit"},
	SpawnFood = {"SpawnItem", "test_food"},
	SpawnTool = {"SpawnItem", "test_tool"},
	SpawnScanner = {"SpawnItem", "test_scanner"},
	StructureEditor = {"StructureRole", "Structure"},
	MinigameTest = {"Minigame", "Bandage wrap timing"},
}

for buttonName, commandInfo in pairs(adminButtons) do
	local button = gui:FindFirstChild(buttonName, true)
	if button and button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			invokeAdmin(commandInfo[1], commandInfo[2])
			if buttonName == "StructureEditor" then setOnlyPanel("StructureEditorPanel") end
			if buttonName == "MinigameTest" then setOnlyPanel("MinigamePanel") end
			if string.sub(buttonName, 1, 5) == "Spawn" then setOnlyPanel("ItemSpawnPanel") end
		end)
	end
end

local adminOpenButton = gui:FindFirstChild("AdminOpenButton")
if adminOpenButton and adminOpenButton:IsA("TextButton") then
	adminOpenButton.MouseButton1Click:Connect(function()
		if player:GetAttribute("IsPlanetApathyAdmin") == true then toggleMenu("AdminPanel") end
	end)
end

local function updateHealthUi(state)
	updateText("ExperimentNumber", "Experiment " .. tostring(state.ExperimentNumber))
	updateText("Objective", tostring(state.Objective))
	updateText("LayerStatus", "Layer " .. tostring(state.Layer))
	for name, value in pairs(state.Stats) do
		local rowName = name .. "Row"
		if type(value) == "number" then
			updateText(rowName, string.format("  %s: %.1f", name, value))
		else
			updateText(rowName, "  " .. name .. ": " .. tostring(value))
		end
	end
	for partName, partState in pairs(state.Parts) do
		local text = string.format("%s  Muscle:%d Pain:%d Inf:%d Skin:%d", partState.Amputated and "MISSING" or partName, partState.Muscle, partState.Pain, partState.Infection, partState.Skin)
		updateText(partName .. "Part", text)
	end
	if state.Inventory then
		for _, slotName in ipairs(Config.InventorySlots) do
			local button = gui:FindFirstChild(slotName, true)
			local item = state.Inventory[slotName]
			if button and button:IsA("TextButton") then
				button.Text = slotName .. "\n" .. (item and item.Name or "(empty)")
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Config.Controls.Inventory then toggleMenu("InventoryPanel") end
	if input.KeyCode == Config.Controls.HealthPanel then toggleMenu("HealthPanel") end
	if input.KeyCode == Config.Controls.Crafting then toggleMenu("CraftingPanel") end
	if input.KeyCode == Config.Controls.Settings then toggleMenu("SettingsPanel") end
	if input.KeyCode == Config.Controls.Ragdoll then
		ragdollEnabled = not ragdollEnabled
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(ragdollEnabled and Enum.HumanoidStateType.Physics or Enum.HumanoidStateType.GettingUp)
			activeMovementName = ragdollEnabled and "Ragdoll" or "Idle"
			if activeMovementTrack then activeMovementTrack:Stop(0.12) end
			activeMovementTrack = AnimationService.Play(humanoid, activeMovementName)
		end
	end
	if input.KeyCode == Config.Controls.AdminMenu and player:GetAttribute("IsPlanetApathyAdmin") == true then toggleMenu("AdminPanel") end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		actionRemote:InvokeServer("MainHandUse")
	end
	if input.UserInputType == Enum.UserInputType.MouseButton3 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton3 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

stateRemote.OnClientEvent:Connect(function(state)
	latestState = state
	player:SetAttribute("IsPlanetApathyAdmin", state.IsAdmin == true)
	local adminButton = gui:FindFirstChild("AdminOpenButton")
	if adminButton and adminButton:IsA("GuiObject") then adminButton.Visible = state.IsAdmin == true end
	updateHealthUi(state)
end)

remotes.Dialogue.OnClientEvent:Connect(function(line: string)
	local character = player.Character
	if not character then return end
	local color = Color3.fromHex(player:GetAttribute("BloodColor") or Config.Blood.DefaultPlayerColor:ToHex())
	local bubble = character:FindFirstChild("ExperimentDialogueBubble") :: Part? or ChatService.CreateBubble(character, color)
	bubble.Color = BloodService.ForMood(color, latestState and latestState.Stats.Mood or 0)
	local surfaceGui = bubble:FindFirstChildWhichIsA("SurfaceGui", true)
	local label = surfaceGui and surfaceGui:FindFirstChild("Line")
	if label and label:IsA("TextLabel") then label.Text = line end
	updateText("LastDialogue", line)
end)

local function setupCharacterAnimations(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid and humanoid:IsA("Humanoid") then
		local animate = character:FindFirstChild("Animate")
		if animate then animate.Disabled = true end
		AnimationService.Play(humanoid, "Idle")
		humanoid.Running:Connect(function(speed)
			if ragdollEnabled then return end
			local wanted = speed > 0.5 and "Walk" or "Idle"
			if activeMovementName == wanted then return end
			activeMovementName = wanted
			if activeMovementTrack then activeMovementTrack:Stop(0.12) end
			activeMovementTrack = AnimationService.Play(humanoid, wanted)
		end)
	end
end

if player.Character then setupCharacterAnimations(player.Character) end
player.CharacterAdded:Connect(setupCharacterAnimations)

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local camera = workspace.CurrentCamera
	local bubble = character and character:FindFirstChild("ExperimentDialogueBubble")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if bubble and bubble:IsA("Part") and root and camera then
		bubble.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 4, 0), camera.CFrame.Position)
	end
end)

setOnlyPanel(nil)
