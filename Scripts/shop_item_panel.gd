class_name ShopItemPanel
extends Panel

signal add_item(item: Item, quantity: int)
signal remove_item(item: Item)

var item: Item
var selected: bool
var purchase_quantity: int
var read_only: bool

@onready var item_name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var image: TextureRect = $MarginContainer/VBoxContainer/Image
@onready var cost_label: Label = $MarginContainer/VBoxContainer/Cost
@onready var selected_indicator: Control = $Selected
@onready var quantity_bar: Control = $MarginContainer/VBoxContainer/QuantityBar
@onready var add_quantity: Button = $MarginContainer/VBoxContainer/QuantityBar/MoreButton
@onready var remove_quantity: Button = $MarginContainer/VBoxContainer/QuantityBar/LessButton
@onready var quantity_edit: LineEdit = $MarginContainer/VBoxContainer/QuantityBar/Quantity


func _ready() -> void:
	item_name_label.text = item.item_name
	image.texture = item.item_texture
	cost_label.text = str(item.item_cost) + " coins"
	add_quantity.visible = not read_only
	remove_quantity.visible = not read_only
	quantity_edit.editable = not read_only


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			toggle_selected()


func toggle_selected():
	if not read_only:
		if selected:
			if purchase_quantity <= 0:
				selected = false
		else:
			selected = true
			update_purchase_quantity(1)
		selected_indicator.visible = selected


func update_purchase_quantity(increment: int) -> void:
	purchase_quantity += increment
	quantity_bar.visible = purchase_quantity > 0
	quantity_edit.text = str(purchase_quantity)
	if purchase_quantity <= 0:
		if selected:
			toggle_selected()
		remove_item.emit(item)
	else:
		add_item.emit(item, increment)
	if read_only:
		cost_label.text = str(item.item_cost * purchase_quantity) + " coins"


func _on_less_button_pressed() -> void:
	update_purchase_quantity(-1)


func _on_more_button_pressed() -> void:
	update_purchase_quantity(1)
