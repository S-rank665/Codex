local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Classes.Character)
local Ability = require(ReplicatedStorage.Classes.Ability)
local Types = require(ReplicatedStorage.Classes.Types)

local Mega2011X: Types.Killer = Character.CreateKiller({
    Config = {
        Name = "2011X (Mega's Take)",
        SelectionTag = "2011X",
        ModelTag = "2011X",
        SelectionPoseAnimation = "",
        SelectionSounds = {},
        Quote = "Hide and seek.",
        Price = 0,
        Render = "",
    },

    GameplayConfig = {
        Health = 1200,
        BaseSpeed = 11.5,
        JumpPower = 50,
        JumpHeight = 7.2,
        UseJumpPower = true,
        ResourceProperties = {
            ResourceName = "Temper",
            Resource = 0,
            MaxResource = 100,
            ResourceVisible = true,
        },
        Abilities = {
            Impatience = Ability.New({
                Name = "Impatience",
                Passive = true,
            }),
            RageMeter = Ability.New({
                Name = "Rage Meter",
                Passive = true,
            }),
            Attack = Ability.New({
                Name = "Attack",
                Cooldown = 1,
                InputName = "Slash",
                Damage = 42,
            }),
            HideAndSeek = Ability.New({
                Name = "Hide and Seek",
                Cooldown = 30,
                InputName = "SecondAbility",
            }),
            Kick = Ability.New({
                Name = "Kick",
                Cooldown = 15,
                InputName = "ThirdAbility",
            }),
            Invisibility = Ability.New({
                Name = "Invisibility",
                Cooldown = 25,
                InputName = "FirstAbility",
            }),
            RageMode = Ability.New({
                Name = "Rage Mode",
                Cooldown = 0,
                InputName = "FourthAbility",
            }),
        },
    },
})

return Mega2011X
