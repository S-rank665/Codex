--!strict
local screen = script.Parent
local frame = Instance.new("Frame")
frame.Name = "InventoryPanel"
frame.Size = UDim2.fromScale(0.44, 0.52)
frame.Position = UDim2.fromScale(0.28, 0.24)
frame.BackgroundColor3 = Color3.fromRGB(14, 16, 18)
frame.Visible = false
frame.Parent = screen
for i, slot in ipairs({"MainHand", "OffHand", "Mouth", "UpperBack", "MiddleBack", "RearHip"}) do
	local b = Instance.new("TextButton")
	b.Name = slot
	b.Size = UDim2.fromScale(0.3, 0.14)
	b.Position = UDim2.fromScale(0.05 + ((i - 1) % 2) * 0.34, 0.08 + math.floor((i - 1) / 2) * 0.18)
	b.Text = slot .. "\n(empty)"
	b.Parent = frame
end
local useZone = Instance.new("TextLabel")
useZone.Name = "UseOrEquipZone"
useZone.Size = UDim2.fromScale(0.26, 0.32)
useZone.Position = UDim2.fromScale(0.68, 0.32)
useZone.BackgroundColor3 = Color3.fromRGB(40, 36, 28)
useZone.TextColor3 = Color3.new(1,1,1)
useZone.Text = "Use / Equip"
useZone.Parent = frame
