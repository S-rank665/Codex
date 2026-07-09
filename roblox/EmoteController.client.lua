--!strict
-- LocalScript: StarterPlayer > StarterPlayerScripts > EmoteController.client.lua
-- Открывает меню по B, берет список экипированных эмоций с сервера
-- и проигрывает контент из ReplicatedStorage/Emotes

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local TOGGLE_KEY = Enum.KeyCode.B
local MAX_EMOTES = 4

local remotesFolder = ReplicatedStorage:WaitForChild("EmoteRemotes")
local getEquippedEmotes = remotesFolder:WaitForChild("GetEquippedEmotes") :: RemoteFunction
local equippedChanged = remotesFolder:WaitForChild("EquippedEmotesChanged") :: RemoteEvent

local emotesFolder = ReplicatedStorage:WaitForChild("Emotes")

local equippedEmoteNames: { string } = {}
local currentTrack: AnimationTrack? = nil
local currentSound: Sound? = nil
local activeProps: { Instance } = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteMenuGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.Size = UDim2.fromOffset(360, 90)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 1, 24)
frame.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
frame.BackgroundTransparency = 0.35
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(75, 75, 75)
stroke.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = frame

local MENU_HIDDEN_POS = UDim2.new(0.5, 0, 1, 24)
local MENU_SHOWN_POS = UDim2.new(0.5, 0, 1, -110)
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local menuOpened = false
local menuTween: Tween? = nil

local function setMenuVisible(isVisible: boolean)
	menuOpened = isVisible
	if menuTween then
		menuTween:Cancel()
	end

	local targetPosition = if isVisible then MENU_SHOWN_POS else MENU_HIDDEN_POS
	menuTween = TweenService:Create(frame, TWEEN_INFO, { Position = targetPosition })
	menuTween:Play()
end

local function clearProps()
	for _, prop in activeProps do
		if prop and prop.Parent then
			prop:Destroy()
		end
	end
	table.clear(activeProps)
end

local function stopCurrent()
	if currentTrack then
		currentTrack:Stop(0.15)
		currentTrack:Destroy()
		currentTrack = nil
	end

	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end

	clearProps()
end

local function tryGetEmoteContainer(emoteName: string): Instance?
	return emotesFolder:FindFirstChild(emoteName)
end

local function applyProps(character: Model, emoteContainer: Instance)
	local propsContainer = emoteContainer:FindFirstChild("Props")
	if not propsContainer then
		return
	end

	for _, propTemplate in propsContainer:GetChildren() do
		local cloned = propTemplate:Clone()
		cloned.Parent = character
		table.insert(activeProps, cloned)
	end
end

local function playEmote(emoteName: string)
	local emoteContainer = tryGetEmoteContainer(emoteName)
	if not emoteContainer then
		warn("Эмоция не найдена в ReplicatedStorage/Emotes:", emoteName)
		return
	end

	local animationObj = emoteContainer:FindFirstChild("Animation")
	if not animationObj or not animationObj:IsA("Animation") then
		warn("У эмоции отсутствует Animation:", emoteName)
		return
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		warn("Не найден Humanoid или HumanoidRootPart")
		return
	end

	stopCurrent()

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local track = animator:LoadAnimation(animationObj)
	track:Play(0.1)
	currentTrack = track

	local soundTemplate = emoteContainer:FindFirstChild("Sound")
	if soundTemplate and soundTemplate:IsA("Sound") then
		local sound = soundTemplate:Clone()
		sound.Parent = rootPart
		sound:Play()
		currentSound = sound

		sound.Ended:Once(function()
			if currentSound == sound then
				currentSound:Destroy()
				currentSound = nil
			end
		end)
	end

	applyProps(character, emoteContainer)

	track.Stopped:Once(function()
		if currentTrack == track then
			currentTrack:Destroy()
			currentTrack = nil
		end
		clearProps()
	end)
end

local function clearButtons()
	for _, child in frame:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function resolveDisplayName(emoteName: string): string
	local container = emotesFolder:FindFirstChild(emoteName)
	if not container then
		return emoteName
	end

	local displayNameValue = container:FindFirstChild("DisplayName")
	if displayNameValue and displayNameValue:IsA("StringValue") and displayNameValue.Value ~= "" then
		return displayNameValue.Value
	end

	return emoteName
end

local function rebuildButtons()
	clearButtons()
	for _, emoteName in equippedEmoteNames do
		local button = Instance.new("TextButton")
		button.Name = "EmoteButton_" .. emoteName
		button.Size = UDim2.fromOffset(80, 60)
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamSemibold
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextSize = 14
		button.TextWrapped = true
		button.Text = resolveDisplayName(emoteName)
		button.AutoButtonColor = true
		button.Parent = frame

		local buttonBackground = Instance.new("ImageLabel")
		buttonBackground.Name = "Background"
		buttonBackground.Size = UDim2.fromScale(1, 1)
		buttonBackground.BackgroundTransparency = 1
		buttonBackground.Image = "rbxassetid://110197891173539"
		buttonBackground.ScaleType = Enum.ScaleType.Stretch
		buttonBackground.ZIndex = 1
		buttonBackground.Parent = button

		button.ZIndex = 2

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 10)
		buttonCorner.Parent = button

		button.MouseButton1Click:Connect(function()
			playEmote(emoteName)
		end)
	end
end

local function setEquippedFromServer(rawList: any)
	local parsed: { string } = {}
	if type(rawList) == "table" then
		for _, value in rawList do
			if type(value) == "string" then
				table.insert(parsed, value)
			end
			if #parsed >= MAX_EMOTES then
				break
			end
		end
	end
	equippedEmoteNames = parsed
	rebuildButtons()
end

local ok, result = pcall(function()
	return getEquippedEmotes:InvokeServer()
end)
if ok then
	setEquippedFromServer(result)
else
	warn("Не удалось получить список экипированных эмоций:", result)
end

equippedChanged.OnClientEvent:Connect(function(newList)
	setEquippedFromServer(newList)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == TOGGLE_KEY then
		setMenuVisible(not menuOpened)
	end
end)

localPlayer.CharacterRemoving:Connect(function()
	stopCurrent()
end)
