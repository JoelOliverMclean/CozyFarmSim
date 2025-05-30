class_name Player
extends FirstPersonController


var colliding_node: Node3D
var paused: bool
var current_menu: Menu


@onready var raycast: RayCast3D = $ViewRig/RayCast3D


func _input(event: InputEvent) -> void:
	if not current_menu:
		if event.is_action_pressed("interact") && colliding_node:
			interact()


func interact() -> void:
	if colliding_node.get_parent() is Door:
		colliding_node.get_parent().open_close()
	if colliding_node.get_parent() is Stall:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		colliding_node.get_parent().open_shop()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			paused = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			paused = false
			if current_menu:
				current_menu.open_close()


func menu_opened(menu: Menu) -> void:
	current_menu = menu
	current_menu.menu_closed.connect(on_menu_closed)


func on_menu_closed() -> void:
	current_menu.menu_closed.disconnect(on_menu_closed)
	current_menu = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not current_menu && not paused:
		super._physics_process(delta)
		process_animations()
		detect_raycast()


func detect_raycast() -> void:
	if raycast.is_colliding():
		if colliding_node && colliding_node != raycast.get_collider():
			hover_node(colliding_node, false)
		colliding_node = raycast.get_collider()
		hover_node(colliding_node, true)
	else:
		if colliding_node:
			hover_node(colliding_node, false)
			colliding_node = null


func hover_node(node: Node3D, hover: bool) -> void:
	if node is Interactable:
		node.focus(hover)


func process_animations() -> void:
	if move_input.length() != 0 and animation_player.current_animation != "Walking":
		animation_player.play("Walking")
	elif move_input.length() == 0 and animation_player.current_animation != "Idle":
		animation_player.play("Idle")


func handle_mouse_look(event: InputEventMouseMotion) -> void:
	if not current_menu && not paused:
		super.handle_mouse_look(event)
