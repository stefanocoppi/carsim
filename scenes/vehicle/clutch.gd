class_name Clutch


# parametri fisici
var friction = 0.0 #320.0    # valore massimo di coppia trasmissibile dalla frizione

# stato
var locked = false       # indica se la frizione è solidale con il motore (true)


func init_params(json_data):
	friction = json_data["friction"]


# calcola le coppie di reazione della frizione
# av1, av2: velocità angolare di motore e cambio
# t1, t2: coppia di motore e cambio
# slip_torque: valore massimo di coppia di slittamento consentito
# kick: aumento di coppia dovuto allo slittamento iniziale
#
# ritorna un Vector2 con:
# x: coppia di reazione sul cambio
# y: coppia di reazione sul motore
func get_reaction_torques(av1:float, av2:float, t1:float, t2:float, slip_torque:float, kick:float) -> Vector2:
	var reaction_torques = Vector2.ZERO
	var clutch_torque = friction + kick
	Utils.log("clutch_torque= %s, locked= %s" % [clutch_torque,locked])
	var delta_torque = t1 - t2
	var delta_av = av1 - av2
	Utils.log("delta_torque= %s, delta_av=%s" % [delta_torque,delta_av])
	
	if locked:
		# se la differenza di coppia tra motore e cambio è superiore al valore massimo di slittamento consentito,
		# riapre la frizione
		if absf(delta_torque) >= slip_torque:
			locked = false
	else:
		# se la differenza di velocità angolare tra motore e cambio è quasi zero, considera la frizione locked
		if absf(delta_av) < 0.5:
			locked = true 
	
	if av1 < av2:
		# se la velocità del motore è inferiore a quella del cambio
		reaction_torques.x = -clutch_torque
		reaction_torques.y = clutch_torque
	else:
		reaction_torques.x = clutch_torque
		reaction_torques.y = -clutch_torque
	
	Utils.log("reaction_torques= %s" % reaction_torques)
	
	return reaction_torques
