--!strict
local screen = script.Parent
local frame = Instance.new("Frame")
frame.Name = "HealthPanel"
frame.Size = UDim2.fromScale(0.44, 0.82)
frame.Position = UDim2.fromScale(0.03, 0.10)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
frame.Visible = false
frame.Parent = screen

local function label(name: string, text: string, pos: UDim2, size: UDim2, color: Color3?): TextLabel
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Size = size
	item.Position = pos
	item.BackgroundColor3 = color or Color3.fromRGB(22, 22, 28)
	item.TextColor3 = Color3.fromRGB(235, 235, 235)
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextScaled = false
	item.TextSize = 14
	item.Text = text
	item.Parent = frame
	return item
end

local title = label("Title", "  Chipped Experiment Health Panel", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.055), Color3.fromRGB(24, 24, 34))
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Center
label("ExperimentNumber", "Experiment: awaiting chip", UDim2.fromScale(0.03, 0.065), UDim2.fromScale(0.46, 0.045))
label("LayerStatus", "Layer: ?", UDim2.fromScale(0.51, 0.065), UDim2.fromScale(0.46, 0.045))
label("Objective", "Objective: awaiting corporate order", UDim2.fromScale(0.03, 0.115), UDim2.fromScale(0.94, 0.06))
label("LastDialogue", "", UDim2.fromScale(0.03, 0.18), UDim2.fromScale(0.94, 0.05), Color3.fromRGB(30, 30, 36))

local stats = {"Brain", "Hunger", "Thirst", "Sickness", "Weight", "Stamina", "Temperature", "Immunity", "Calories", "Radiation", "Mood", "STR", "RES", "INT"}
for i, stat in ipairs(stats) do
	local col = (i - 1) % 2
	local row = math.floor((i - 1) / 2)
	label(stat .. "Row", "  " .. stat .. ": awaiting chip data", UDim2.fromScale(0.03 + col * 0.48, 0.245 + row * 0.047), UDim2.fromScale(0.45, 0.04))
end

local bodyTitle = label("BodyTitle", "  Body parts", UDim2.fromScale(0.03, 0.59), UDim2.fromScale(0.94, 0.04), Color3.fromRGB(26, 24, 32))
bodyTitle.TextXAlignment = Enum.TextXAlignment.Center
for i, part in ipairs({"Head", "Chest", "Abdomen", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
	label(part .. "Part", part .. ": awaiting scan", UDim2.fromScale(0.03, 0.635 + (i - 1) * 0.047), UDim2.fromScale(0.94, 0.04))
end
