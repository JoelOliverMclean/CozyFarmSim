class_name InventorySlotUI
extends Panel


var slot: InventorySlot = null


func set_slot(new_slot: InventorySlot) -> void:
	$MarginContainer/VBoxContainer/Label.text = "" if not new_slot else new_slot.item.item_name
	$MarginContainer/VBoxContainer/TextureRect.texture = null if not new_slot else new_slot.item.item_texture
	$Label.text = "" if not new_slot else str(new_slot.quantity)
