class_name Quadcopter
extends RigidBody3D

@export var motor1: Motor
@export var motor2: Motor
@export var motor3: Motor
@export var motor4: Motor

@onready var motors = [motor1, motor2, motor3, motor4]


#drag in the (local) x, y, z directions
#if for example the y drag is high (top-bottom):
	#if the top/bottom is facing the same direction
	#as the direction that the quad is moving in, the drone will slow down
@export var XYZ_projected_areas = Vector3(0.02, 0.03, 0.02)

#kinda accurate terminal velocity:
#@export var drag_coeff = 0.2

@export var drag_coeff = 0.25

var imu_pitch_speed = 0
var imu_roll_speed = 0
var imu_yaw_speed = 0

var imu_pitch = 0
var imu_roll = 0
var imu_yaw = 0



func _process(delta):
	imu_pitch = rotation.x
	imu_roll = rotation.z
	imu_yaw = rotation.y
	
	var local_angular_velocity = angular_velocity * basis
	
	imu_pitch_speed = local_angular_velocity.x
	imu_roll_speed = local_angular_velocity.z
	imu_yaw_speed = local_angular_velocity.y
	
	#these are all for the HUD
	gb.velocity = linear_velocity.length()
	gb.imu_rotations[0] = imu_pitch
	gb.imu_rotations[1] = imu_roll
	gb.imu_rotations[2] = imu_yaw
	
	gb.imu_rotation_speeds[0] = imu_pitch_speed
	gb.imu_rotation_speeds[1] = imu_roll_speed
	gb.imu_rotation_speeds[2] = imu_yaw_speed
	
	$FPVCam.fov = remap(SimulatorSettings.get_property("fisheye_strength"), 0, 1, 90, 150)
	$FloorCast.global_position = global_position
	

	
func _physics_process(delta):
	if Input.is_action_just_pressed("self_right"):
		if $FloorCast.is_colliding() and ($FloorCast.get_collision_normal() != Vector3.ZERO):
			var floor_normal = $FloorCast.get_collision_normal()
			basis.y = floor_normal
			basis.x = -basis.z.cross(floor_normal)
			basis.z = -basis.y.cross(basis.x)
			basis = basis.orthonormalized()
			
		else:
			global_rotation.x = 0
			global_rotation.z = 0
	
	var total_thrust = 0
	var total_angular_velocity = 0
	#set forces per motor
	var prop_drag = 0
	
	for motor in motors:
		var thrust = motor.compute_thrust()
		var ground_effect = motor.compute_ground_effect()
		total_thrust += thrust
		total_angular_velocity += motor.angular_velocity
		#print("thrust ",thrust)
		var torque = motor.compute_torque()
		var drag_torque = motor.compute_drag_torque()
		prop_drag += motor.compute_prop_drag()
		
		apply_force(motor.up * thrust * ground_effect, global_transform.basis * motor.position)
		apply_torque(motor.up * torque)
		apply_torque(motor.up * drag_torque)
		
		
	gb.total_thrust = total_thrust
	
	var angular_velocity01 = total_angular_velocity/15000.0
	$AudioMotors.volume_linear = angular_velocity01
	$AudioMotors.pitch_scale = 0.3+angular_velocity01*2.0
	
	
	$AudioWind.volume_linear = linear_velocity.length_squared()/20000.0
	$AudioWind.pitch_scale = 1.0 + linear_velocity.length_squared()/300.0
	

	var drag_mult =  drag_coeff * (0.5 + 0.5 / (1.0 + linear_velocity.length() * 0.1))
	
	var vel_norm = linear_velocity.normalized()
	var drag_directions = Vector3(0, 0, 0)
	
	drag_directions.x = pow(global_basis.x.dot(vel_norm), 2)*XYZ_projected_areas.x * drag_mult
	drag_directions.y = pow(global_basis.y.dot(vel_norm), 2)*XYZ_projected_areas.y * drag_mult
	drag_directions.z = pow(global_basis.z.dot(vel_norm), 2)*XYZ_projected_areas.z * drag_mult
	
	var drag = drag_directions.x + drag_directions.y + drag_directions.z
	var drag_force = (vel_norm * linear_velocity.length_squared()) * (drag+prop_drag)
	
	gb.drag_force = drag_force.length()
	apply_central_force(-drag_force)
