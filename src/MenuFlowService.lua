local MenuFlowService = {}
MenuFlowService.__index = MenuFlowService

function MenuFlowService.new(cameraController, dialogueService)
	local self = setmetatable({}, MenuFlowService)
	self.cameraController = cameraController
	self.dialogueService = dialogueService

	self.inMenu = false
	self.inShop = false
	self.menuLocked = false
	self.shopLocked = false

	self.events = {
		MenuEntered = Instance.new("BindableEvent"),
		MenuExited = Instance.new("BindableEvent"),
		ShopEntered = Instance.new("BindableEvent"),
		ShopExited = Instance.new("BindableEvent"),
		MenuLockChanged = Instance.new("BindableEvent"),
		ShopLockChanged = Instance.new("BindableEvent"),
	}

	return self
end

function MenuFlowService:IsMenuLocked()
	return self.menuLocked
end

function MenuFlowService:IsShopLocked()
	return self.shopLocked
end

function MenuFlowService:SetMenuLocked(locked, reason)
	self.menuLocked = locked and true or false
	self.events.MenuLockChanged:Fire(self.menuLocked, reason)
end

function MenuFlowService:SetShopLocked(locked, reason)
	self.shopLocked = locked and true or false
	self.events.ShopLockChanged:Fire(self.shopLocked, reason)
end

function MenuFlowService:CanEnterMenu()
	return not self.menuLocked and not self.inMenu
end

function MenuFlowService:CanEnterShop()
	return not self.shopLocked and self.inMenu and not self.inShop
end

function MenuFlowService:EnterMenu(menuCameraPart)
	if not self:CanEnterMenu() then
		return false, "MENU_LOCKED_OR_ALREADY_OPEN"
	end

	self.cameraController:TransitionTo(menuCameraPart)
	self.inMenu = true
	self.events.MenuEntered:Fire(menuCameraPart)
	return true
end

function MenuFlowService:ExitMenu()
	if not self.inMenu then
		return false, "NOT_IN_MENU"
	end

	self.inMenu = false
	self.inShop = false
	self.cameraController:ReleaseToPlayer()
	self.events.MenuExited:Fire()
	return true
end

function MenuFlowService:EnterShop(shopCameraPart, dialogueLabel)
	if not self:CanEnterShop() then
		return false, "SHOP_LOCKED_OR_MENU_NOT_OPEN"
	end

	self.cameraController:TransitionTo(shopCameraPart)
	self.inShop = true
	self.events.ShopEntered:Fire(shopCameraPart)

	if self.dialogueService and dialogueLabel then
		local line = self.dialogueService:GetRandomLine()
		if line then
			task.spawn(function()
				self.dialogueService:PlayLine(line, dialogueLabel)
			end)
		end
	end

	return true
end

function MenuFlowService:ExitShop(destinationCameraPart)
	if not self.inShop then
		return false, "NOT_IN_SHOP"
	end

	self.inShop = false

	if destinationCameraPart then
		self.cameraController:TransitionTo(destinationCameraPart)
	else
		self.cameraController:ReleaseToPlayer()
		self.inMenu = false
		self.events.MenuExited:Fire()
	end

	self.events.ShopExited:Fire(destinationCameraPart)
	return true
end

function MenuFlowService:ForceExitAll(destinationCameraPart)
	self.inShop = false
	self.inMenu = false

	if destinationCameraPart then
		self.cameraController:TransitionTo(destinationCameraPart, 0.7)
	else
		self.cameraController:ReleaseToPlayer()
	end

	self.events.ShopExited:Fire(destinationCameraPart)
	self.events.MenuExited:Fire(destinationCameraPart)
	return true
end

function MenuFlowService:Destroy()
	for _, event in pairs(self.events) do
		event:Destroy()
	end
	self.events = nil
end

return MenuFlowService
