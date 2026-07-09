local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Classes.Character)
local Ability = require(ReplicatedStorage.Classes.Ability)
local Types = require(ReplicatedStorage.Classes.Types)

local MegaSonic: Types.Survivor = Character.CreateSurvivor({
    Config = {
        Name = "Sonic the Hedgehog (Mega's Take)",
        SelectionTag = "Sonic",
        ModelTag = "Sonic",
        SelectionPoseAnimation = "",
        Quote = "I found you, faker!",
        Price = 0,
        Render = "",
    },

    GameplayConfig = {
        Health = 100,
        BaseSpeed = 12.25,
        JumpPower = 50,
        JumpHeight = 7.2,
        UseJumpPower = true,
        Abilities = {
            IFoundYouFaker = Ability.New({
                Name = "I Found You, Faker!",
                Passive = true,
            }),
            TheirSacrifices = Ability.New({
                Name = "Their Sacrifices Won't Be In Vain!",
                Passive = true,
            }),
            Spindash = Ability.New({
                Name = "Spindash",
                Cooldown = 25,
                InputName = "FirstAbility",
            }),
            Peelout = Ability.New({
                Name = "Peelout",
                Cooldown = 40,
                InputName = "SecondAbility",
            }),
            InstaShield = Ability.New({
                Name = "Insta-Shield",
                Cooldown = 15,
                InputName = "JumpAbility",
            }),
        },
    },
})

return MegaSonic
