class_name Door
extends StaticBody3D


var open: bool


@onready var look_at: Interactable = get_node("LookAtDetect")
@onready var interact_label: Label3D = get_node("InteractLabel")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")


func _on_look_at_detect_focus_gained() -> void:
	show_label(true)


func _on_look_at_detect_focus_lost() -> void:
	show_label(false)


func show_label(show: bool) -> void:
	interact_label.visible = show


func open_close() -> void:
	if open:
		animation_player.play("Closing")
	else:
		animation_player.play("Opening")
	open = !open
	interact_label.text = "[E] Open" if open else "[E] Close"
