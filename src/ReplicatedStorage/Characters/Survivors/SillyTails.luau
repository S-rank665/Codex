local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Classes.Character)
local Ability = require(ReplicatedStorage.Classes.Ability)
local Types = require(ReplicatedStorage.Classes.Types)

local SillyTails: Types.Survivor = Character.CreateSurvivor({
    Config = {
        Name = "Tails (Silly's Take)",
        SelectionTag = "Tails",
        ModelTag = "Tails",
        SelectionPoseAnimation = "",
        Quote = "I can still help!",
        Price = 0,
        Render = "",
    },

    GameplayConfig = {
        Health = 80,
        BaseSpeed = 10.5,
        JumpPower = 50,
        JumpHeight = 7.2,
        UseJumpPower = true,
        Abilities = {
            MetalSupport = Ability.New({
                Name = "Metal Support",
                Passive = true,
            }),
            RingEnergy = Ability.New({
                Name = "Ring Energy",
                Passive = true,
            }),
            Spindash = Ability.New({
                Name = "Spindash",
                Cooldown = 22,
                InputName = "FirstAbility",
            }),
            Glide = Ability.New({
                Name = "Glide",
                Cooldown = 25,
                InputName = "SecondAbility",
            }),
            TailSpin = Ability.New({
                Name = "Tail Spin",
                Cooldown = 24,
                InputName = "ThirdAbility",
            }),
        },
    },
})

return SillyTails
