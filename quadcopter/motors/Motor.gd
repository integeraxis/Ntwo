class_name Motor
extends Node3D

@export var prop: Propeller

#the direction the motor turns in
@export var direction:int
@export var on:bool = true

@onready var radius = $MeshInstance3D.mesh.top_radius

const mass = 0.3 #in kg

#the speed that gets sent to the motors [0-1]
var pwm = 0.0


const RHO = 1.225 # kg/m³ (air density)
const CT = 0.18 #thrust
const CQ = 0.4 #torque

const MAX_RPM = 41040.0 #6s, 1800kv motors (1800*(3.8*6) = 41040)
#aka the angular velocity at max PWM duty cycle 
const MAX_angular_velocity = MAX_RPM * TAU / 60.0  # rad/s

# Precompute static multipliers
const THRUST_CONST = CT * gb.air_density * pow(prop.diameter, 4)
const TORQUE_CONST = CQ * gb.air_density * pow(prop.diameter, 5)

#(kinda accurate terminal velocity:)
#const TORQUE_DRAG_CONST := 1e-8
#const PROP_DRAG_CONST := 2e-9

const TORQUE_DRAG_CONST := 1e-8
const PROP_DRAG_CONST := 1e-9

var angular_velocity = 0
var up = Vector3.ZERO

func compute_thrust():
	if not on: return 0.0
	var n = angular_velocity / TAU
	return THRUST_CONST * n * n
	
func compute_ground_effect():
	return prop.ground_effect()

func compute_torque():
	if not on: return 0.0
	var n = angular_velocity / TAU
	return TORQUE_CONST * n * n * direction

func compute_drag_torque():
	if not on: return 0.0
	#var n = angular_velocity / TAU
	#return -DRAG_CONST * n * n * sign(angular_velocity)
	return signed_pow(angular_velocity, 2.0) * direction * TORQUE_DRAG_CONST * 1
	
func compute_prop_drag():
	if not on: return 0.0
	return abs(pow(angular_velocity, 2.0)) * PROP_DRAG_CONST

func _process(delta):
	angular_velocity = pwm*MAX_angular_velocity
	angular_velocity *= int(on)
	up = global_basis.y
	prop.angular_velocity = angular_velocity
	#print(angular_velocity)

#this is just pow but the original sign gets preserved
func signed_pow(base, expo):
	return sign(base)*abs(pow(base, expo))
