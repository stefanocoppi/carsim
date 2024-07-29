class_name Car
extends RigidBody3D


@onready var wheel_fr = $WheelFR as Wheel
@onready var wheel_fl = $WheelFL as Wheel
@onready var wheel_rr = $WheelRR as Wheel
@onready var wheel_rl = $WheelRL as Wheel

var throttle_input: float = 0.0
var brake_input = 0.0
var torque_out = 0.0


func _ready():
	pass # Replace with function body.



func _process(delta):
	pass
	#print("throttle_input=%s" % throttle_input)


func get_engine_torque(_throttle_input) -> float:
	
	return 100 * _throttle_input
	

func _physics_process(delta):
	
	throttle_input = Input.get_action_strength("Throttle")
	brake_input = Input.get_action_strength("Brake")
	
	torque_out = get_engine_torque(throttle_input)
	
	wheel_fr.apply_forces(delta)
	wheel_fl.apply_forces(delta)
	wheel_rr.apply_forces(delta)
	wheel_rl.apply_forces(delta)
	
	var drive_torque = torque_out
	var brake_torque = 100.0 * brake_input
	wheel_fl.apply_torque(0.0,brake_torque,delta)
	wheel_fr.apply_torque(0.0,brake_torque,delta)
	wheel_rl.apply_torque(drive_torque,brake_torque,delta)
	wheel_rr.apply_torque(drive_torque,brake_torque,delta)
