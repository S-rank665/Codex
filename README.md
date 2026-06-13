# Planetary Apathy Protocol

Roblox Studio / Luau parody survival-exploration prototype inspired by the systemic feel of **Casualties: Unknown**, but with original lore and safe parody mechanics: the explicit self-harm loop is replaced with motivation, refusal, and apathy.

## Implemented foundation

- Third-person-only Roblox camera tuning.
- ModuleScript architecture under `ReplicatedStorage/PlanetApathy`.
- Chipped genetic experiment identity with accessory-derived experiment numbers.
- Player blood color validation that rejects saturated red hues; NPC blood is yellow by config.
- Mood/apathy system with walk-speed penalty, 30% action refusal under low mood, and periodic dialogue.
- Health state model with global stats and per-body-part values for muscle, infection, pain, skin, and bleeding.
- Six-slot body inventory, no filled-container nesting, recognition names for low INT, equipment slots, and item expiry hooks.
- Configurable 11-layer block cave generator using noise plus erosion-pass tuning fields.
- Basic HUD scripts for mutually exclusive inventory, health, and crafting panels.
- Server bootstrap for run state, generated first layer, remotes, and health ticking.

## Roblox setup

Open with Rojo using `default.project.json`, then sync into Roblox Studio. External models, voxel templates, structure files, sounds, animations, shaders, equipment models, and admin-only structure editor content are intentionally represented by code-facing contracts and folders so they can be authored in Studio without hardcoding asset IDs.
