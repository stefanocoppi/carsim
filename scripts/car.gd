class_name Car
extends RigidBody3D


@onready var wheel_fr = $WheelFR as RayCastSuspension
@onready var wheel_fl = $WheelFL as RayCastSuspension
@onready var wheel_rr = $WheelRR as RayCastSuspension
@onready var wheel_rl = $WheelRL as RayCastSuspension


func _ready():
	pass # Replace with function body.



func _process(delta):
	pass


func _physics_process(delta):
	
	wheel_fr.apply_forces(delta)
	wheel_fl.apply_forces(delta)
	wheel_rr.apply_forces(delta)
	wheel_rl.apply_forces(delta)
