class_name Inventory
extends Object


signal inventory_updated


var slot_size: int = 64
var slot_count: int = 12
var slots: Dictionary[int, InventorySlot]


func next_space() -> int:
	for i in range(slot_count):
		if not slots.get(i, null):
			return i
	return -1


func item_in_slot(slot: InventorySlot, other: Item) -> bool:
	return slot.item.item_name == other.item_name


# Returns number of items failed to add due to space
func add_item(item: Item, quantity: int) -> int:
	var existing_index = slots.values().find_custom(item_in_slot.bind(item))
	if existing_index >= 0 && slots[existing_index].quantity < slot_size:
		return _add_item_to_slot(existing_index, item, quantity)
	else:
		return _add_item_to_slot(next_space(), item, quantity)


func _add_item_to_slot(slot: int, item: Item, quantity: int) -> int:
	var existing_slot = slots.get(slot, null)
	if not existing_slot:
		existing_slot = InventorySlot.new()
		existing_slot.item = item
	var existing_quantity = existing_slot.quantity
	var space_left_in_slot = slot_size - existing_quantity
	var remaining_quantity = quantity - space_left_in_slot
	var quantity_to_add = quantity if remaining_quantity <= 0 else quantity - remaining_quantity
	existing_slot.quantity += quantity_to_add
	slots.set(slot, existing_slot)
	if remaining_quantity >= 0:
		var next_space = next_space()
		if next_space >= 0:
			return _add_item_to_slot(next_space, item, remaining_quantity)
		else:
			return remaining_quantity
	else:
		return 0


func remove_item(item: Item, quantity: int) -> void:
	pass


func check() -> void:
	inventory_updated.emit()
