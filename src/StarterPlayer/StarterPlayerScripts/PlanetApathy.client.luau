--!strict
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Root = ReplicatedStorage:WaitForChild("PlanetApathy")
local Config = require(Root.Config.GameConfig)
local ChatService = require(Root.Shared.ChatService)
local BloodService = require(Root.Shared.BloodService)
local remotes = Root:WaitForChild("Remotes")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
player.CameraMode = Config.Camera.Mode
player.CameraMinZoomDistance = Config.Camera.MinZoomDistance
player.CameraMaxZoomDistance = Config.Camera.MaxZoomDistance

local openMenu: string? = nil
local function toggleMenu(name: string)
	openMenu = (openMenu == name) and nil or name
	local gui = player.PlayerGui:FindFirstChild("PlanetApathyGui")
	if gui then
		for _, child in ipairs(gui:GetChildren()) do
			if child:IsA("GuiObject") then child.Visible = child.Name == name and openMenu == name end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Config.Controls.Inventory then toggleMenu("InventoryPanel") end
	if input.KeyCode == Config.Controls.HealthPanel then toggleMenu("HealthPanel") end
end)

remotes.Dialogue.OnClientEvent:Connect(function(line: string)
	local character = player.Character
	if not character then return end
	local color = Color3.fromHex(player:GetAttribute("BloodColor") or Config.Blood.DefaultPlayerColor:ToHex())
	local bubble = character:FindFirstChild("ExperimentDialogueBubble") :: Part? or ChatService.CreateBubble(character, color)
	bubble.Color = BloodService.ForMood(color, -50)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then bubble.CFrame = root.CFrame * CFrame.new(0, 4, 0) end
	local label = bubble:FindFirstChildWhichIsA("SurfaceGui", true):FindFirstChild("Line") :: TextLabel
	label.Text = line
	local gui = player.PlayerGui:FindFirstChild("PlanetApathyGui")
	local health = gui and gui:FindFirstChild("HealthPanel")
	local log = health and health:FindFirstChild("LastDialogue", true)
	if log and log:IsA("TextLabel") then log.Text = line end
end)
