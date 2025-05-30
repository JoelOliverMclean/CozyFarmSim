@tool
class_name DayNightCycle
extends Node3D

@export var play_in_editor: bool = false

@export_range(0.0, 24.0, 0.01)
var time_of_day: float = 6.0:
	set(value):
		time_of_day = value
		if Engine.is_editor_hint():
			if sun_light:
				update_sun()
				sun_light.notify_property_list_changed()

@export var sunrise_time: float = 6.0    # 6 AM
@export var sunset_time: float = 20.0    # 8 PM
@export var day_length_minutes: float = 2.0

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


func _ready() -> void:
	play_in_editor = true
	day_seconds = day_length_minutes * 60.0


func _process(delta):
	if play_in_editor:
		var minutes_per_second = 24.0 / (day_length_minutes * 60.0)
		time_of_day += minutes_per_second * delta
		if time_of_day >= 24.0:
			time_of_day -= 24.0

		update_sun()


func format_time_of_day() -> String:
	var total_minutes = int(time_of_day * 60)
	var hours = total_minutes / 60
	var minutes = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]


func update_sun():
	var light_energy
	
	if time_of_day < sunrise_time or time_of_day >= sunset_time:
		light_energy = lerp(env.environment.ambient_light_sky_contribution, 0.1, 0.02)
	else:
		light_energy = lerp(env.environment.ambient_light_sky_contribution, 1.0, 0.02)
		
	env.environment.ambient_light_sky_contribution = light_energy
	(env.environment.sky.sky_material as ProceduralSkyMaterial).sky_energy_multiplier = light_energy
	(env.environment.sky.sky_material as ProceduralSkyMaterial).ground_energy_multiplier = light_energy
	sun_light.light_energy = light_energy
	
	var sun_angle = get_sun_angle(time_of_day)
	sun_light.rotation_degrees = Vector3(sun_angle - 180.0, 0, 0) # offset: 90° = noon straight overhead


func get_sun_angle(time_of_day: float) -> float:
	var day_duration = sunset_time - sunrise_time
	var night_duration = 24.0 - day_duration
	
	if time_of_day >= sunrise_time and time_of_day < sunset_time:
		# DAYTIME: map [sunrise, sunset] → [0°, 180°]
		var t = (time_of_day - sunrise_time) / day_duration
		return lerp(0.0, 180.0, t)
	else:
		# NIGHTTIME: handle wraparound for [sunset → next sunrise]
		var night_start = sunset_time
		var night_end = sunrise_time + 24.0 if sunrise_time < sunset_time else sunrise_time

		var adjusted_time = time_of_day
		if time_of_day < sunrise_time:
			adjusted_time += 24.0  # wrap around past midnight

		var t = (adjusted_time - night_start) / night_duration
		var angle = lerp(180.0, 360.0, t)
		return fmod(angle, 360.0)
