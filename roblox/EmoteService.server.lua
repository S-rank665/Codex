--!strict
-- Script: ServerScriptService > EmoteService.server.lua
-- Мост между клиентом и модулем PlayerEquippedEmotes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerEquippedEmotes = require(script.Parent:WaitForChild("PlayerEquippedEmotes"))

local remotesFolder = ReplicatedStorage:FindFirstChild("EmoteRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "EmoteRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local getEquippedEmotes = remotesFolder:FindFirstChild("GetEquippedEmotes")
if not getEquippedEmotes then
	getEquippedEmotes = Instance.new("RemoteFunction")
	getEquippedEmotes.Name = "GetEquippedEmotes"
	getEquippedEmotes.Parent = remotesFolder
end

local setEquippedEmotes = remotesFolder:FindFirstChild("SetEquippedEmotes")
if not setEquippedEmotes then
	setEquippedEmotes = Instance.new("RemoteEvent")
	setEquippedEmotes.Name = "SetEquippedEmotes"
	setEquippedEmotes.Parent = remotesFolder
end

local changedEvent = remotesFolder:FindFirstChild("EquippedEmotesChanged")
if not changedEvent then
	changedEvent = Instance.new("RemoteEvent")
	changedEvent.Name = "EquippedEmotesChanged"
	changedEvent.Parent = remotesFolder
end

Players.PlayerAdded:Connect(function(player)
	local loaded = PlayerEquippedEmotes.LoadForPlayer(player)
	changedEvent:FireClient(player, loaded)
end)

(getEquippedEmotes :: RemoteFunction).OnServerInvoke = function(player: Player)
	return PlayerEquippedEmotes.GetEquipped(player)
end

(setEquippedEmotes :: RemoteEvent).OnServerEvent:Connect(function(player: Player, newList: { string })
	local updated = PlayerEquippedEmotes.SetEquipped(player, newList)
	changedEvent:FireClient(player, updated)
end)
