class_name StallItem
extends Node3D

@onready var interact_label: Label3D = $InteractLabel

@export var item_scene: PackedScene = preload("res://Scenes/planter.tscn")
@export var item: Item = preload("res://Resources/Items/planter.tres")


func _ready() -> void:
	interact_label.text = get_label_text($LookAtDetect.focused)


func _on_look_at_detect_focus_gained() -> void:
	interact_label.text = get_label_text(true)


func _on_look_at_detect_focus_lost() -> void:
	interact_label.text = get_label_text(false)


func get_label_text(show_buy_hint: bool) -> String:
	var info = item.item_name + "\n" + str(item.item_cost) + " coins"
	var buy_hint = "\n [E] Buy"
	return info + (buy_hint if show_buy_hint else "")
