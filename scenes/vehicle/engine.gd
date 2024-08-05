class_name Engine_t

# parametri
const MAX_RPM = 6000.0
const MAX_TORQUE = 200.0    # Nm
const ENGINE_BRAKE = 10.0   # Nm
const ENGINE_DRAG = 0.03    # Nm/rpm
const AV_2_RPM: float = 60 / TAU
const ENGINE_INERTIA_MOMENT: float = 0.25
const RPM_IDLE = 900
var torque_curve:Curve

# variabili

# INPUT
var throttle:float = 0.0

# STATO
var rpm:float = 0

# OUTPUT
var torque_out:float = 0.0



func _init():
	torque_curve = preload("res://resources/torque_curve.tres")
	pass


# fornisce la coppia all'albero motore, in funzione di rpm e posizione
# dell'acceleratore (0.0-1.0)
func get_torque(p_rpm, p_throttle) -> float:
		
	# rpm normalizzati tra 0 e 1
	var rpm_normalized = clamp(p_rpm / MAX_RPM, 0.0, 1.0)
	# ottiene la coppia normalizzata dalla curva di coppia
	var norm_torque = torque_curve.sample_baked(rpm_normalized)
	# coppia resistente
	var t0 = -(ENGINE_BRAKE + ENGINE_DRAG * p_rpm)
	# moltiplica la coppia normalizzata per quella massima
	var t1 = norm_torque * MAX_TORQUE
		
	# coppia all'albero motore: interpolazione lineare tra t0, t1 in base alla posizione dell'acceleratore
	var torque_out = lerpf(t0, t1, p_throttle)
	
	return torque_out


# ciclo di funzionamento del motore
# da richiamare in physics_process()
func loop(delta):

	torque_out = get_torque(rpm,throttle)
	var factor = (AV_2_RPM * delta * torque_out / ENGINE_INERTIA_MOMENT)
	#print("factor = %s" % factor)
	rpm += factor
	
	if rpm >= MAX_RPM:
		torque_out = 0.0
		rpm -= 500
	
	rpm = max(rpm,RPM_IDLE)


# avvia il motore, impostando gli rpm al minimo
func start():
	rpm = RPM_IDLE


func stop():
	rpm = 0
