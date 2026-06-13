--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Root = ReplicatedStorage:WaitForChild("PlanetApathy")
local remotes = Root:WaitForChild("Remotes")
local adminRemote = remotes:WaitForChild("AdminCommand") :: RemoteFunction

local screen = script.Parent
local openButton = Instance.new("TextButton")
openButton.Name = "AdminOpenButton"
openButton.Size = UDim2.fromOffset(110, 32)
openButton.Position = UDim2.new(1, -122, 0, 12)
openButton.BackgroundColor3 = Color3.fromRGB(110, 74, 24)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "ADMIN DEBUG"
openButton.Visible = false
openButton.Parent = screen

local frame = Instance.new("Frame")
frame.Name = "AdminPanel"
frame.Size = UDim2.fromScale(0.34, 0.62)
frame.Position = UDim2.fromScale(0.63, 0.18)
frame.BackgroundColor3 = Color3.fromRGB(20, 18, 12)
frame.Visible = false
frame.Parent = screen

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.08)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 228, 160)
title.TextScaled = true
title.Text = "Admin Debug"
title.Parent = frame

local status = Instance.new("TextLabel")
status.Name = "AdminStatus"
status.Size = UDim2.fromScale(0.92, 0.08)
status.Position = UDim2.fromScale(0.04, 0.89)
status.BackgroundColor3 = Color3.fromRGB(35, 31, 24)
status.TextColor3 = Color3.new(1, 1, 1)
status.Text = "Ready"
status.Parent = frame

local function run(command: string, payload: any?)
	local ok, result = adminRemote:InvokeServer(command, payload)
	status.Text = (ok and "✅ " or "❌ ") .. tostring(result)
end

local buttons = {
	{"Mood +20", "Mood", 20},
	{"Mood -20", "Mood", -20},
	{"Test Damage", "Damage", nil},
	{"Full Heal", "Heal", nil},
	{"Next Layer", "NextLayer", nil},
	{"Say Test Line", "Dialogue", "This is a test dialogue bubble."},
	{"Spawn Medkit", "SpawnItem", "test_medkit"},
	{"Spawn Food", "SpawnItem", "test_food"},
	{"Spawn Tool", "SpawnItem", "test_tool"},
	{"Spawn Scanner", "SpawnItem", "test_scanner"},
	{"Structure Editor", "StructureRole", "Structure"},
	{"Mini-game Test", "Minigame", "Bandage wrap timing"},
}

for index, entry in ipairs(buttons) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromScale(0.43, 0.105)
	button.Position = UDim2.fromScale(0.05 + ((index - 1) % 2) * 0.48, 0.10 + math.floor((index - 1) / 2) * 0.125)
	button.BackgroundColor3 = Color3.fromRGB(55, 47, 31)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Text = entry[1]
	button.Parent = frame
	button.MouseButton1Click:Connect(function() run(entry[2], entry[3]) end)
end

local function refreshAdminVisibility()
	local visible = player:GetAttribute("IsPlanetApathyAdmin") == true
	openButton.Visible = visible
	if not visible then frame.Visible = false end
end

openButton.MouseButton1Click:Connect(function()
	local nextVisible = not frame.Visible
	for _, child in ipairs(screen:GetChildren()) do
		if child:IsA("GuiObject") and string.find(child.Name, "Panel") then
			child.Visible = false
		end
	end
	frame.Visible = nextVisible
end)
player:GetAttributeChangedSignal("IsPlanetApathyAdmin"):Connect(refreshAdminVisibility)
refreshAdminVisibility()
