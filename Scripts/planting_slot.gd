class_name PlantingSlot
extends Area3D


@onready var indicator: Node3D = $Indicator


func hover(hovering: bool) -> void:
	indicator.visible = hovering
