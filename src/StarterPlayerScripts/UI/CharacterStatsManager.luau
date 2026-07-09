local CharacterStatsManager = {
    UI = nil,
    Connection = nil,
}

local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Modules.Utils)

function CharacterStatsManager:Init()
    local UIPrefab = Utils.Instance.FindFirstChild(script, "Stats")
    
    Utils.Character.ObserveCharacter(LocalPlayer, function(char: Model)
        CharacterStatsManager._InitUI(char, UIPrefab:Clone())
    end)
end

function CharacterStatsManager._InitUI(Char: Model, UI: Frame)
    if CharacterStatsManager.Connection then
        CharacterStatsManager.Connection:Disconnect()
    end
    if CharacterStatsManager.UI then
        CharacterStatsManager.UI:Destroy()
    end

    if Char:FindFirstChild("Role").Value == "Spectator" then return end

    CharacterStatsManager.UI = UI
    UI.Parent = LocalPlayer.PlayerGui.PlayerStats
    
    local Resource = UI.Stamina
    local ResourceText = Resource.TextLabel
    local ResourceBar = Resource.BarBackground.Bar
    
    local Health = UI.Health
    local HealthText = Health.TextLabel
    local HealthBar = Health.BarBackground.Bar
    
    local Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
    local ResourceAttributes = {
        ResourceName = Char.PlayerAttributes.ResourceName,
        Resource = Char.PlayerAttributes.Resource,
        MaxResource = Char.PlayerAttributes.MaxResource,
        ResourceVisible = Char.PlayerAttributes.ResourceVisible,
    }

    CharacterStatsManager.Connection = RunService.PreRender:Connect(function(delta: number)
        if not CharacterStatsManager.UI then
            CharacterStatsManager.Connection:Disconnect()
            return
        end
        
	    HealthBar.Size = UDim2.fromScale(math.lerp(HealthBar.Size.X.Scale, Humanoid.Health / Humanoid.MaxHealth, delta * 9), 1)
	    --
	    Resource.Visible = ResourceAttributes.ResourceVisible.Value or ResourceAttributes.MaxResource.Value > 0
        local MaxResource = math.max(ResourceAttributes.MaxResource.Value, 1)
	    ResourceBar.Size = UDim2.fromScale(math.lerp(ResourceBar.Size.X.Scale, ResourceAttributes.Resource.Value / MaxResource, delta * 9), 1)
    end)

    Utils.Instance.ObserveProperty(Humanoid, "Health", function(value: number)
        HealthText.Text = tostring(math.round(Humanoid.Health)).."/"..tostring(Humanoid.MaxHealth)
    end)

    local function UpdateResourceText()
        local Label = ResourceAttributes.ResourceName.Value ~= "" and ResourceAttributes.ResourceName.Value or "Resource"
        ResourceText.Text = Label..": "..tostring(math.abs(math.round(ResourceAttributes.Resource.Value))).."/"..tostring(ResourceAttributes.MaxResource.Value)
    end
    Utils.Instance.ObserveProperty(ResourceAttributes.ResourceName, "Value", UpdateResourceText)
    Utils.Instance.ObserveProperty(ResourceAttributes.Resource, "Value", UpdateResourceText)
    Utils.Instance.ObserveProperty(ResourceAttributes.MaxResource, "Value", UpdateResourceText)
    Utils.Instance.ObserveProperty(ResourceAttributes.ResourceVisible, "Value", UpdateResourceText)
    UpdateResourceText()
end

return CharacterStatsManager
