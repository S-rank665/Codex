--!strict
-- Loads editable Animation instances from ReplicatedStorage, falling back to Roblox defaults when ids are empty.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationService = {}

AnimationService.DefaultAnimationIds = {
	Idle = "rbxassetid://507766666",
	Walk = "rbxassetid://507777826",
	Crouch = "rbxassetid://507777826",
	Ragdoll = "rbxassetid://507770239",
	Push = "rbxassetid://507765644",
	Sit = "rbxassetid://2506281703",
	Lying = "rbxassetid://507770818",
}

local function findAnimation(name: string): Animation?
	local assets = ReplicatedStorage:FindFirstChild("PlanetApathyAssets")
	local animations = assets and assets:FindFirstChild("Animations")
	if not animations then return nil end
	local found = animations:FindFirstChild(name, true)
	return found and found:IsA("Animation") and found or nil
end

function AnimationService.GetAnimation(name: string): Animation
	local existing = findAnimation(name)
	if existing and existing.AnimationId ~= "" then return existing end
	local fallback = Instance.new("Animation")
	fallback.Name = name .. "Fallback"
	fallback.AnimationId = AnimationService.DefaultAnimationIds[name] or AnimationService.DefaultAnimationIds.Idle
	return fallback
end

function AnimationService.Play(humanoid: Humanoid, name: string, fadeTime: number?): AnimationTrack?
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")	
	animator.Parent = humanoid
	local track = animator:LoadAnimation(AnimationService.GetAnimation(name))
	track:Play(fadeTime or 0.15)
	return track
end

return AnimationService
