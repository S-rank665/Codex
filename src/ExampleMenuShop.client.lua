--[[
	Пример подключения системы меню + магазина.
	Что нужно подготовить в сцене:
	1) workspace.MenuCameraAnchor (Part)
	2) workspace.ShopCameraAnchor (Part)
	3) workspace.ReturnCameraAnchor (Part) - опционально
	4) SurfaceGui с кнопкой перехода в магазин
	5) UI TextLabel для диалога
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraTransitionController = require(ReplicatedStorage.Modules.CameraTransitionController)
local ShopDialogueService = require(ReplicatedStorage.Modules.ShopDialogueService)
local MenuFlowService = require(ReplicatedStorage.Modules.MenuFlowService)

local menuCameraAnchor = workspace:WaitForChild("MenuCameraAnchor")
local shopCameraAnchor = workspace:WaitForChild("ShopCameraAnchor")
local returnCameraAnchor = workspace:FindFirstChild("ReturnCameraAnchor")

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local menuGui = playerGui:WaitForChild("MenuGui")
local shopGui = playerGui:WaitForChild("ShopGui")

local openMenuButton = menuGui:WaitForChild("OpenMenuButton")
local closeMenuButton = menuGui:WaitForChild("CloseMenuButton")
local enterShopButton = menuGui:WaitForChild("EnterShopButton")
local exitShopButton = shopGui:WaitForChild("ExitShopButton")
local dialogueLabel = shopGui:WaitForChild("DialogueFrame"):WaitForChild("Text")

local cameraController = CameraTransitionController.new()
local dialogueService = ShopDialogueService.new({
	lines = {
		"Добро пожаловать! Смотри, что есть в продаже.",
		"Случайный диалог работает. Магазин ждёт тебя.",
		"Сегодняшний выбор тебе понравится.",
	},
	voiceMap = {
		["Добро пожаловать! Смотри, что есть в продаже."] = "rbxassetid://1234567890", -- Замени на свою озвучку
	},
})

local menuFlowService = MenuFlowService.new(cameraController, dialogueService)

openMenuButton.MouseButton1Click:Connect(function()
	local ok = menuFlowService:EnterMenu(menuCameraAnchor)
	if ok then
		menuGui.Enabled = true
	end
end)

closeMenuButton.MouseButton1Click:Connect(function()
	local ok = menuFlowService:ExitMenu()
	if ok then
		menuGui.Enabled = false
		shopGui.Enabled = false
	end
end)

enterShopButton.MouseButton1Click:Connect(function()
	local ok = menuFlowService:EnterShop(shopCameraAnchor, dialogueLabel)
	if ok then
		shopGui.Enabled = true
	end
end)

exitShopButton.MouseButton1Click:Connect(function()
	local ok = menuFlowService:ExitShop(returnCameraAnchor or menuCameraAnchor)
	if ok then
		shopGui.Enabled = false
		menuGui.Enabled = true
	end
end)

-- API, которое можно использовать из других скриптов:
_G.MenuAPI = {
	EnterMenu = function()
		return menuFlowService:EnterMenu(menuCameraAnchor)
	end,
	ExitMenu = function()
		return menuFlowService:ExitMenu()
	end,
	EnterShop = function()
		return menuFlowService:EnterShop(shopCameraAnchor, dialogueLabel)
	end,
	ExitShop = function(destination)
		return menuFlowService:ExitShop(destination)
	end,
	ForceExitAll = function(destination)
		return menuFlowService:ForceExitAll(destination)
	end,
	SetMenuLocked = function(locked, reason)
		menuFlowService:SetMenuLocked(locked, reason)
	end,
	SetShopLocked = function(locked, reason)
		menuFlowService:SetShopLocked(locked, reason)
	end,
	IsMenuLocked = function()
		return menuFlowService:IsMenuLocked()
	end,
	IsShopLocked = function()
		return menuFlowService:IsShopLocked()
	end,
}
