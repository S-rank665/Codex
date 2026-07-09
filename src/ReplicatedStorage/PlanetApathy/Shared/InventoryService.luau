--!strict
local Config = require(script.Parent.Parent.Config.GameConfig)
export type Item = {Id:string, Name:string, Kind:string, Qualities:{string}?, Recognition:number?, Container:{Item}?, Capacity:number?, Filled:boolean?, ExpiresAt:number?, EquipmentSlot:string?, LiquidColor:Color3?, Damage:number?, Durability:number?}
local InventoryService = {}

function InventoryService.NewInventory()
	local slots = {Equipment = {}}
	for _, slot in ipairs(Config.InventorySlots) do slots[slot] = nil end
	for _, slot in ipairs(Config.EquipmentSlots) do slots.Equipment[slot] = nil end
	return slots
end

function InventoryService.CanStore(container: Item, item: Item): (boolean, string?)
	if not container.Capacity then return false, "Target is not a container" end
	if item.Container and #(item.Container) > 0 then return false, "Filled containers cannot be nested" end
	if #(container.Container or {}) >= container.Capacity then return false, "Container is full" end
	return true, nil
end

function InventoryService.DisplayName(item: Item, intelligence: number): (string, string)
	if intelligence >= (item.Recognition or 0) then return item.Name, "Recognized corporate salvage." end
	local generic = item.Kind == "Treatment" and "Some kind of treatment" or ("Some kind of " .. string.lower(item.Kind))
	return generic, "You're not smart enough to know that."
end

function InventoryService.Equip(inventory, item: Item): (boolean, string?)
	local slot = item.EquipmentSlot
	if not slot then return false, "This item is not equipment" end
	if inventory.Equipment[slot] then return false, "Equipment slot occupied" end
	inventory.Equipment[slot] = item
	return true, nil
end

function InventoryService.TickExpiry(inventory, now: number, dropCallback: (Item) -> ())
	for slot, item in pairs(inventory) do
		if slot ~= "Equipment" and type(item) == "table" and item.ExpiresAt and item.ExpiresAt <= now then
			if item.Container then for _, inside in ipairs(item.Container) do dropCallback(inside) end end
			inventory[slot] = nil
			dropCallback(item)
		end
	end
end

return InventoryService
