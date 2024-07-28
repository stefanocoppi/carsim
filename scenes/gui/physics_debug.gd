extends Panel


@onready var car = get_node("../../RigidBody3D")
@onready var tire_fr = $TireFR/Text
@onready var tire_fl = $TireFL/Text
@onready var tire_rr = $TireRR/Text
@onready var tire_rl = $TireRL/Text


func _ready():
	pass # Replace with function body.
	print(car)



func _process(delta):
	# stampa lo slip vector
	tire_fr.text = "slip_vec = %s" % car.wheel_fr.slip_vec
	tire_fl.text = "slip_vec = %s" % car.wheel_fl.slip_vec
	tire_rr.text = "slip_vec = %s" % car.wheel_rr.slip_vec
	tire_rl.text = "slip_vec = %s" % car.wheel_rl.slip_vec
	
