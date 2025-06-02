class_name ThirdPersonCameraRig
extends CameraRig


func camera_look(camera_look_input: Vector2, look_sensitivity: float, camera_distance: float):
	super.camera_look(camera_look_input, look_sensitivity, camera_distance)
	var pivot_position = global_transform.origin
	var desired_camera_position = pivot_position - global_transform.basis.z * camera_distance

	# Cast a ray from pivot to desired camera position
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pivot_position, desired_camera_position, camera_collision_mask)
	var result = space_state.intersect_ray(query)

	if result:
		# Move camera to collision point slightly closer
		camera.global_transform.origin = pivot_position.lerp(result.position, 0.9)
	else:
		# No collision; use full distance
		camera.global_transform.origin = desired_camera_position
