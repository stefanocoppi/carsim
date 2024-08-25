class_name Brake

const BRAKE_PAD_MU = 0.4
const EFFECTIVE_RADIUS = 0.25

var max_brake_force = 50000 #100000
var front_brake_bias = 0.6

# ritorna le coppie frenanti anteriore e posteriore
func get_brake_torques(brake_input,delta) -> Vector2:
	var torques = Vector2.ZERO
	
	var clamping_foce = brake_input * max_brake_force * 0.5
	
	var braking_force = 2.0 * BRAKE_PAD_MU * clamping_foce
	
	torques.x = braking_force * EFFECTIVE_RADIUS * front_brake_bias
	torques.y = braking_force * EFFECTIVE_RADIUS * (1 - front_brake_bias)
	
	#print("torques= %s" % torques)
	
	return torques
