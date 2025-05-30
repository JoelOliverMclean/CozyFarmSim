class_name FirstPersonController
extends CharacterBody3D

@export_group("Movement")
@export var max_speed: float = 4.0
@export var acceleration: float = 20.0
@export var braking: float = 20.0
@export var air_acceleration: float = 4.0
@export var jump_force: float = 5.0
@export var gravity_modifier: float = 1.5
@export var max_run_speed: float = 6.0

@export_group("Camera")
@export var look_sensitivity: float = 0.005

var is_running: bool = false
var camera_look_input: Vector2
var move_input: Vector2

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier
@onready var camera: Camera3D = $HeadRig/Camera3D
@onready var rig: Node3D = $ViewRig


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Apply Gravity
	apply_gravity(delta)
	movement(delta)
	look_input(delta)


func look_input(delta: float) -> void:
	rotate_y(-camera_look_input.x * look_sensitivity)
	rig.rotate_x(-camera_look_input.y * look_sensitivity)
	rig.rotation.x = clamp(rig.rotation.x, -1.2, 1)
	camera_look_input = Vector2.ZERO


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func movement(delta: float) -> void:
	process_jump()
	
	move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	if (Input.is_action_pressed("sprint")):
		var run_dot = clamp(-move_dir.dot(transform.basis.z), 0.0, 1.0)
		move_dir *= run_dot
		animation_player.speed_scale = max_run_speed / max_speed
	else:
		animation_player.speed_scale = 1.0
	
	var current_smoothing = acceleration
	
	if not is_on_floor():
		current_smoothing = air_acceleration
	elif not move_dir:
		current_smoothing = braking
	
	var target_velocity = move_dir * (max_run_speed if is_running else max_speed)
	
	velocity.x = lerp(velocity.x, target_velocity.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, current_smoothing * delta)
	
	move_and_slide()


func process_jump() -> void:
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_mouse_look(event)

func handle_mouse_look(event: InputEventMouseMotion) -> void:
	camera_look_input = event.relative
