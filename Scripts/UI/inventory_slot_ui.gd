class_name InventorySlotUI
extends PanelContainer


var slot: InventorySlot = null


func set_slot(new_slot: InventorySlot) -> void:
	$MarginContainer/VBoxContainer/Name.text = "" if not new_slot else new_slot.item.item_name
	$MarginContainer/VBoxContainer/Image.texture = null if not new_slot else new_slot.item.item_texture
	$QuantityContainer/Quantity.text = "" if not new_slot else str(new_slot.quantity)
