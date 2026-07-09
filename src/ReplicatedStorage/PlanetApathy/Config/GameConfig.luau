--!strict
-- Central tuning for the parody survival/exploration prototype.
local GameConfig = {}

GameConfig.CorporationName = "Vesper-Gene Recovery Division"
GameConfig.RunNumberDigits = 6
GameConfig.Camera = {
	MinZoomDistance = 7,
	MaxZoomDistance = 14,
	Mode = Enum.CameraMode.Classic,
}
GameConfig.Controls = {
	Inventory = Enum.KeyCode.Tab,
	HealthPanel = Enum.KeyCode.R,
	Crafting = Enum.KeyCode.C,
	SwapHands = Enum.KeyCode.Q,
	ThrowMainHand = Enum.KeyCode.T,
	Ragdoll = Enum.KeyCode.X,
	Push = Enum.KeyCode.F,
	Crouch = Enum.KeyCode.LeftControl,
	Settings = Enum.KeyCode.P,
	AdminMenu = Enum.KeyCode.F4,
}
GameConfig.Blood = {
	NpcColor = Color3.fromRGB(255, 221, 44),
	DefaultPlayerColor = Color3.fromRGB(80, 230, 190),
	RedHueMin = 345 / 360,
	RedHueMax = 18 / 360,
	MinSaturationForRedBan = 0.42,
	MinValueForRedBan = 0.22,
	LowMoodFade = 0.45,
}
GameConfig.Mood = {
	Min = -100,
	Max = 100,
	LowThreshold = -40,
	RefusalChance = 0.30,
	LowWalkSpeedMultiplier = 0.70,
	DialogueInterval = 60,
	ActionRefusals = {"But...", "No.", "Why?", "Are you serious?", "Hmm...", "Uhm... hmm...", "Ugh. C'mon..."},
	GlobalLines = {
		"I can't take this anymore.",
		"Please... anything to make me feel better...",
		"Damn it... why am I here?",
		"The company calls this data. I call it a bad afternoon.",
	},
}
GameConfig.InventorySlots = {"MainHand", "OffHand", "Mouth", "UpperBack", "MiddleBack", "RearHip"}
GameConfig.EquipmentSlots = {"Head", "Face", "Body", "Hip", "Legs", "Pants"}
GameConfig.BodyParts = {"Head", "Chest", "Abdomen", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
GameConfig.Stats = {
	Brain = 100,
	Hunger = 100,
	Thirst = 100,
	Sickness = 0,
	Weight = 70,
	Stamina = 100,
	Temperature = 37,
	Immunity = 100,
	Calories = 0,
	Radiation = 0,
	Mood = 0,
	STR = 1,
	RES = 1,
	INT = 1,
}
GameConfig.Layers = {
	{Id=1, Name="Caves I", Biome="Caves", Density=0.48, NoiseScale=0.075, ErosionPasses=1, TrapChance=0.10, TrapDifficulty=1, LootChance=0.70, LootMultiplier=1.15, HungerRate=1, Cold=0.2, Radiation=0.00, Modifiers={"QuietStone"}},
	{Id=2, Name="Caves II", Biome="Caves", Density=0.53, NoiseScale=0.070, ErosionPasses=2, TrapChance=0.18, TrapDifficulty=1.2, LootChance=0.62, LootMultiplier=1.00, HungerRate=1.05, Cold=0.35, Radiation=0.01, Modifiers={"EchoTax"}},
	{Id=3, Name="Caves III", Biome="Caves", Density=0.59, NoiseScale=0.064, ErosionPasses=2, TrapChance=0.24, TrapDifficulty=1.45, LootChance=0.55, LootMultiplier=0.90, HungerRate=1.08, Cold=0.45, Radiation=0.02, Modifiers={"CorporateSilence"}},
	{Id=4, Name="Desert I", Biome="Desert", Density=0.44, NoiseScale=0.060, ErosionPasses=1, TrapChance=0.32, TrapDifficulty=1.7, LootChance=0.50, LootMultiplier=0.82, HungerRate=1.18, Heat=0.65, Radiation=0.03, Modifiers={"OilPockets", "FallingStalactites"}},
	{Id=5, Name="Desert II", Biome="Desert", Density=0.47, NoiseScale=0.056, ErosionPasses=2, TrapChance=0.41, TrapDifficulty=2.0, LootChance=0.45, LootMultiplier=0.75, HungerRate=1.24, Heat=0.85, Radiation=0.04, Modifiers={"MirageAccounting"}},
	{Id=6, Name="Desert III", Biome="Desert", Density=0.50, NoiseScale=0.052, ErosionPasses=2, TrapChance=0.50, TrapDifficulty=2.35, LootChance=0.40, LootMultiplier=0.70, HungerRate=1.30, Heat=1.00, Radiation=0.05, Modifiers={"OilPockets", "GlassWind"}},
	{Id=7, Name="Desert IV", Biome="Desert", Density=0.54, NoiseScale=0.050, ErosionPasses=3, TrapChance=0.58, TrapDifficulty=2.65, LootChance=0.36, LootMultiplier=0.64, HungerRate=1.36, Heat=1.15, Radiation=0.06, Modifiers={"FallingStalactites"}},
	{Id=8, Name="Basalt Office", Biome="Basalt", Density=0.57, NoiseScale=0.047, ErosionPasses=3, TrapChance=0.66, TrapDifficulty=3.0, LootChance=0.33, LootMultiplier=0.58, HungerRate=1.42, Cold=0.25, Radiation=0.08, Modifiers={"PaperworkFog"}},
	{Id=9, Name="Wet Static", Biome="Wetlands", Density=0.61, NoiseScale=0.043, ErosionPasses=3, TrapChance=0.74, TrapDifficulty=3.35, LootChance=0.30, LootMultiplier=0.52, HungerRate=1.48, Cold=0.55, Radiation=0.10, Modifiers={"DirtyWater"}},
	{Id=10, Name="Archive Fault", Biome="Archive", Density=0.64, NoiseScale=0.039, ErosionPasses=4, TrapChance=0.82, TrapDifficulty=3.75, LootChance=0.26, LootMultiplier=0.45, HungerRate=1.55, Cold=0.75, Radiation=0.13, Modifiers={"ScannerNoise"}},
	{Id=11, Name="Lost Equipment", Biome="Core", Density=0.68, NoiseScale=0.035, ErosionPasses=4, TrapChance=0.90, TrapDifficulty=4.25, LootChance=0.22, LootMultiplier=0.38, HungerRate=1.65, Cold=0.90, Radiation=0.18, Modifiers={"FinalBeacon"}},
}
GameConfig.FirstRunGoalLayer = 11
GameConfig.AdminUserIds = {}
GameConfig.AdminGroup = {
	UseExperienceGroup = true,
	MinRank = 200,
}
GameConfig.Debug = {
	Enabled = true,
	PickupDistance = 12,
	SpawnHeight = 8,
	DefaultStructureName = "Untitled Test Structure",
}
return GameConfig
