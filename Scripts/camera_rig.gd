class_name CameraRig
extends Node3D


@export var camera_collision_mask = 0

@onready var camera: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $RayCast3D


func camera_look(camera_look_input: Vector2, look_sensitivity: float, camera_distance: float, delta: float):
	rotate_x(-camera_look_input.y * look_sensitivity)
	rotation.x = clamp(rotation.x, -1.2, 1)


func detect_raycast() -> Node3D:
	return raycast.get_collider()
