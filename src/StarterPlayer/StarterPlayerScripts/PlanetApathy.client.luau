--!strict
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Root = ReplicatedStorage:WaitForChild("PlanetApathy")
local Config = require(Root.Config.GameConfig)
local ChatService = require(Root.Shared.ChatService)
local BloodService = require(Root.Shared.BloodService)
local remotes = Root:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("StateUpdate") :: RemoteEvent

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
player.CameraMode = Config.Camera.Mode
player.CameraMinZoomDistance = Config.Camera.MinZoomDistance
player.CameraMaxZoomDistance = Config.Camera.MaxZoomDistance

local openMenu: string? = nil
local latestState = nil

local function setOnlyPanel(name: string?)
	openMenu = name
	local gui = player.PlayerGui:FindFirstChild("PlanetApathyGui")
	if gui then
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
end

local function toggleMenu(name: string)
	setOnlyPanel(openMenu == name and nil or name)
end

local function updateText(pathName: string, value: string)
	local gui = player.PlayerGui:FindFirstChild("PlanetApathyGui")
	local target = gui and gui:FindFirstChild(pathName, true)
	if target and target:IsA("TextLabel") then target.Text = value end
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
	for partName, part in pairs(state.Parts) do
		local text = string.format("%s  Muscle:%d Pain:%d Inf:%d Skin:%d", part.Amputated and "MISSING" or partName, part.Muscle, part.Pain, part.Infection, part.Skin)
		updateText(partName .. "Part", text)
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Config.Controls.Inventory then toggleMenu("InventoryPanel") end
	if input.KeyCode == Config.Controls.HealthPanel then toggleMenu("HealthPanel") end
	if input.KeyCode == Config.Controls.AdminMenu and player:GetAttribute("IsPlanetApathyAdmin") == true then toggleMenu("AdminPanel") end
end)

stateRemote.OnClientEvent:Connect(function(state)
	latestState = state
	player:SetAttribute("IsPlanetApathyAdmin", state.IsAdmin == true)
	updateHealthUi(state)
end)

remotes.Dialogue.OnClientEvent:Connect(function(line: string)
	local character = player.Character
	if not character then return end
	local color = Color3.fromHex(player:GetAttribute("BloodColor") or Config.Blood.DefaultPlayerColor:ToHex())
	local bubble = character:FindFirstChild("ExperimentDialogueBubble") :: Part? or ChatService.CreateBubble(character, color)
	bubble.Color = BloodService.ForMood(color, latestState and latestState.Stats.Mood or 0)
	local label = bubble:FindFirstChildWhichIsA("SurfaceGui", true):FindFirstChild("Line") :: TextLabel
	label.Text = line
	updateText("LastDialogue", line)
end)

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local camera = workspace.CurrentCamera
	local bubble = character and character:FindFirstChild("ExperimentDialogueBubble")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if bubble and bubble:IsA("Part") and root and camera then
		bubble.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 4, 0), camera.CFrame.Position)
	end
end)
