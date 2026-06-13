--!strict
-- Test-only catalogs used by the in-game admin/debug UI.
local DebugCatalog = {}

DebugCatalog.SpawnableItems = {
	{Id = "test_medkit", Name = "Corporate Regret Kit", Kind = "Treatment", Color = Color3.fromRGB(190, 255, 210)},
	{Id = "test_food", Name = "Compressed Lunch Brick", Kind = "Food", Color = Color3.fromRGB(220, 170, 90)},
	{Id = "test_tool", Name = "Questionable Hammer", Kind = "Tool", Color = Color3.fromRGB(160, 160, 175)},
	{Id = "test_scanner", Name = "Planetary Scanner", Kind = "Tool", Color = Color3.fromRGB(80, 180, 255)},
	{Id = "test_blood", Name = "Non-Red Experiment Blood Bag", Kind = "Liquid", Color = Color3.fromRGB(80, 230, 190)},
}

DebugCatalog.Minigames = {
	"Bandage wrap timing",
	"Splinter extraction steadiness",
	"Bone alignment drag",
	"Scanner calibration",
}

DebugCatalog.StructureRoles = {
	"Structure",
	"Starting Capsule",
	"Final Equipment Site",
}

return DebugCatalog
