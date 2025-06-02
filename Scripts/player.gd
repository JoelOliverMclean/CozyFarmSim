class_name Player
extends CharacterController


signal coins_adjusted(new_coins: int)


@export_group("Stuff")
@export var bed: Bed
@export var day_night_cycle: DayNightCycle


var inventory: Inventory = Inventory.new()
var colliding_node: Node3D
var asleep: bool
var current_menu: Menu
var coins: int = 30:
	set(value):
		coins = value
		coins_adjusted.emit(value)

var previous_transform: Transform3D
var previous_rotation: Vector3
var previous_parent: Node3D
var jumping: bool


@onready var inventory_ui := $InventoryUI
@onready var model_anim := $Model/AnimationPlayer
@onready var model := $Model

@onready var animation_player: AnimationPlayer = $CameraController/FirstPersonCamRig/AnimationPlayer
@onready var camera_controller: PlayerCameraController = $CameraController


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	inventory_ui.redraw_inventory(inventory)
	inventory.inventory_updated.connect(_on_inventory_updated)
	go_to_bed.call_deferred()


func go_to_bed() -> void:
	if bed and not day_night_cycle.is_daytime():
		asleep = true
		previous_parent = get_parent()
		var wake_marker: Marker3D = bed.get_parent().get_node("WakeMarker")
		global_transform = wake_marker.global_transform
		global_rotation = wake_marker.global_rotation
		bed.go_to_bed(self)
		previous_transform = transform
		previous_rotation = rotation
		reparent(bed.get_node("SleepMarker"))
		transform = Transform3D()
		model.transform = Transform3D()
		camera_controller.set_current(Enums.CameraView.NONE)
		day_night_cycle.player_asleep = true


func _on_inventory_updated() -> void:
	inventory_ui.redraw_inventory(inventory)


func get_out_of_bed():
	if asleep && bed && get_parent().get_parent() == bed:
		day_night_cycle.player_asleep = false
		bed.wake_player()


func awoken():
	camera_controller.set_first_person()
	asleep = false
	reparent(previous_parent)
	previous_parent = null
	transform = previous_transform
	model.transform = Transform3D()


func _input(event: InputEvent) -> void:
	if not current_menu:
		if event.is_action_pressed("interact"):
			if asleep:
				get_out_of_bed()
			elif colliding_node:
				interact()
		if event.is_action_pressed("inventory"):
			inventory_ui.open_close()


func interact() -> void:
	if colliding_node.get_parent() is Door:
		colliding_node.get_parent().open_close()
	if colliding_node.get_parent() is Stall:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		colliding_node.get_parent().open_shop()
	if bed && colliding_node.get_parent() == bed:
		go_to_bed()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Game.pause()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Game.resume()
			if current_menu:
				current_menu.open_close()
	if not asleep:
		pass
	elif day_night_cycle.is_daytime() and bed.can_get_out():
		get_out_of_bed()


func menu_opened(menu: Menu) -> void:
	current_menu = menu
	current_menu.menu_closed.connect(on_menu_closed)


func on_menu_closed() -> void:
	current_menu.menu_closed.disconnect(on_menu_closed)
	current_menu = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	process_animations(delta)
	if not Game.paused:
		super._physics_process(delta)
		if not current_menu:
			detect_raycast()
			if not asleep:
				camera_controller.look_input(delta)


func detect_raycast() -> void:
	var collider = camera_controller.detect_raycast()
	if collider and not asleep:
		if colliding_node && colliding_node != collider:
			hover_node(colliding_node, false)
		colliding_node = collider
		hover_node(colliding_node, true)
	else:
		if colliding_node:
			hover_node(colliding_node, false)
			colliding_node = null


func hover_node(node: Node3D, hover: bool) -> void:
	if node is Interactable:
		node.focus(hover)


func process_animations(delta: float) -> void:
	if jumping:
		if model_anim.current_animation != "Jump":
			model_anim.play("Jump")
	elif is_on_floor() and (get_move_input().length() != 0 || (camera_controller.camera_look_input.x != 0 and camera_controller.active_rig is ThirdPersonCameraRig)):
		if model_anim.current_animation != "Walk":
			model_anim.play("Walk")
		if animation_player.current_animation != "Walking":
			animation_player.play("Walking")
	else:
		if model_anim.current_animation != "Idle":
			model_anim.play("Idle")
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
	
	rotate_model(delta)


func rotate_model(delta: float):
	if move_dir.length() > 0:
		var target_transform = Transform3D().looking_at(move_dir, Vector3.UP)
		var current_basis = model.global_transform.basis

		# Smoothly interpolate basis (rotation) towards target
		model.global_transform.basis = current_basis.slerp(target_transform.basis, 10.0 * delta)


func get_move_input() -> Vector2:
	if current_menu or Game.paused or asleep:
		return Vector2()
	return super.get_move_input()


#func actual_jump() -> void:
	#if is_on_floor() and jumping:
		#velocity.y = jump_force


func jump_input() -> void:
	if Input.is_action_pressed("jump") and is_on_floor():
		jumping = true
		velocity.y = jump_force


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Jump":
		jumping = false
