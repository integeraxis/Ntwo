extends Node

const air_density = 1.225 #in kg/m^3

var velocity := 0.0
var total_thrust := 0.0
var drag_force := 0.0

var imu_rotations := [0.0, 0.0, 0.0]
var imu_rotation_speeds := [0.0, 0.0, 0.0]

var settings_menu_ref = null
var gui_ref = null
var world_ref = null

func reset():
	get_tree().reload_current_scene()

func take_screenshot():
	# Wait for the frame to finish rendering to avoid incomplete captures
	await RenderingServer.frame_post_draw
	
	var timestamp = str(round(Time.get_unix_time_from_system()))
	var screenshot_path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+ "/Ntwo screenshot " + timestamp + ".png"
	
	var image = get_viewport().get_texture().get_image()
	image.save_png(screenshot_path)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		reset()
	if Input.is_action_just_pressed("screenshot"):
		take_screenshot()
		
func is_toggle_action(action:String, event_idx=0) -> bool:
	var ev = InputMap.action_get_events(action)[event_idx]
	if ev is InputEventKey or ev is InputEventJoypadButton: 
		return true
	if ev is InputEventJoypadMotion:
		return false
		
	return false
	

func rates_function(x, max_rate, center_rate, expo):
	#x is in the range [-1, 1]
	#you can see a desmos graph here:
	#https://www.desmos.com/calculator/5hlbr3utht
	var expo_factor = x*(pow(x, 5) * expo + x*(1.0-expo))
	#this is multiplied by sign(x) so it also works for x < 0
	return (center_rate*x)+((max_rate-center_rate)*expo_factor) * sign(x)

var throttle_expo = 1.5

func throttle_curve_function(x, expo):
	return pow(x, 1+expo)

#throttle
func raw_throttle():
	if InputSettings.get_property("throttle_0_at_center"):
		return Input.get_action_strength("throttle_up")
	else:
		return (Input.get_axis("throttle_down", "throttle_up") + 1)/2

func get_throttle_input():
	return throttle_curve_function(raw_throttle(), throttle_expo)
	
#pitch
func raw_pitch():
	return clamp(Input.get_axis("pitch_up", "pitch_down"), -1, 1)
	
func get_pitch_input():
	return rates_function(raw_pitch(), deg_to_rad(RatesSettings.get_property("pitch_max_rate")), deg_to_rad(RatesSettings.get_property("pitch_center_rate")), RatesSettings.get_property("pitch_expo"))
	
#roll
func raw_roll():
	return clamp(Input.get_axis("roll_left", "roll_right"), -1, 1)

func get_roll_input():
	return rates_function(raw_roll(), deg_to_rad(RatesSettings.get_property("roll_max_rate")), deg_to_rad(RatesSettings.get_property("roll_center_rate")), RatesSettings.get_property("roll_expo"))
	
#yaw
func raw_yaw():
	return clamp(Input.get_axis("yaw_left", "yaw_right"), -1, 1)

func get_yaw_input():
	return rates_function(raw_yaw(), deg_to_rad(RatesSettings.get_property("yaw_max_rate")), deg_to_rad(RatesSettings.get_property("yaw_center_rate")), RatesSettings.get_property("yaw_expo"))
