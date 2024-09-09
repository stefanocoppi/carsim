class_name Brake

# parametri fisici
var brake_pad_mu = 0.0 #0.4
var effective_radius = 0.0 # 0.25
var max_brake_force = 0.0 #50000 #100000
var front_brake_bias = 0.0 #0.6


func init_params(json_data):
	brake_pad_mu = json_data["brake_pad_mu"]
	effective_radius = json_data["effective_radius"]
	max_brake_force = json_data["max_brake_force"]
	front_brake_bias = json_data["front_brake_bias"]


# ritorna le coppie frenanti anteriore e posteriore
func get_brake_torques(brake_input,delta) -> Vector2:
	var torques = Vector2.ZERO
	
	var clamping_foce = brake_input * max_brake_force * 0.5
	
	var braking_force = 2.0 * brake_pad_mu * clamping_foce
	
	torques.x = braking_force * effective_radius * front_brake_bias
	torques.y = braking_force * effective_radius * (1 - front_brake_bias)
	
	#print("torques= %s" % torques)
	
	return torques
