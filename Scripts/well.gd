class_name Well
extends StaticBody3D


@onready var interact_label: Label3D = get_node("InteractLabel")


func _on_look_at_detect_focus_gained() -> void:
	interact_label.visible = true

func _on_look_at_detect_focus_lost() -> void:
	interact_label.visible = false
