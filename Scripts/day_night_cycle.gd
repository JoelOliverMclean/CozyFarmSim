@tool
class_name DayNightCycle
extends Node3D

@export var play_in_editor: bool = false
@export_range(-360, 360, 1)
var y_offset_angle: int = 15

var player_asleep: bool

@export_range(0.0, 24.0, 0.01)
var time_of_day: float = 6.0:
	set(value):
		time_of_day = value
		if sun_light and Engine.is_editor_hint():
			update_sun(1.0)
			update_light_energy(get_desired_light_energy_for_time())
			sun_light.notify_property_list_changed()

@export var sunrise_time: float = 6.0    # 6 AM
@export var sunset_time: float = 20.0    # 8 PM
@export var day_length_minutes: float = 10.0

@onready var sun_light: DirectionalLight3D = get_node("SunLight")
@onready var env: WorldEnvironment = get_node("WorldEnvironment")

# For lighting effects
@export var sunrise_color: Color = Color(1.0, 0.5, 0.3)
@export var noon_color: Color = Color(1.0, 1.0, 0.9)
@export var sunset_color: Color = Color(1.0, 0.4, 0.2)
@export var night_color: Color = Color(0.1, 0.1, 0.3)

var day_seconds: float
var rotation_axis := Vector3(1, 0, 0)  # Rotate around x-axis (like real sun)
var angle_offset = 45


func should_run() -> bool:
	return play_in_editor or not Engine.is_editor_hint()


func _ready() -> void:
	day_seconds = day_length_minutes * 60.0
	var light_energy = get_desired_light_energy_for_time()
	update_light_energy(light_energy)


func is_daytime() -> bool:
	return time_of_day >= sunrise_time and time_of_day < sunset_time


func _process(delta):
	if should_run():
		var minutes_per_second = 24.0 / ((day_length_minutes * get_fast_forward()) * 60.0)
		time_of_day += minutes_per_second * delta
		if time_of_day >= 24.0:
			time_of_day -= 24.0

		update_sun(delta)


func get_fast_forward() -> float:
	return 0.2 if player_asleep else 1.0


func format_time_of_day() -> String:
	var total_minutes = int(time_of_day * 60)
	var hours = (total_minutes as int) / 60
	var minutes = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]


func update_sun(delta: float):
	var light_energy = lerp(env.environment.ambient_light_sky_contribution, get_desired_light_energy_for_time(), 0.05 * delta)
	update_light_energy(light_energy)
	
	var sun_angle = get_sun_angle()
	sun_light.rotation_degrees = Vector3(sun_angle - 180.0, y_offset_angle, 0) # offset: 90° = noon straight overhead


func get_desired_light_energy_for_time() -> float:
	return 1.0 if is_daytime() else 0.1


func update_light_energy(light_energy: float):
	env.environment.ambient_light_sky_contribution = light_energy
	(env.environment.sky.sky_material as ProceduralSkyMaterial).sky_energy_multiplier = light_energy
	(env.environment.sky.sky_material as ProceduralSkyMaterial).ground_energy_multiplier = light_energy
	sun_light.light_energy = light_energy


func get_sun_angle() -> float:
	var day_duration = sunset_time - sunrise_time
	var night_duration = 24.0 - day_duration
	
	if is_daytime():
		# DAYTIME: map [sunrise, sunset] → [0°, 180°]
		var t = (time_of_day - sunrise_time) / day_duration
		return lerp(0.0, 180.0, t)
	else:
		# NIGHTTIME: handle wraparound for [sunset → next sunrise]
		var night_start = sunset_time

		var adjusted_time = time_of_day
		if time_of_day < sunrise_time:
			adjusted_time += 24.0  # wrap around past midnight

		var t = (adjusted_time - night_start) / night_duration
		var angle = lerp(180.0, 360.0, t)
		return fmod(angle, 360.0)
