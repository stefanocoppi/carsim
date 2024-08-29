class_name Drivetrain


const SHIFT_TIME = 500   # durata del cambio marcia in ms
const TIME_TO_DECLUTCH = 200  # tempo per staccare la frizione

enum DIFF_STATE {
	LOCKED,
	SLIPPING,
}


var gear_ratios = [ 3.08, 2.455, 1.66, 1.175, 1.0 ]
var final_drive = 3.0 #3.7
var reverse_ratio = 3.2
var power_ratio = 2.0
var coast_ratio = 1.0
var diff_preload = 50.0
var diff_split    = 0.5
var drive_inertia = 10.0
var engine_inertia = 0.0
var gear_inertia = 0.2
var selected_gear = 0  # marcia correntemente selezionata
var future_gear = 0    # marcia da innestare
var avg_rear_spin = 0.0
var gearbox_shaft_speed = 0.0
var reaction_torque = 0.0
var drive_torque = 0.0
var car:Car = null
var shift_start_time = 0
var t1 = 0.0  # coppia inviata al semiasse
var t2 = 0.0
var torque_in_diff = 0.0
var diff_clutch:Clutch = null


func _init(p_car):
	car = p_car
	diff_clutch = Clutch.new()


func shift_up():
	if (shift_start_time == 0)  and (selected_gear< gear_ratios.size()):
		shift_start_time = Time.get_ticks_msec()
		future_gear += 1
		car.clutch_input = 1.0


func shift_down():
	if (shift_start_time == 0) and (selected_gear > -1):
		shift_start_time = Time.get_ticks_msec()
		future_gear -= 1
		car.clutch_input = 1.0


func gearbox_loop():
	var t = Time.get_ticks_msec()
	Utils.log("gearbox_loop()")
	if (t - shift_start_time) >= TIME_TO_DECLUTCH:
		selected_gear = future_gear
	
	if (t - shift_start_time) >= SHIFT_TIME:
		car.clutch_input = 0.0
		shift_start_time = 0
	
	if (shift_start_time > 0) and (t - shift_start_time) < SHIFT_TIME:
		car.engine.throttle = 0.0


func get_gear_ratio() -> float:
	if selected_gear > 0:
		return gear_ratios[selected_gear - 1] * final_drive
	# retromarcia
	if selected_gear == -1:
		return - reverse_ratio * final_drive
	return 0.0


func differential(torque,brake_torque,wheels:Array[Wheel],delta):
	
	Utils.log("******************** differential start ************************* ")
	
	var diff_state = DIFF_STATE.LOCKED
	
	var tr1 = abs(wheels[0].get_reaction_torque())
	var tr2 = abs(wheels[1].get_reaction_torque())
	Utils.log("torque=%s, brake_torque=%s" % [torque,brake_torque])
	Utils.log("tr1=%s, tr2=%s" % [tr1,tr2])
	
	var bias = 0.0
	
	if tr1 >= tr2:
		bias = tr1 / tr2
	else:
		bias = tr2 / tr1
	
	var delta_torque = tr1 - tr2
	
	Utils.log("bias=%s, delta_torque=%s" % [bias,delta_torque])
	
	#print("torque= %s" % torque)
	torque_in_diff = torque
	t1 = torque * 0.5
	t2 = torque * 0.5
	
	Utils.log("t1=%s, t2=%s" % [t1,t2])
	
	var ratio = power_ratio
	if torque * sign(get_gear_ratio()) < 0:
		ratio = coast_ratio
	
	Utils.log("ratio=%s" % ratio)
	
	if abs(delta_torque) > diff_preload and bias >= ratio:
		diff_state = DIFF_STATE.SLIPPING
	
	Utils.log("diff_state=%s" % diff_state)
	
	match diff_state:
		DIFF_STATE.SLIPPING:
			diff_clutch.friction = diff_preload
			var diff_torques = diff_clutch.get_reaction_torques(wheels[0].spin,wheels[1].spin,
				tr1,tr2,diff_preload * ratio, 0.0)
			Utils.log("diff_torques=%s" % diff_torques)
			t1 += diff_torques.x
			t2 += diff_torques.y
			Utils.log("t1=%s, t2=%s" % [t1,t2])
			wheels[0].apply_torque(t1, brake_torque * 0.5,drive_inertia, delta)
			wheels[1].apply_torque(t2, brake_torque * 0.5,drive_inertia, delta)
		
		DIFF_STATE.LOCKED:
			var net_torque = wheels[0].get_reaction_torque() + wheels[1].get_reaction_torque()
			net_torque += t1 + t2
			
			Utils.log("net_torque=%s" % net_torque)
			
			var spin = 0.0
			var avg_spin = (wheels[0].spin + wheels[1].spin) * 0.5
			var rolling_resistance = wheels[0].rolling_resistance + wheels[1].rolling_resistance
			
			Utils.log("avg_spin=%s, rolling_resistance=%s" % [avg_spin,rolling_resistance])
			
			if abs(avg_spin) < 5.0 and brake_torque > abs(net_torque):
				spin = 0.0
			else:
				net_torque -= (brake_torque + rolling_resistance) * sign(avg_spin)
			
			spin = avg_spin + delta * net_torque / (wheels[0].wheel_inertia + drive_inertia + wheels[1].wheel_inertia)
			
			Utils.log("net_torque=%s, spin=%s" % [net_torque,spin])
			
			wheels[0].spin = spin
			wheels[1].spin = spin
	

	Utils.log("******************** differential end ************************* ")
	

func apply_torque_to_wheel(torque, front_brake_torque, rear_brake_torque, wheels:Array[Wheel], delta):
	var front_wheels = [wheels[2], wheels[3]]

	drive_inertia = (engine_inertia + pow(abs(get_gear_ratio()), 2) * gear_inertia)
	drive_torque = torque * get_gear_ratio()
	
	#print("drive_torque=%s" % drive_torque)
	
	# trazione posteriore
	differential(drive_torque,rear_brake_torque,wheels,delta)
	front_wheels[0].apply_torque(0.0, front_brake_torque * 0.5, drive_inertia,delta)
	front_wheels[1].apply_torque(0.0, front_brake_torque * 0.5, drive_inertia,delta)
	reaction_torque = (wheels[0].get_reaction_torque() + wheels[1].get_reaction_torque()) * 0.5
	reaction_torque *= (1.0 / get_gear_ratio())
