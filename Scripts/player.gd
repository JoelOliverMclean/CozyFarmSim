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

var current_stall: StallWithItems
var was_moving: bool


@onready var inventory_ui := $InventoryUI
@onready var model_anim := $Model/AnimationPlayer
@onready var model := $Model

@onready var animation_player: AnimationPlayer = $CameraController/FirstPersonCamRig/AnimationPlayer
@onready var camera_controller: PlayerCameraController = $CameraController
@onready var hud: HUD = $HUD
@onready var hold_marker: Marker3D = $Model/HoldMarker

var held_object: Node3D = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	inventory_ui.redraw_inventory(inventory)
	inventory.inventory_updated.connect(_on_inventory_updated)
	go_to_bed.call_deferred()
	hud.update_coins(coins)
	coins_adjusted.connect(_on_coins_adjusted)


func _on_coins_adjusted(new_coins) -> void:
	hud.update_coins(new_coins)


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
		if event.is_action_released("interact"):
			if asleep:
				get_out_of_bed()
			elif colliding_node:
				interact_with_collider()
			elif held_object:
				drop_held_object()
	if event.is_action_pressed("inventory") and (current_menu is InventoryUI or not current_menu):
		inventory_ui.open_close()


func interact_with_collider() -> void:
	if colliding_node.get_parent() is Door:
		colliding_node.get_parent().open_close()
	elif colliding_node.get_parent() is Stall:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		colliding_node.get_parent().open_shop()
	elif bed && colliding_node.get_parent() == bed:
		go_to_bed()
	elif colliding_node.get_parent() is StallItem:
		buy_item(colliding_node.get_parent())


func drop_held_object():
	if not held_object:
		return
	if has_node("HeldItemCollision"):
		get_node("HeldItemCollision").queue_free()
	
	var root = get_tree().current_scene
	var global_transform_to_keep = held_object.global_transform
	hold_marker.remove_child(held_object)
	root.add_child(held_object)
	held_object.global_transform = global_transform_to_keep
	
	held_object.collision_layer = 1
	held_object.collision_mask = 1
	
	var drop_distance = 0.5
	var forward_dir = -model.global_transform.basis.z.normalized()
	var carried_pos = held_object.global_transform.origin
	var drop_pos = carried_pos + Vector3(forward_dir.x, 0, forward_dir.z).normalized() * drop_distance
	drop_pos.y = global_transform.origin.y
	held_object.global_transform.origin = drop_pos
	
	#if held_object is RigidBody3D:
		#held_object.linear_velocity = forward_dir * 2
	
	held_object = null


func buy_item(stall_item: StallItem) -> void:
	if coins >= stall_item.item.item_cost and held_object == null:
		coins -= stall_item.item.item_cost
		var item_size: Enums.ItemSize = stall_item.item.item_size
		if item_size == Enums.ItemSize.SMALL:
			inventory.add_item(stall_item.item, 1)
			inventory_ui.redraw_inventory(inventory)
		elif item_size == Enums.ItemSize.LARGE:
			pickup_new_item(stall_item)


func pickup_new_item(item: StallItem) -> void:
	var new_planter: RigidBody3D = item.item_scene.instantiate()
	new_planter.collision_layer = 0
	new_planter.collision_mask = 0
	new_planter.freeze = true
	
	var planter_hold_point := new_planter.get_node("HoldPoint") as Marker3D
	var root_to_carry = planter_hold_point.global_transform.affine_inverse() * new_planter.global_transform
	
	hold_marker.add_child(new_planter)
	
	new_planter.global_transform = hold_marker.global_transform * planter_hold_point.transform.affine_inverse()
	
	var extra_shape = CollisionShape3D.new()
	extra_shape.shape = new_planter.get_node("CollisionShape3D").shape.duplicate()
	extra_shape.name = "HeldItemCollision"
	add_child(extra_shape)
	extra_shape.global_transform = new_planter.get_node("CollisionShape3D").global_transform
	
	held_object = new_planter


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
	if current_menu:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func on_menu_closed() -> void:
	current_menu.menu_closed.disconnect(on_menu_closed)
	current_menu = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if held_object:
		update_hold_marker_position()
	process_animations(delta)
	if not Game.paused:
		super._physics_process(delta)
		if not current_menu:
			detect_raycast()
			if not asleep:
				camera_controller.look_input(delta)


func update_hold_marker_position() -> void:
	var skeleton = model.get_node("Armature/Skeleton3D") as Skeleton3D
	var left_hand_bone_idx = skeleton.find_bone("Hand.L")
	var right_hand_bone_idx = skeleton.find_bone("Hand.R")
	var left_hand_pos = skeleton.get_bone_global_pose(left_hand_bone_idx).origin
	var right_hand_pos = skeleton.get_bone_global_pose(right_hand_bone_idx).origin
	var midpoint = (left_hand_pos + right_hand_pos) * 0.5
	hold_marker.transform.origin = midpoint



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
	elif is_on_floor() and get_move_input().length() != 0:
		var anim = "Walk_Holding" if held_object else "Walk"
		if model_anim.current_animation != anim:
			model_anim.play(anim)
		if animation_player.current_animation != "Walking":
			animation_player.play("Walking")
	else:
		var anim = "Idle_Holding" if held_object else "Idle"
		if model_anim.current_animation != anim:
			model_anim.play(anim)
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
	
	rotate_model(delta)


func rotate_model(delta: float):
	var is_moving = move_dir.length() > 0
	
	if is_moving:
		if camera_controller.active_rig is ThirdPersonCameraRig:
			var target_transform = Transform3D().looking_at(move_dir, Vector3.UP)
			var current_basis = model.global_transform.basis

			# Smoothly interpolate basis (rotation) towards target
			model.global_transform.basis = current_basis.slerp(target_transform.basis, 10.0 * delta)
		else:
			model.rotation.y = lerp(model.rotation.y, 0.0, 10.0 * delta)


func get_move_input() -> Vector2:
	if current_menu or Game.paused or asleep:
		return Vector2()
	return super.get_move_input()


func jump_input() -> void:
	if Input.is_action_pressed("jump") and is_on_floor() and not held_object:
		jumping = true
		velocity.y = jump_force


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Jump":
		jumping = false


func set_shop_ui(stall: StallWithItems) -> void:
	current_stall = stall
	if current_stall:
		coins_adjusted.connect(stall.on_player_coins_adjusted)
