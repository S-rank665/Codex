local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Classes.Character)
local Ability = require(ReplicatedStorage.Classes.Ability)
local Types = require(ReplicatedStorage.Classes.Types)

local MegaKnuckles: Types.Survivor = Character.CreateSurvivor({
    Config = {
        Name = "Knuckles the Echidna (Mega's Take)",
        SelectionTag = "Knuckles",
        ModelTag = "Knuckles",
        SelectionPoseAnimation = "",
        Quote = "I won't let this happen again.",
        Price = 0,
        Render = "",
    },

    GameplayConfig = {
        Health = 100,
        BaseSpeed = 10.5,
        JumpPower = 50,
        JumpHeight = 7.2,
        UseJumpPower = true,
        Abilities = {
            AvoidExtinction = Ability.New({
                Name = "Avoid Extinction",
                Passive = true,
            }),
            WallCling = Ability.New({
                Name = "Wall Cling",
                Passive = true,
            }),
            FlamesOfFury = Ability.New({
                Name = "Flames of Fury",
                Passive = true,
            }),
            Punch = Ability.New({
                Name = "Punch",
                Cooldown = 24,
                InputName = "FirstAbility",
            }),
            Glide = Ability.New({
                Name = "Glide",
                Cooldown = 25,
                InputName = "ThirdAbility",
            }),
            Uppercut = Ability.New({
                Name = "Uppercut",
                Cooldown = 24,
                InputName = "SecondAbility",
            }),
        },
    },
})

return MegaKnuckles
