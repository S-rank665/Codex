# Planetary Apathy Protocol

Roblox Studio / Luau parody survival-exploration prototype inspired by systemic survival games, with original lore and safe parody mechanics: explicit self-harm loops are replaced with motivation, refusal, and apathy.

## Implemented foundation

- Third-person-only Roblox camera tuning.
- ModuleScript architecture under `ReplicatedStorage/PlanetApathy`.
- Chipped genetic experiment identity with accessory-derived experiment numbers.
- Player blood color validation that rejects saturated red hues; NPC blood is yellow by config.
- Mood/apathy system with walk-speed penalty, 30% action refusal under low mood, and periodic dialogue.
- Health state model with global stats and per-body-part values for muscle, infection, pain, skin, and bleeding.
- Six-slot body inventory, no filled-container nesting, recognition names for low INT, equipment slots, and item expiry hooks.
- Configurable 11-layer block cave generator using noise plus erosion-pass tuning fields.
- Test HUD for health, inventory, crafting, dialogue bubbles, and admin debugging.
- Server bootstrap for run state, generated first layer, remotes, health ticking, state replication, and admin commands.

## Admin debug access

The debug panel is available when either:

1. The player user id is listed in `GameConfig.AdminUserIds`.
2. The experience is user-owned and the player is the creator.
3. The experience is group-owned and `GameConfig.AdminGroup.UseExperienceGroup` is `true`; players with rank `GameConfig.AdminGroup.MinRank` or higher can use it.

By default the group rank threshold is `200`, so owners/admins in the Roblox community group can test without hardcoding a single user id. Press **F4** or the **ADMIN DEBUG** button to open the panel.

## Roblox setup

Open with Rojo using `default.project.json`, then sync into Roblox Studio. External models, voxel templates, structure files, sounds, animations, shaders, equipment models, and the production structure editor are intentionally represented by code-facing contracts and test controls so they can be authored in Studio without hardcoding asset IDs.
