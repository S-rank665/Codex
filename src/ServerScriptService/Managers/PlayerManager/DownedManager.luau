local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Modules.Network)
local Utils = require(ReplicatedStorage.Modules.Utils)
local PlayerSpeedManager = require(script.Parent.PlayerSpeedManager)

local DownedManager = {
    DownedHealth = 300,
    ReviveHealth = 65,
    BleedDamagePerSecond = 1,
    ReviveDistance = 10,
    DownedSpeedFactor = 0.35,
    Downed = {},
}

function DownedManager:Init()
    Network:SetConnection("ReviveDownedPlayer", "REMOTE_FUNCTION", function(SourcePlayer: Player, TargetPlayer: Player)
        return DownedManager.Revive(SourcePlayer, TargetPlayer)
    end)
end

function DownedManager.IsSurvivor(Character: Model): boolean
    local Role = Character and Character:FindFirstChild("Role")
    return Role and Role.Value == "Survivor"
end

function DownedManager.CanDown(Character: Model): boolean
    return DownedManager.IsSurvivor(Character)
        and Character:GetAttribute("Downed") ~= true
        and Character:GetAttribute("DownedLivesUsed") ~= true
end

function DownedManager.Down(Player: Player, Humanoid: Humanoid): boolean
    local Character = Player and Player.Character
    if not Character or not Humanoid or not DownedManager.CanDown(Character) then
        return false
    end

    Character:SetAttribute("Downed", true)
    Character:SetAttribute("DownedLivesUsed", true)
    Character:SetAttribute("CanRevive", false)
    Character:SetAttribute("DownedHealth", DownedManager.DownedHealth)
    Character:SetAttribute("DownedMaxHealth", DownedManager.DownedHealth)

    Humanoid.MaxHealth = DownedManager.DownedHealth
    Humanoid.Health = DownedManager.DownedHealth
    PlayerSpeedManager.AddSpeedFactor(Player, "Downed", DownedManager.DownedSpeedFactor)

    local Token = {}
    DownedManager.Downed[Player] = Token
    task.spawn(function()
        while DownedManager.Downed[Player] == Token and Character.Parent and Humanoid.Parent and Humanoid.Health > 0 do
            task.wait(1)
            if DownedManager.Downed[Player] ~= Token then
                break
            end

            local NewHealth = math.max(Humanoid.Health - DownedManager.BleedDamagePerSecond, 0)
            Humanoid.Health = NewHealth
            Character:SetAttribute("DownedHealth", NewHealth)

            if NewHealth <= 0 then
                DownedManager.Kill(Player)
                break
            end
        end
    end)

    return true
end

function DownedManager.Kill(Player: Player)
    local Character = Player and Player.Character
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    if not Character or not Humanoid then
        return
    end

    DownedManager.Downed[Player] = nil
    Character:SetAttribute("Downed", false)
    Character:SetAttribute("CanRevive", false)
    PlayerSpeedManager.RemoveSpeedFactor(Player, "Downed")
    Humanoid.Health = 0
end

function DownedManager.Revive(SourcePlayer: Player, TargetPlayer: Player): (boolean, string?)
    if not SourcePlayer or not TargetPlayer or SourcePlayer == TargetPlayer then
        return false, "Invalid revive target."
    end

    local SourceCharacter = SourcePlayer.Character
    local TargetCharacter = TargetPlayer.Character
    if not SourceCharacter or not TargetCharacter then
        return false, "Missing character."
    end

    if SourceCharacter:GetAttribute("Downed") == true then
        return false, "Downed players cannot revive others."
    end

    if TargetCharacter:GetAttribute("Downed") ~= true then
        return false, "Target is not downed."
    end

    local SourceRoot = Utils.Character.GetRootPart(SourceCharacter)
    local TargetRoot = Utils.Character.GetRootPart(TargetCharacter)
    if not SourceRoot or not TargetRoot or (SourceRoot.Position - TargetRoot.Position).Magnitude > DownedManager.ReviveDistance then
        return false, "Too far away."
    end

    local Humanoid = TargetCharacter:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then
        return false, "Target has no humanoid."
    end

    DownedManager.Downed[TargetPlayer] = nil
    TargetCharacter:SetAttribute("Downed", false)
    TargetCharacter:SetAttribute("CanRevive", true)
    PlayerSpeedManager.RemoveSpeedFactor(TargetPlayer, "Downed")

    local OriginalMaxHealth = TargetCharacter:GetAttribute("OriginalMaxHealth") or 100
    Humanoid.MaxHealth = OriginalMaxHealth
    Humanoid.Health = math.min(DownedManager.ReviveHealth, OriginalMaxHealth)
    TargetCharacter:SetAttribute("DownedHealth", 0)

    return true
end

function DownedManager.AreAllSurvivorsDowned(): boolean
    local Survivors = Utils.Character.GetCharactersWithRoles(false).Survivor or {}
    local FoundSurvivor = false

    for _, Character: Model in Survivors do
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid and Humanoid.Health > 0 then
            FoundSurvivor = true
            if Character:GetAttribute("Downed") ~= true then
                return false
            end
        end
    end

    return FoundSurvivor
end

function DownedManager.KillAllDownedSurvivors()
    for _, Character: Model in Utils.Character.GetCharactersWithRoles(false).Survivor or {} do
        if Character:GetAttribute("Downed") == true then
            local Player = Players:GetPlayerFromCharacter(Character)
            if Player then
                DownedManager.Kill(Player)
            end
        end
    end
end

return DownedManager
