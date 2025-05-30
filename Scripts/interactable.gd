class_name Interactable
extends Area3D


var focused: bool

signal focus_gained
signal focus_lost


func focus(new_focused: bool) -> void:
	if focused != new_focused:
		if new_focused:
			focus_gained.emit() 
		else:
			focus_lost.emit()
	focused = new_focused
