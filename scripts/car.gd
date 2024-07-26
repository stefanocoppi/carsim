class_name Car
extends RigidBody3D


@onready var wheel_fr = $WheelFR as Wheel
@onready var wheel_fl = $WheelFL as Wheel
@onready var wheel_rr = $WheelRR as Wheel
@onready var wheel_rl = $WheelRL as Wheel

var throttle_input: float = 0.0


func _ready():
	pass # Replace with function body.



func _process(delta):
	pass
	print("throttle_input=%s" % throttle_input)


func _physics_process(delta):
	
	throttle_input = Input.get_action_strength("Throttle")
	
	
	wheel_fr.apply_forces(delta)
	wheel_fl.apply_forces(delta)
	wheel_rr.apply_forces(delta)
	wheel_rl.apply_forces(delta)
	
	var drive_torque = 10.0
	wheel_rl.apply_torque(drive_torque,0.0,delta)
	wheel_rr.apply_torque(drive_torque,0.0,delta)
