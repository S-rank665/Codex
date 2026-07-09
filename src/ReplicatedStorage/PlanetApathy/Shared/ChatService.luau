--!strict
local ChatService = {}
function ChatService.Muffle(message: string, mouthOccupied: boolean): string
	if not mouthOccupied then return message end
	return string.gsub(message, "[%aА-Яа-я]", "m")
end
function ChatService.CreateBubble(character: Model, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = "ExperimentDialogueBubble"
	part.Size = Vector3.new(5, 1.2, 0.1)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	local gui = Instance.new("SurfaceGui"); gui.Face = Enum.NormalId.Front; gui.Parent = part
	local text = Instance.new("TextLabel"); text.Name = "Line"; text.Size = UDim2.fromScale(1,1); text.BackgroundTransparency = 1; text.TextScaled = true; text.Parent = gui
	part.Parent = character
	return part
end
return ChatService
