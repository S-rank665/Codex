--!strict
local screen = script.Parent
local frame = Instance.new("Frame")
frame.Name = "HealthPanel"
frame.Size = UDim2.fromScale(0.36, 0.72)
frame.Position = UDim2.fromScale(0.03, 0.14)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
frame.Visible = false
frame.Parent = screen
local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.08)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Text = "Chipped Experiment Health Panel"
title.Parent = frame
local last = Instance.new("TextLabel")
last.Name = "LastDialogue"
last.Size = UDim2.fromScale(0.94, 0.08)
last.Position = UDim2.fromScale(0.03, 0.09)
last.BackgroundColor3 = Color3.fromRGB(30,30,36)
last.TextColor3 = Color3.new(1,1,1)
last.Text = ""
last.Parent = frame
for i, stat in ipairs({"Brain", "Hunger", "Thirst", "Sickness", "Weight", "Stamina L/R", "Temperature", "Immunity", "Radiation", "Mood"}) do
	local label = Instance.new("TextLabel")
	label.Name = stat .. "Row"
	label.Size = UDim2.fromScale(0.94, 0.055)
	label.Position = UDim2.fromScale(0.03, 0.18 + (i - 1) * 0.062)
	label.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "  " .. stat .. ": awaiting chip data"
	label.Parent = frame
end
