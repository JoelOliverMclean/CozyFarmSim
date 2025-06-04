class_name StallWithItems
extends StaticBody3D


@export var sign_text_line_1: String
@export var sign_text_line_2: String = "Market Stall"

@onready var shop_sign_line_1: Label3D = get_node("Sign")
@onready var shop_sign_line_2: Label3D = get_node("Sign2")
@onready var render_items_detect: Area3D = $RenderItemsSphere


func _ready() -> void:
	shop_sign_line_1.text = sign_text_line_1
	shop_sign_line_2.text = sign_text_line_2


func _on_render_items_sphere_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$StallItem.interact_label.visible = true
		(body as Player).set_shop_ui(self)


func _on_render_items_sphere_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$StallItem.interact_label.visible = false
		(body as Player).set_shop_ui(null)


func on_player_coins_adjusted(new_coins) -> void:
	pass
