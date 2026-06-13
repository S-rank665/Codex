--!strict
local screen = script.Parent
local frame = Instance.new("Frame")
frame.Name = "InventoryPanel"
frame.Size = UDim2.fromScale(0.50, 0.62)
frame.Position = UDim2.fromScale(0.25, 0.19)
frame.BackgroundColor3 = Color3.fromRGB(14, 16, 18)
frame.Visible = false
frame.Parent = screen

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.08)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Text = "Six-slot body inventory (test UI)"
title.Parent = frame

for i, slot in ipairs({"MainHand", "OffHand", "Mouth", "UpperBack", "MiddleBack", "RearHip"}) do
	local b = Instance.new("TextButton")
	b.Name = slot
	b.Size = UDim2.fromScale(0.28, 0.13)
	b.Position = UDim2.fromScale(0.05 + ((i - 1) % 2) * 0.32, 0.12 + math.floor((i - 1) / 2) * 0.16)
	b.BackgroundColor3 = Color3.fromRGB(34, 38, 42)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = slot .. "\n(empty)"
	b.Parent = frame
end

local useZone = Instance.new("TextLabel")
useZone.Name = "UseOrEquipZone"
useZone.Size = UDim2.fromScale(0.28, 0.31)
useZone.Position = UDim2.fromScale(0.68, 0.23)
useZone.BackgroundColor3 = Color3.fromRGB(40, 36, 28)
useZone.TextColor3 = Color3.new(1,1,1)
useZone.TextScaled = true
useZone.Text = "Drag here\nUse / Equip"
useZone.Parent = frame

local hint = Instance.new("TextLabel")
hint.Name = "InventoryHint"
hint.Size = UDim2.fromScale(0.90, 0.16)
hint.Position = UDim2.fromScale(0.05, 0.76)
hint.BackgroundColor3 = Color3.fromRGB(24, 27, 30)
hint.TextColor3 = Color3.fromRGB(220, 220, 220)
hint.TextWrapped = true
hint.Text = "World item pickup test: admin can spawn Parts above the player. Full drag-to-character pickup hooks can attach to these slots next."
hint.Parent = frame
