class_name Car
extends RigidBody3D


const MS_TO_KMH = 3.6


@onready var wheel_fr = $WheelFR as Wheel
@onready var wheel_fl = $WheelFL as Wheel
@onready var wheel_rr = $WheelRR as Wheel
@onready var wheel_rl = $WheelRL as Wheel

var engine:Engine_t

var max_steer = 0.3
var steer_speed = 5.0

var throttle_input: float = 0.0
var brake_input = 0.0
var steering_input = 0.0
var steering_amount = 0.0
var torque_out = 0.0

var avg_front_spin = 0.0
var rear_brake_torque = 0.0
var front_brake_torque = 0.0
var speedometer = 0.0    # Km/h


func _ready():
	engine = Engine_t.new()
	engine.start()



func _process(delta):
	pass
	#print("throttle_input=%s" % throttle_input)


func get_engine_torque(_throttle_input) -> float:
	
	return 200 * _throttle_input
	

func _physics_process(delta):
	
	throttle_input = Input.get_action_strength("Throttle")
	brake_input = Input.get_action_strength("Brake")
	steering_input = Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight")
		
	# sterzatura delle ruote
	if (steering_input < steering_amount):
		steering_amount -= steer_speed * delta
		if (steering_input > steering_amount):
			steering_amount = steering_input
	elif (steering_input > steering_amount):
		steering_amount += steer_speed * delta
		if (steering_input < steering_amount):
			steering_amount = steering_input
	
	wheel_fl.steer(steering_amount,max_steer)
	wheel_fr.steer(steering_amount,max_steer)
	
	torque_out = get_engine_torque(throttle_input)
	engine.throttle = throttle_input
	engine.loop(delta)
	
	freewheel(delta)
	
	wheel_fr.apply_forces(delta)
	wheel_fl.apply_forces(delta)
	wheel_rr.apply_forces(delta)
	wheel_rl.apply_forces(delta)
	
	#var drive_torque = -torque_out
	#var brake_torque = 100.0 * brake_input
	#wheel_fl.apply_torque(0.0,brake_torque,delta)
	#wheel_fr.apply_torque(0.0,brake_torque,delta)
	#wheel_rl.apply_torque(drive_torque,brake_torque,delta)
	#wheel_rr.apply_torque(drive_torque,brake_torque,delta)


func freewheel(delta):
	avg_front_spin = 0.0
	# applica la coppia frenante
	wheel_fl.apply_torque(0.0,front_brake_torque,delta)
	wheel_fr.apply_torque(0.0,front_brake_torque,delta)
	wheel_rl.apply_torque(0.0,rear_brake_torque,delta)
	wheel_rr.apply_torque(0.0,rear_brake_torque,delta)
	# calcola la velocità mostrata nel tachimetro
	avg_front_spin += (wheel_fl.spin + wheel_fr.spin) * 0.5
	speedometer = avg_front_spin * wheel_fl.tire_radius * MS_TO_KMH


func engage(torque,delta):
	avg_front_spin = 0.0
	var gearing = 1.0
	var drive_torque = torque * gearing
	avg_front_spin += (wheel_fl.spin + wheel_fr.spin) * 0.5
	
	# differenziale
	
	speedometer = avg_front_spin * wheel_fl.tire_radius * MS_TO_KMH
	
	# applica la coppia frenante
	wheel_fl.apply_torque(0.0,front_brake_torque,delta)
	wheel_fr.apply_torque(0.0,front_brake_torque,delta)
	
	
