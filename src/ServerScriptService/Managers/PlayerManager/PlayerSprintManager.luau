local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerSpeedManager = require(script.Parent.PlayerSpeedManager)
local Types = require(ReplicatedStorage.Classes.Types)
local Network = require(ReplicatedStorage.Modules.Network)
local Utils = require(ReplicatedStorage.Modules.Utils)

local PlayerSprintManager = {
    ManagedPlayers = {},
}

local SprintModule = {}
SprintModule.__index = SprintModule

local FactorName = "Sprint"

function PlayerSprintManager:Init()
    Utils.Player.ObservePlayers(function(Player: Player)
        Utils.Character.ObserveCharacter(Player, function(Character: Model, CharacterJanitor: Types.Janitor)
            local ManagedPlayer = setmetatable({
                AttemptingSprint = false,
                PressingSprintWhileRecovering = false,
                Recovering = false,
                Exhausted = false,
                Stamina = 100,
                TweenSpeed = true,
                SpeedApplied = false,
                SprintMultiplier = 2.66666,
                CanGainStamina = true,
                RecoverDelay = 0.75,
                RecoverExhaustionDelay = 2,
            }, SprintModule)

            local HumanoidRootPart = Utils.Character.GetRootPart(Character)
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local Role = Character:FindFirstChild("Role")

            local PlayerAttributes = Character:FindFirstChild("PlayerAttributes")
            local SprintValue = PlayerAttributes:FindFirstChild("Sprinting")
            local StaminaValue = PlayerAttributes:FindFirstChild("Stamina")
            ManagedPlayer.MaxStamina = PlayerAttributes:FindFirstChild("MaxStamina")
            ManagedPlayer.StaminaRegenRate = PlayerAttributes:FindFirstChild("StaminaGain")
            ManagedPlayer.StaminaDrainRate = PlayerAttributes:FindFirstChild("StaminaDrain")

            PlayerSpeedManager.AddSpeedFactor(Player, FactorName, 1)

            CharacterJanitor:Add(RunService.PreSimulation:Connect(function(delta: number)
                local DirectionOfMovement = HumanoidRootPart.CFrame:VectorToObjectSpace(HumanoidRootPart.AssemblyLinearVelocity)
                local HumanoidDirectionOfMovement = Vector3.new(Humanoid.MoveDirection.X, 0, Humanoid.MoveDirection.Z)
                local Moving = not HumanoidRootPart.Anchored and Humanoid.WalkSpeed > 0 and DirectionOfMovement.Magnitude > 0.1 and HumanoidDirectionOfMovement.Magnitude > 0
            
                if Moving and ManagedPlayer.AttemptingSprint and not ManagedPlayer.Exhausted and not ManagedPlayer.PressingSprintWhileRecovering and PlayerSpeedManager.ManagedPlayers[Player].LastMultiplier >= 0.65 and PlayerSpeedManager.ManagedPlayers[Player].CanSprint then
                    ManagedPlayer.SpeedApplied = true

                    if ManagedPlayer.RecoveryThread then
                        task.cancel(ManagedPlayer.RecoveryThread)
                    end

                    -- Fanon Outcome: sprint no longer consumes stamina.
                    -- Character-specific resources use CustomResource values instead.
                    ManagedPlayer.Stamina = ManagedPlayer.MaxStamina.Value

                else

                    if ManagedPlayer.SpeedApplied then
                        ManagedPlayer:_Stop(false)
                        ManagedPlayer.SpeedApplied = false
                    end

                    ManagedPlayer.Stamina = ManagedPlayer.MaxStamina.Value

                end

                if ManagedPlayer.TweenSpeed then
                    local ValueToTweenTo = ManagedPlayer.SpeedApplied and ManagedPlayer.SprintMultiplier or 1
                    
                    PlayerSpeedManager.ManagedPlayers[Player].Factors[FactorName] = math.lerp(PlayerSpeedManager.ManagedPlayers[Player].Factors[FactorName], ValueToTweenTo, delta * 5.5)
                else
                    PlayerSpeedManager.ManagedPlayers[Player].Factors[FactorName] = ManagedPlayer.SpeedApplied and ManagedPlayer.SprintMultiplier or 1
                end

                if StaminaValue.Value ~= ManagedPlayer.Stamina then
                    StaminaValue.Value = ManagedPlayer.Stamina
                end

                if SprintValue.Value ~= ManagedPlayer.SpeedApplied then
                    SprintValue.Value = ManagedPlayer.SpeedApplied
                end
            end))

            CharacterJanitor:Add(Network:SetConnection("ChangeSprintState", "REMOTE_EVENT", function(plr: Player, Pressed: boolean)
                if plr ~= Player then
                    return
                end

                ManagedPlayer.AttemptingSprint = Pressed
                ManagedPlayer.PressingSprintWhileRecovering = false
            end))

            CharacterJanitor:Add(function()
                if PlayerSprintManager.ManagedPlayers[Player].RecoveryThread then
                    task.cancel(PlayerSprintManager.ManagedPlayers[Player].RecoveryThread)
                end
                PlayerSprintManager.ManagedPlayers[Player] = nil
            end, true)

            PlayerSprintManager.ManagedPlayers[Player] = ManagedPlayer
        end)
    end)
end

function SprintModule:_Stop(StopExhausted: boolean)
	self.Recovering = true

	if StopExhausted then
		self.Stamina = 0
		self.PressingSprintWhileRecovering = true
		self.Exhausted = true
		task.delay(self.RecoverExhaustionDelay, function()
			self.Recovering = false
			self.Exhausted = false
		end)
	else
		self.RecoveryThread = task.delay(self.RecoverDelay, function()
			self.Recovering = false
		end)
	end
end

function SprintModule:_DrainStamina(delta: number)
	self.Stamina -= self.StaminaDrainRate.Value * delta
end

function SprintModule:_GainStaminaLegally(delta: number)
	if not self.Recovering and not self.Exhausted and self.Stamina <= self.MaxStamina.Value then
		self.Stamina = math.clamp(self.Stamina + self.StaminaRegenRate.Value * delta, 0, self.MaxStamina.Value :: number)
	end
end

return PlayerSprintManager
