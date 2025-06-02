class_name InventoryUI
extends Menu


@onready var slot_container := get_node("Panel/MarginContainer/VBoxContainer/ScrollContainer/HFlowContainer")

@onready var inventory_slot_ui: PackedScene = preload("res://Scenes/UI/inventory_slot_ui.tscn")


func redraw_inventory(inventory: Inventory):
	if slot_container:
		for child in slot_container.get_children():
			child.queue_free()
		if inventory:
			for index in range(inventory.slot_count):
				var inventory_slot_ui: InventorySlotUI = inventory_slot_ui.instantiate()
				slot_container.add_child(inventory_slot_ui)
				var inventory_slot: InventorySlot = inventory.slots.get(index, null)
				inventory_slot_ui.set_slot(inventory_slot)
