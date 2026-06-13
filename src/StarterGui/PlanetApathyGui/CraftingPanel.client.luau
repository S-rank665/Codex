--!strict
local frame = Instance.new("Frame")
frame.Name = "CraftingPanel"
frame.Size = UDim2.fromScale(0.36, 0.48)
frame.Position = UDim2.fromScale(0.32, 0.26)
frame.BackgroundColor3 = Color3.fromRGB(18, 14, 12)
frame.Visible = false
frame.Parent = script.Parent
local text = Instance.new("TextLabel")
text.Size = UDim2.fromScale(0.9, 0.8)
text.Position = UDim2.fromScale(0.05, 0.1)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.new(1, 1, 1)
text.TextWrapped = true
text.Text = "Crafting test panel\n\nRecipes will read ingredients from body slots and non-nested containers in inventory. This panel is mutually exclusive with health/inventory/admin screens."
text.Parent = frame
