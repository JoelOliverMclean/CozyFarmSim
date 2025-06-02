class_name Basket
extends VBoxContainer

@onready var item_panel_scene: PackedScene = preload("res://Scenes/UI/shop_item_panel.tscn")


var items: Dictionary[Item, ShopItemPanel]


func add_item(item: Item, quantity: int):
	if items.has(item):
		var item_panel = items[item]
		item_panel.update_purchase_quantity(quantity)
	else:
		var item_panel: ShopItemPanel = item_panel_scene.instantiate()
		item_panel.item = item
		item_panel.read_only = true
		items.set(item, item_panel)
		add_child(item_panel)
		item_panel.update_purchase_quantity(quantity)


func remove_item(item: Item):
	if items.has(item):
		items[item].queue_free()
		items.erase(item)


func get_cost() -> int:
	var total_cost = 0
	for item in items:
		total_cost += items[item].purchase_quantity * item.item_cost
	return total_cost


func empty() -> void:
	for item in items:
		items[item].queue_free()
	items.clear()


func give_basket_items_to_player(player: Player) -> void:
	for item in items:
		var item_panel = items[item]
		player.inventory.add_item(item, item_panel.purchase_quantity)
	player.inventory.check()
