extends Node3D


@export var interactables: Array[Node3D] = []

@onready var activate_area: Area3D = $ActivateArea
@onready var shopkeep: CharacterBody3D = $Shopkeep


var player: Player
var active: bool


func _on_activate_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		activate_items(true)
		player = body


func _on_activate_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		activate_items(false)
		player = null


func activate_items(activate: bool) -> void:
	active = activate
	for item in interactables:
		item.visible = activate


func _physics_process(delta: float) -> void:
	if active and player:
		shopkeep.axis_lock_angular_x = true
		shopkeep.axis_lock_angular_z = true
		var look_at_target = player.global_position
		shopkeep.look_at(look_at_target)
