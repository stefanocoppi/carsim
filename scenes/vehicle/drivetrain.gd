class_name Drivetrain


var time_to_clutch = 225      # tempo di riattacco della frizione in ms
var time_to_declutch = 125    # tempo di distacco della frizione in ms
var shift_start = 0           # timestamp in cui inizia la cambiata
var gear_ratios = [ 3.08, 2.455, 1.66, 1.175, 1.0 ]
var final_drive = 3.7
var reverse_ratio = 3.2
var diff_split    = 0.5
var drive_inertia = 10.0
var engine_inertia = 0.0
var gear_inertia = 0.2
var current_gear = 0  # marcia correntemente selezionata
var future_gear  = 0  # marcia che si vuole inserire
var avg_rear_spin = 0.0
var gearbox_shaft_speed = 0.0
var car:Car = null


func _init(p_car):
	car = p_car

func shift_up():
	if (shift_start == 0) and (current_gear < gear_ratios.size()):
		future_gear = current_gear + 1
		shift_start = Time.get_ticks_msec()
		Utils.log("inizio processo di cambiata")
		Utils.log("shift_up: current_gear=%s  future_gear=%s" % [current_gear,future_gear])
		#Utils.log("shift_start= %s" % shift_start)


func shift_down():
	if (shift_start == 0) and (current_gear > -1):
		future_gear = current_gear - 1
		shift_start = Time.get_ticks_msec()
		Utils.log("inizio processo di cambiata")
		Utils.log("shift_down: current_gear=%s  future_gear=%s" % [current_gear,future_gear])
		#Utils.log("shift_start= %s" % shift_start)


func get_gear_ratio() -> float:
	if current_gear > 0:
		return gear_ratios[current_gear - 1] * final_drive
	# retromarcia
	if current_gear == -1:
		return - reverse_ratio * final_drive
	return 0.0


func gearbox_physics_process(delta):
	
	avg_rear_spin = 0.0
	avg_rear_spin += (car.wheel_rl.spin + car.wheel_rr.spin) * 0.5
	gearbox_shaft_speed = avg_rear_spin * get_gear_ratio() 
	
	if shift_start > 0:
		var t = Time.get_ticks_msec() - shift_start
		if current_gear != future_gear:
			if t >= time_to_declutch:
				# distacco della frizione completato
				Utils.log("distacco frizione completato in %s ms." % t)
				Utils.log("app= 1.0")
				car.clutch.set_application(1.0)
				current_gear = future_gear
				Utils.log("innesto marcia: current_gear=%s  future_gear=%s" % [current_gear,future_gear])
			else:
				# distacco progressivo della frizione
				var app = float(t)/float(time_to_declutch)
				car.clutch.set_application(app)
				#Utils.log("distacco frizione app=%s" % app)
		else:
			# fase post-innesto marcia
			if t >= (time_to_declutch+time_to_clutch):
				# fine processo di cambiata
				shift_start = 0
				car.clutch.set_application(0.0)
				Utils.log("riattacco frizione completato in %s ms." % (t - time_to_declutch))
				Utils.log("app = 0.0")
				Utils.log("fine processo di cambiata, durata=%s ms" % t)
			else:
				# riattacca la frizione
				var app = float(time_to_clutch-(t-time_to_declutch))/float(time_to_clutch)
				#Utils.log("riattacco frizione app= %s" % app)
				car.clutch.set_application(app)



func differential(torque,brake_torque,wheels,delta):
	#print("torque= %s" % torque)
	var t1 = torque * 0.5
	var t2 = torque * 0.5
	#var diff_sum = 0.0
	#t2 *= diff_split
	#t1 *= (1 - diff_split)
	#print("diff torque=%s" % torque)
	#print("diff_split=%s" % diff_split)
	
	#diff_sum += wheels[0].apply_torque(t1, brake_torque * 0.5, delta)
	#diff_sum -= wheels[1].apply_torque(t2, brake_torque * 0.5, delta)
	wheels[0].apply_torque(t1, brake_torque * 0.5,drive_inertia, delta)
	wheels[1].apply_torque(t2, brake_torque * 0.5,drive_inertia, delta)
	#print("diff_sum=%s" % diff_sum)
	
	#diff_split = 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
	

func apply_torque_to_wheel(torque, front_brake_torque, rear_brake_torque, wheels, delta):
	var front_wheels = [wheels[2], wheels[3]]

	drive_inertia = (engine_inertia + pow(abs(get_gear_ratio()), 2) * gear_inertia)
	var drive_torque = torque
	
	#print("drive_torque=%s" % drive_torque)
	
	# trazione posteriore
	differential(drive_torque,rear_brake_torque,wheels,delta)
	front_wheels[0].apply_torque(0.0, front_brake_torque * 0.5, drive_inertia,delta)
	front_wheels[1].apply_torque(0.0, front_brake_torque * 0.5, drive_inertia,delta)
