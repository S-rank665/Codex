local ShopService = {}
ShopService.__index = ShopService

function ShopService.new(cameraController, dialogueService)
	local self = setmetatable({}, ShopService)
	self.cameraController = cameraController
	self.dialogueService = dialogueService

	self.shopLocked = false
	self.inShop = false

	self.events = {
		Entered = Instance.new("BindableEvent"),
		Exited = Instance.new("BindableEvent"),
		LockChanged = Instance.new("BindableEvent"),
	}

	return self
end

function ShopService:IsLocked()
	return self.shopLocked
end

function ShopService:SetLocked(locked, reason)
	self.shopLocked = locked and true or false
	self.events.LockChanged:Fire(self.shopLocked, reason)
end

function ShopService:CanEnter()
	return not self.shopLocked and not self.inShop
end

function ShopService:Enter(shopCameraPart, dialogueLabel)
	if not self:CanEnter() then
		return false, "SHOP_LOCKED_OR_ALREADY_OPEN"
	end

	self.cameraController:TransitionTo(shopCameraPart)
	self.inShop = true
	self.events.Entered:Fire(shopCameraPart)

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

function ShopService:Exit(destinationCameraPart)
	if not self.inShop then
		return false, "NOT_IN_SHOP"
	end

	if destinationCameraPart then
		self.cameraController:TransitionTo(destinationCameraPart)
	else
		self.cameraController:ReleaseToPlayer()
	end

	self.inShop = false
	self.events.Exited:Fire(destinationCameraPart)
	return true
end

function ShopService:ForceExit(destinationCameraPart)
	if destinationCameraPart then
		self.cameraController:TransitionTo(destinationCameraPart, 0.7)
	else
		self.cameraController:ReleaseToPlayer()
	end

	self.inShop = false
	self.events.Exited:Fire(destinationCameraPart)
	return true
end

function ShopService:Destroy()
	for _, event in pairs(self.events) do
		event:Destroy()
	end
	self.events = nil
end

return ShopService
