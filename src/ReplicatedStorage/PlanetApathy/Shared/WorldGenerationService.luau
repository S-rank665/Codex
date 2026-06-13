--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
local WorldGenerationService = {}
WorldGenerationService.BlockSize = 8

local function getVoxelTemplate(layer)
	local root = workspace:FindFirstChild("PlanetApathyWorkspace")
	local templates = root and root:FindFirstChild("VoxelTemplates")
	if not templates then return nil end
	local name = layer.Biome == "Desert" and "DesertSandVoxel" or layer.Biome == "Basalt" and "BasaltVoxel" or layer.Biome == "Archive" and "ArchiveVoxel" or "CaveStoneVoxel"
	return templates:FindFirstChild(name)
end

local function densityAt(x:number, y:number, z:number, layer, seed:number): number
	local n = math.noise((x + seed) * layer.NoiseScale, y * layer.NoiseScale, (z - seed) * layer.NoiseScale)
	local caveBias = (y / 64) * 0.16
	return n + caveBias
end

function WorldGenerationService.BuildLayerModel(layerId: number, seed: number, parent: Instance): Model
	local layer = Config.Layers[layerId]
	assert(layer, "Unknown layer")
	local model = Instance.new("Model")
	model.Name = "Layer_" .. layerId .. "_" .. layer.Name
	model.Parent = parent
	for x = -10, 10 do
		for y = -4, 4 do
			for z = -10, 10 do
				local d = densityAt(x, y, z, layer, seed)
				if d > (1 - layer.Density) then
					local template = getVoxelTemplate(layer)
					local part = template and template:Clone() or Instance.new("Part")
					part.Name = layer.Biome .. "Voxel"
					part.Size = Vector3.new(WorldGenerationService.BlockSize, WorldGenerationService.BlockSize, WorldGenerationService.BlockSize)
					part.Anchored = true
					part.Position = Vector3.new(x, y, z) * WorldGenerationService.BlockSize
					part:SetAttribute("Layer", layerId)
					part:SetAttribute("BreakResistance", math.floor(10 + layer.TrapDifficulty * 4))
					if not part:FindFirstChild("Sounds") then
						local sounds = Instance.new("Folder"); sounds.Name = "Sounds"; sounds.Parent = part
						for _, s in ipairs({"Footsteps", "Fall", "Place", "Break"}) do Instance.new("Sound", sounds).Name = s end
					end
					part.Parent = model
				end
			end
		end
	end
	local barrier = Instance.new("Part")
	barrier.Name = "LayerTransitionBarrier"
	barrier.Size = Vector3.new(60, 36, 3)
	barrier.Position = Vector3.new(0, 0, -92)
	barrier.Anchored = true
	barrier.Color = Color3.fromRGB(0, 0, 0)
	barrier.Material = Enum.Material.ForceField
	barrier.CanCollide = false
	barrier.Transparency = 0.78
	barrier:SetAttribute("NextLayer", math.min(layerId + 1, #Config.Layers))
	barrier.Parent = model
	return model
end

return WorldGenerationService
