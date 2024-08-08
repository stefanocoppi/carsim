extends Panel


@onready var car = get_node("../../RigidBody3D")
@onready var tire_fr = $TireFR/Text
@onready var tire_fl = $TireFL/Text
@onready var tire_rr = $TireRR/Text
@onready var tire_rl = $TireRL/Text
@onready var console = $Text


func _ready():
	pass
	



func _process(delta):
	# stampa lo slip vector
	#tire_fr.text = "local_vel = %s" % car.wheel_fr.local_vel
	tire_fr.text = "slip_vec = %s" % car.wheel_fr.slip_vec
	tire_fr.text += "\nspin = %s" % car.wheel_fr.spin
	#tire_fr.text += "\nplanar_vect = %s" % car.wheel_fr.planar_vect
	tire_fr.text += "\nforce_vec = %s" % car.wheel_fr.force_vec
	tire_fr.text += "\nsteering_input = %s" % car.steering_input
	tire_fr.text += "\nsteering_amount = %s" % car.steering_amount
	tire_fr.text += "\nrotation.y = %s" % car.wheel_fr.rotation.y
	tire_fl.text = "slip_vec = %s" % car.wheel_fl.slip_vec
	tire_fl.text += "\nspin = %s" % car.wheel_fl.spin
	tire_fl.text += "\nforce_vec = %s" % car.wheel_fl.force_vec
	tire_fl.text += "\nrotation.y = %s" % car.wheel_fl.rotation.y
	tire_rr.text = "slip_vec = %s" % car.wheel_rr.slip_vec
	#tire_rr.text += "\nplanar_vect = %s" % car.wheel_rr.planar_vect
	tire_rr.text += "\nspin = %s" % car.wheel_rr.spin
	tire_rr.text += "\nforce_vec = %s" % car.wheel_rr.force_vec
	tire_rl.text = "slip_vec = %s" % car.wheel_rl.slip_vec
	tire_rl.text += "\nspin = %s" % car.wheel_rl.spin
	tire_rl.text += "\nforce_vec = %s" % car.wheel_rl.force_vec
	
	console.text = "Engine rpm= %s    speed= %s" % [car.engine.rpm,car.speedometer]
	console.text += "\nthrottle= %s" % car.engine.throttle
	console.text += "\ntorque_out= %s" % car.engine.torque_out
	
	
