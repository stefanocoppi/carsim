class_name Engine_t


const AV_2_RPM: float = 60 / TAU


# parametri
var max_rpm = 0 #8000.0
var rpm_idle = 0 #900
var max_torque = 0.0 #260.0    # Nm
var engine_brake = 0.0 #150.0   # Nm
var engine_drag = 0.0 #0.03    # Nm/rpm
var inertia_moment = 0.0 #0.14
var torque_curve:Curve

# variabili

# riferimenti esterni
var car:Car = null

# INPUT
var throttle:float = 0.0

# STATO
var rpm:float = 0

# OUTPUT
var torque_out:float = 0.0
var engine_net_torque = 0.0



func _init(p_car):
	car = p_car
	torque_curve = preload("res://resources/torque_curve.tres")


func init_params(json_data):
	max_rpm = json_data["max_rpm"]
	rpm_idle = json_data["rpm_idle"]
	max_torque = json_data["max_torque"]
	engine_brake = json_data["engine_brake"]
	engine_drag = json_data["engine_drag"]
	inertia_moment = json_data["inertia_moment"]


# fornisce la coppia all'albero motore, in funzione di rpm e posizione
# dell'acceleratore (0.0-1.0)
func get_torque(p_rpm, p_throttle) -> float:
	
	# rpm normalizzati tra 0 e 1
	var rpm_normalized = clamp(p_rpm / max_rpm, 0.0, 1.0)
	# ottiene la coppia normalizzata dalla curva di coppia
	var norm_torque = torque_curve.sample_baked(rpm_normalized)
	# coppia resistente
	#var t0 = -(engine_brake + engine_drag * p_rpm)
	var t0 = - engine_brake * rpm_normalized
	
	# moltiplica la coppia normalizzata per quella massima
	var t1 = norm_torque * max_torque
		
	# coppia all'albero motore: interpolazione lineare tra t0, t1 in base alla posizione dell'acceleratore
	var torque_out = lerpf(t0, t1, p_throttle)
	
	#print("torque_out=%s" % torque_out)
	
	return torque_out


# ciclo di funzionamento del motore
# da richiamare in physics_process()
func loop(delta):

	torque_out = get_torque(rpm,throttle)
	engine_net_torque = torque_out + car.clutch_reaction_torque
	#engine_net_torque = torque_out
	var factor = (AV_2_RPM * delta * engine_net_torque / inertia_moment)
	#print("factor = %s" % factor)
	rpm += factor
	
	if rpm >= max_rpm:
		torque_out = 0.0
		rpm -= 500
	
	rpm = max(rpm,rpm_idle)
	
	#print("rpm=%s" % rpm)


# avvia il motore, impostando gli rpm al minimo
func start():
	rpm = rpm_idle


func stop():
	rpm = 0


func get_angular_vel() -> float:
	return rpm / AV_2_RPM
