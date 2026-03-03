--!strict
-- ModuleScript: ServerScriptService > PlayerEquippedEmotes
-- Хранит и сохраняет список "одетых" эмоций для каждого игрока.
-- Можно вызывать из других серверных скриптов.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_EMOTES = 4
local STORE_NAME = "PlayerEquippedEmotes_v2"

local store = DataStoreService:GetDataStore(STORE_NAME)

local PlayerEquippedEmotes = {}

local cache: { [number]: { string } } = {}
local playerByUserId: { [number]: Player } = {}

local function sanitizeList(input: any): { string }
	local result: { string } = {}
	if type(input) ~= "table" then
		return result
	end

	local unique: { [string]: boolean } = {}
	for _, value in input do
		if type(value) == "string" and value ~= "" and not unique[value] then
			unique[value] = true
			table.insert(result, value)
			if #result >= MAX_EMOTES then
				break
			end
		end
	end

	return result
end

function PlayerEquippedEmotes.LoadForPlayer(player: Player): { string }
	playerByUserId[player.UserId] = player

	local success, data = pcall(function()
		return store:GetAsync(tostring(player.UserId))
	end)

	if success then
		cache[player.UserId] = sanitizeList(data)
	else
		warn("[PlayerEquippedEmotes] Ошибка загрузки:", data)
		cache[player.UserId] = {}
	end

	return cache[player.UserId]
end

function PlayerEquippedEmotes.GetEquipped(player: Player): { string }
	return cache[player.UserId] or {}
end

function PlayerEquippedEmotes.SetEquipped(player: Player, emoteNames: { string }): { string }
	local sanitized = sanitizeList(emoteNames)
	cache[player.UserId] = sanitized
	return sanitized
end

function PlayerEquippedEmotes.SaveForPlayer(player: Player)
	local data = cache[player.UserId] or {}
	local success, err = pcall(function()
		store:SetAsync(tostring(player.UserId), data)
	end)

	if not success then
		warn("[PlayerEquippedEmotes] Ошибка сохранения:", err)
	end

	cache[player.UserId] = nil
	playerByUserId[player.UserId] = nil
end

function PlayerEquippedEmotes.NotifyChanged(player: Player)
	local remotes = ReplicatedStorage:FindFirstChild("EmoteRemotes")
	if not remotes then
		return
	end

	local changedEvent = remotes:FindFirstChild("EquippedEmotesChanged")
	if changedEvent and changedEvent:IsA("RemoteEvent") then
		changedEvent:FireClient(player, cache[player.UserId] or {})
	end
end

Players.PlayerRemoving:Connect(function(player)
	PlayerEquippedEmotes.SaveForPlayer(player)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		PlayerEquippedEmotes.SaveForPlayer(player)
	end
end)

return PlayerEquippedEmotes
