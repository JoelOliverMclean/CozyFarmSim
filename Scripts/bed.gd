class_name Bed
extends Node3D


@export var player: Player

@onready var bed_cam := $Camera3D
@onready var interact_label: Label3D = get_node("InteractLabel")

var waking_up: bool
var wake_duration = 1.0
var is_lerping = false
var lerp_time = 0.0
var start_transform: Transform3D
var target_transform: Transform3D
var camera_reset: bool = true


func _on_look_at_detect_focus_gained() -> void:
	interact_label.visible = true


func _on_look_at_detect_focus_lost() -> void:
	interact_label.visible = false


func go_to_bed(player: Player):
	target_transform = player.camera_controller.first_person_cam_rig.camera.global_transform
	$Camera3D.current = true


func wake_player():
	if $AnimationPlayer.current_animation != "Waking":
		$AnimationPlayer.play("Waking")
		print("Waking playing")


func can_get_out() -> bool:
	return $AnimationPlayer.current_animation != "Waking" and not waking_up


func _process(delta: float) -> void:
	lerp_time += delta
	var t = lerp_time / wake_duration
	if waking_up:
		if t >= 1.0:
			t = 1.0
			waking_up = false
			bed_cam.current = false
			player.awoken()
			lerp_time = 0.0
			
		var eased_t = smoothstep(0.0, 1.0, t)
		
		bed_cam.global_transform.origin = start_transform.origin.lerp(target_transform.origin, eased_t)
		bed_cam.global_transform.basis = start_transform.basis.slerp(target_transform.basis, eased_t)
	elif !player.asleep and $AnimationPlayer.current_animation != "Idle":
		$AnimationPlayer.play("Idle")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Waking":
		waking_up = true
		lerp_time = 0.0
		start_transform = bed_cam.global_transform
