class_name Menu
extends Panel


signal menu_closed


func open_close() -> void:
	visible = !visible
	if visible:
		notify_player()
	else:
		menu_closed.emit()


func notify_player() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player && player is Player:
		player.menu_opened(self)
