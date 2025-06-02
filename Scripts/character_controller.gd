class_name CharacterController
extends CharacterBody3D

@export_group("Movement")
@export var max_speed: float = 4.0
@export var acceleration: float = 20.0
@export var braking: float = 20.0
@export var air_acceleration: float = 4.0
@export var jump_force: float = 5.0
@export var gravity_modifier: float = 1.5
@export var max_run_speed: float = 6.0

var move_dir: Vector3
var is_running: bool

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	movement(delta)
	
	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func jump_input() -> void:
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force


func movement(delta: float) -> void:
	jump_input()
	
	var move_input = get_move_input()
	move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	if (Input.is_action_pressed("sprint")):
		is_running = true
	else:
		is_running = false
	
	var current_smoothing = acceleration
	
	if not is_on_floor():
		current_smoothing = air_acceleration
	elif not move_dir:
		current_smoothing = braking
	
	var target_velocity = move_dir * (max_run_speed if is_running else max_speed)
	
	velocity.x = lerp(velocity.x, target_velocity.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, current_smoothing * delta)


func get_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")
