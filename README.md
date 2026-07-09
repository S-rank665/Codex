# Planetary Apathy Protocol

Roblox Studio / Luau parody survival-exploration prototype with original lore and safe parody mechanics: explicit self-harm loops are replaced with motivation, refusal, and apathy.

## What is editable in Studio now

- `StarterGui/PlanetApathyGui.rbxmx` contains real Roblox UI instances: health, inventory, crafting, shader placeholder, and admin panels. Runtime scripts only find and control these frames; they no longer build the menus from code.
- `Workspace/PlanetApathyWorkspace.rbxmx` contains editable placeholder folders for voxel templates, item templates, structures, effects, and generated layers.
- `ReplicatedStorage/PlanetApathyAssets/PlanetApathyAssets.rbxmx` contains empty `Animation` instances for ragdoll locomotion, rest states, medical minigames, and face states. Put animation ids there later.
- `SoundService/PlanetApathyAudio.rbxmx` contains empty sound placeholders for music layers and organism/body sounds. Put sound ids there later.

## Implemented foundation

- Third-person-only Roblox camera tuning.
- ModuleScript architecture under `ReplicatedStorage/PlanetApathy`.
- Chipped genetic experiment identity with accessory-derived experiment numbers.
- Player blood color validation that rejects saturated red hues; NPC blood is yellow by config.
- Mood/apathy system with walk-speed penalty, 30% action refusal under low mood, and periodic dialogue.
- Health state model with global stats and per-body-part values for muscle, infection, pain, skin, and bleeding.
- Six-slot body inventory, no filled-container nesting, recognition names for low INT, equipment slots, and item expiry hooks.
- Configurable 11-layer block cave generator using editable 2-stud voxel templates plus noise/erosion tuning fields.
- Test HUD for health, inventory, crafting, settings, dialogue bubbles, shader placeholders, and admin debugging.
- Server bootstrap for run state, generated first layer, remotes, health ticking, state replication, and admin commands.

## Controls

- `TAB` inventory. Press again to close.
- `R` health panel. Press again to close.
- `C` crafting panel. Press again to close.
- `P` settings panel. Press again to close.
- `F4` admin debug panel, only when admin access is granted.
- Right mouse button picks up item Parts with an `ItemId` attribute.
- Left mouse button uses/attacks with the main hand through the apathy action gate.
- Middle mouse button locks camera rotation while held.

## Admin debug access

The debug panel is available when either:

1. The player user id is listed in `GameConfig.AdminUserIds`.
2. The experience is user-owned and the player is the creator.
3. The experience is group-owned and `GameConfig.AdminGroup.UseExperienceGroup` is `true`; players with rank `GameConfig.AdminGroup.MinRank` or higher can use it.

By default the group rank threshold is `200`, so owners/admins in the Roblox community group can test without hardcoding a single user id.

## Roblox setup

Open with Rojo using `default.project.json`, then sync into Roblox Studio. The project maps `Workspace`, `ReplicatedStorage`, `ServerScriptService`, `SoundService`, `StarterPlayerScripts`, and `StarterGui` so placeholder content can be edited directly in Studio.
