local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CameraTransitionController = {}
CameraTransitionController.__index = CameraTransitionController

local DEFAULT_SETTINGS = {
	transitionDuration = 1.1,
	easingStyle = Enum.EasingStyle.Quint,
	easingDirection = Enum.EasingDirection.Out,
	mouseInfluence = Vector2.new(1.25, 0.85),
	mouseSmoothing = 0.12,
	maxYawDegrees = 3,
	maxPitchDegrees = 2,
}

local function mergeSettings(custom)
	local result = table.clone(DEFAULT_SETTINGS)
	if custom then
		for key, value in pairs(custom) do
			result[key] = value
		end
	end
	return result
end

function CameraTransitionController.new(camera, settings)
	local self = setmetatable({}, CameraTransitionController)
	self.camera = camera or workspace.CurrentCamera
	self.player = Players.LocalPlayer
	self.settings = mergeSettings(settings)

	self.activeAnchor = nil
	self.transitionTween = nil
	self.parallaxConnection = nil
	self.currentOffset = Vector2.zero
	self.targetOffset = Vector2.zero

	return self
end

function CameraTransitionController:_getMouseDeltaToCenter()
	if not self.player then
		return Vector2.zero
	end

	local mouse = self.player:GetMouse()
	local viewport = self.camera.ViewportSize
	if viewport.X <= 0 or viewport.Y <= 0 then
		return Vector2.zero
	end

	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local raw = Vector2.new(mouse.X, mouse.Y) - center

	local normalized = Vector2.new(
		math.clamp(raw.X / center.X, -1, 1),
		math.clamp(raw.Y / center.Y, -1, 1)
	)

	return Vector2.new(
		normalized.X * self.settings.mouseInfluence.X,
		normalized.Y * self.settings.mouseInfluence.Y
	)
end

function CameraTransitionController:_disconnectParallax()
	if self.parallaxConnection then
		self.parallaxConnection:Disconnect()
		self.parallaxConnection = nil
	end
end

function CameraTransitionController:_connectParallax()
	self:_disconnectParallax()

	self.parallaxConnection = RunService.RenderStepped:Connect(function(dt)
		if not self.activeAnchor then
			return
		end

		self.targetOffset = self:_getMouseDeltaToCenter()
		local alpha = 1 - math.exp(-dt / math.max(self.settings.mouseSmoothing, 0.001))
		self.currentOffset = self.currentOffset:Lerp(self.targetOffset, alpha)

		local yaw = math.rad(-self.currentOffset.X * self.settings.maxYawDegrees)
		local pitch = math.rad(-self.currentOffset.Y * self.settings.maxPitchDegrees)

		local rotated = self.activeAnchor.CFrame * CFrame.Angles(pitch, yaw, 0)
		self.camera.CFrame = self.camera.CFrame:Lerp(rotated, 0.28)
	end)
end

function CameraTransitionController:_prepareCamera()
	self.camera.CameraType = Enum.CameraType.Scriptable
end

function CameraTransitionController:TransitionTo(anchor, transitionDuration)
	assert(anchor and anchor:IsA("BasePart"), "TransitionTo ожидает BasePart-камеру")

	self:_prepareCamera()
	self.activeAnchor = anchor
	self.currentOffset = Vector2.zero
	self.targetOffset = Vector2.zero

	if self.transitionTween then
		self.transitionTween:Cancel()
		self.transitionTween = nil
	end

	local tween = TweenService:Create(
		self.camera,
		TweenInfo.new(
			transitionDuration or self.settings.transitionDuration,
			self.settings.easingStyle,
			self.settings.easingDirection
		),
		{ CFrame = anchor.CFrame }
	)

	self.transitionTween = tween
	tween:Play()
	tween.Completed:Wait()

	if self.transitionTween == tween then
		self.transitionTween = nil
	end

	self:_connectParallax()
end

function CameraTransitionController:ReleaseToPlayer()
	self.activeAnchor = nil
	self.currentOffset = Vector2.zero
	self.targetOffset = Vector2.zero

	if self.transitionTween then
		self.transitionTween:Cancel()
		self.transitionTween = nil
	end

	self:_disconnectParallax()
	self.camera.CameraType = Enum.CameraType.Custom
end

return CameraTransitionController
