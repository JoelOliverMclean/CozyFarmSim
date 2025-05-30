class_name Stall
extends StaticBody3D


@export var sign_text: String

@export var inventory: Array[ShopItem] = []


@onready var look_at: Interactable = get_node("LookAtDetect")
@onready var interact_label: Label3D = get_node("InteractLabel")
@onready var sign: Label3D = get_node("Sign")
@onready var stall_ui: StallUI = get_node("StallUI")


func _ready() -> void:
	sign.text = sign_text
	stall_ui.init(sign_text)
	stall_ui.display_items(inventory)


func _on_look_at_detect_focus_gained() -> void:
	interact_label.visible = true


func _on_look_at_detect_focus_lost() -> void:
	interact_label.visible = false


func close_shop():
	stall_ui.open_close()


func open_shop():
	stall_ui.open_close()
