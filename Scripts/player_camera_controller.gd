class_name PlayerCameraController
extends Node3D


@onready var first_person_cam_rig: FirstPersonCameraRig = $FirstPersonCamRig
@onready var third_person_cam_rig: ThirdPersonCameraRig = $ThirdPersonCamRig
@onready var player: Player = get_parent()

var active_rig: CameraRig
var camera_distance = 0.0
var zoom = 0.0
var camera_look_input: Vector2
var look_sensitivity: float = 0.005

var rotate_y_target: float
var was_moving: bool


func _ready() -> void:
	active_rig = first_person_cam_rig
	rotate_y_target = global_rotation.y


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_down"):
		zoom = clamp(zoom + 1.0, 0.0, 3.0)
	if event.is_action_pressed("scroll_up"):
		zoom = clamp(zoom - 1.0, 0.0, 3.0)


func look_input(delta: float) -> void:
	rotate_y_target += -camera_look_input.x * look_sensitivity
	if active_rig is FirstPersonCameraRig:
		get_parent().global_rotation.y = rotate_y_target
	elif player.move_dir.length() != 0:
		if not was_moving:
			rotation.y = 0
		
		get_parent().global_rotation.y = rotate_y_target
		
		was_moving = true
	else:
		global_rotation.y = rotate_y_target
		
		was_moving = false
	
	if zoom < 1:
		third_person_cam_rig.position.x = lerp(third_person_cam_rig.position.x, 0.0, 10.0 * delta)
	else:
		third_person_cam_rig.position.x = lerp(third_person_cam_rig.position.x, 0.6, 10.0 * delta)
	camera_distance = lerp(camera_distance, -zoom, 10.0 * delta)
	first_person_cam_rig.camera_look(camera_look_input, look_sensitivity, camera_distance, delta)
	third_person_cam_rig.camera_look(camera_look_input, look_sensitivity, camera_distance, delta)
	update_camera_view()
	camera_look_input = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not Game.paused:
		camera_look_input = event.relative


func update_camera_view():
	set_current(Enums.CameraView.THIRD if camera_distance < -0.25 else Enums.CameraView.FIRST)


func set_first_person():
	zoom = 0.0
	camera_distance = 0.0
	set_current(Enums.CameraView.FIRST)


func set_current(camera_view: Enums.CameraView):
	first_person_cam_rig.camera.current = camera_view == Enums.CameraView.FIRST
	third_person_cam_rig.camera.current = camera_view == Enums.CameraView.THIRD
	update_active_rig()


func update_active_rig():
	if first_person_cam_rig.camera.current:
		active_rig = first_person_cam_rig
	elif third_person_cam_rig.camera.current:
		active_rig = third_person_cam_rig
	else:
		active_rig = null


func detect_raycast() -> Node3D:
	if not active_rig:
		return null
	return active_rig.detect_raycast()
