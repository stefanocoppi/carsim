class_name Clutch

# parametri
var clutch_linearity = 0.3
var clutch_max_torque = 825.0

var car:Car = null

# stato
var clutch_application = 0.0
var clutch_current_torque = 0.0
var directed_clutch_torque = 0.0
# true indica che il motore è collegato alla trasmissione
var prepost_locked = false 
var delta_vel = 0.0
var new_delta_vel = 0.0

# output
var output_torque = 0.0


func _init(p_car):
	car = p_car


# imposta l'applicazione della frizione
# app = 1 frizione staccata
# app = 0 frizione attaccata
func set_application(app):
	app = clampf(app,0.0,1.0)
	app = clutch_linearity * app + (1.0 - clutch_linearity) * (app*app*app)
	clutch_application = app
	clutch_current_torque = app * clutch_max_torque


func get_force() -> float:
	return directed_clutch_torque


func calc_forces():
	
	# con il cambio in folle, motore e cambio sono sempre disaccoppiati
	# non viene applicata la coppia della frizione
	if car.drivetrain.current_gear == 0:
		prepost_locked = false
		clutch_current_torque = 0.0
		#Utils.log("gearbox in neutral")
		#Utils.log("clutch_current_torque=%s  prepost_locked=%s" % [clutch_current_torque,prepost_locked])
	
	var engine_rotv = car.engine.get_rotv()
	var gearbox_rotv = car.drivetrain.gearbox_shaft_speed
	
	# calcola la coppia della frizione
	
	if not prepost_locked:
		# il motore è disconnesso dal cambio
		# la frizione lavora per rendere uguali le velocità
		# di rotazione del motore e del cambio
		if engine_rotv > gearbox_rotv:
			directed_clutch_torque = clutch_current_torque
		else:
			directed_clutch_torque = -clutch_current_torque
		if directed_clutch_torque > 0:
			Utils.log("engine_rotv=%s, gearbox_rotv=%s, directed_clutch_torque=%s" % [engine_rotv,gearbox_rotv,
				directed_clutch_torque])
		delta_vel = new_delta_vel
		new_delta_vel = engine_rotv - gearbox_rotv
		Utils.log("delta_vel=%s, new_delta_vel=%s" % [delta_vel,new_delta_vel])
		if (delta_vel>0 and new_delta_vel<0) or (delta_vel<0 and new_delta_vel>0):
			prepost_locked = true
			Utils.log("prepost_locked=%s" % prepost_locked)
		
	
	if prepost_locked:
		# poichè il motore è solidale con la trasmissione, la frizione trasmette
		# l'intera coppia del motore al cambio
		var te = car.engine.torque_out
		var r =  car.drivetrain.get_gear_ratio()
		output_torque = te * r
		Utils.log("il diff ottiene Te=%s * r=%s = %s Nm di coppia" % [te,r,te*r])
	else:
		# il motore è disconnesso dal cambio
		# la frizione lavora per rendere uguali le velocità
		# di rotazione del motore e del cambio
		var tc = get_force()
		var r = car.drivetrain.get_gear_ratio()
		output_torque = tc * r
		if output_torque > 0:
			Utils.log("il diff ottiene Tc=%s * r=%s = %s Nm di coppia" % [tc,r,tc*r])
		
