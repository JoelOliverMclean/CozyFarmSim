class_name StallUI
extends Menu


@onready var player: Player = get_tree().get_first_node_in_group("Player")

@onready var sign: Label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/ShopNameLabel
@onready var items_to_buy: HFlowContainer = $MarginContainer/VBoxContainer/HBoxContainer/TabContainer/Buy/MarginContainer/HBoxContainer/VBoxContainer/ScrollContainer/ItemsToBuy
@onready var total_buy_amount: Label = $MarginContainer/VBoxContainer/HBoxContainer/TabContainer/Buy/MarginContainer/HBoxContainer/BasketContainer/Basket/MarginContainer/VBoxContainer/TotalBuyAmount
@onready var basket: Basket = $MarginContainer/VBoxContainer/HBoxContainer/TabContainer/Buy/MarginContainer/HBoxContainer/BasketContainer/Basket/MarginContainer/VBoxContainer/ScrollContainer/BasketItems
@onready var buy_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/TabContainer/Buy/MarginContainer/HBoxContainer/BasketContainer/Basket/MarginContainer/VBoxContainer/BuyButton
@onready var coins_label: Label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/CoinsLabel
@onready var buy_item_panels: Array[ShopItemPanel] = []

@onready var item_panel_scene: PackedScene = preload("res://Scenes/UI/shop_item_panel.tscn")

var cart: Dictionary[Item, int] = {}


func init(name: String) -> void:
	sign.text = name


func _on_buy_button_pressed() -> void:
	var cost = basket.get_cost()
	player.coins -= cost
	basket.give_basket_items_to_player(player)
	empty_basket()


func _on_sell_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	empty_basket()
	var stall = get_parent()
	if stall is Stall:
		stall.close_shop()


func empty_basket() -> void:
	for item in items_to_buy.get_children():
		if item is ShopItemPanel:
			item.update_purchase_quantity(-item.purchase_quantity)
	basket.empty()
	update_cart_ui()


func display_items(items: Array[Item]) -> void:
	for child in items_to_buy.get_children():
		child.queue_free()
	for item in items:
		var item_panel: ShopItemPanel = item_panel_scene.instantiate()
		item_panel.item = item
		item_panel.add_item.connect(item_added)
		item_panel.remove_item.connect(item_removed)
		items_to_buy.add_child(item_panel)


func item_added(item: Item, quantity: int):
	if cart.has(item):
		cart[item] += quantity
		if cart[item] == 0:
			cart.erase(item)
			basket.remove_item(item)
		else:
			basket.add_item(item, quantity)
	else:
		basket.add_item(item, 1)
		cart.set(item, quantity)
	update_cart_ui()


func item_removed(item: Item):
	cart.erase(item)
	basket.remove_item(item)
	update_cart_ui()


func update_cart_ui():
	total_buy_amount.text = "Total: " + str(basket.get_cost()) + " coins"
	buy_button.disabled = cart.is_empty() || basket.get_cost() > get_tree().get_first_node_in_group("Player").coins
	coins_label.text = "Coins: " + str(player.coins)
	total_buy_amount.label_settings.font_color = Color.RED if basket.get_cost() > get_tree().get_first_node_in_group("Player").coins else Color.WHITE


func open_close() -> void:
	super.open_close()
	coins_label.text = "Coins: " + str(player.coins)
	if visible:
		player.coins_adjusted.connect(on_player_coins_adjusted)
	else:
		player.coins_adjusted.disconnect(on_player_coins_adjusted)


func on_player_coins_adjusted(new_coins: int) -> void:
	update_cart_ui()
