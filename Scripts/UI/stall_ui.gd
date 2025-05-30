class_name StallUI
extends Menu


@onready var sign: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/ShopNameLabel")
@onready var items_to_buy: HFlowContainer = $MarginContainer/VBoxContainer/TabContainer/Buy/MarginContainer/VBoxContainer/ScrollContainer/ItemsToBuy
@onready var item_panel_scene: PackedScene = preload("res://Scenes/UI/shop_item_panel.tscn")


func init(name: String) -> void:
	sign.text = name


func _on_buy_button_pressed() -> void:
	pass # Replace with function body.


func _on_sell_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	var stall = get_parent()
	if stall is Stall:
		stall.close_shop()


func display_items(items: Array[ShopItem]) -> void:
	for child in items_to_buy.get_children():
		child.queue_free()
	for item in items:
		var item_panel: ShopItemPanel = item_panel_scene.instantiate()
		item_panel.init(item.item_name, item.icon, item.cost)
		items_to_buy.add_child(item_panel)
	
