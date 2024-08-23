class_name Drivetrain



var gear_ratios = [ 3.08, 2.455, 1.66, 1.175, 1.0 ]
var final_drive = 3.7
var reverse_ratio = 3.2
var diff_split    = 0.5
var drive_inertia = 10.0
var engine_inertia = 0.0
var gear_inertia = 0.2
var selected_gear = 0  # marcia correntemente selezionata
var avg_rear_spin = 0.0
var gearbox_shaft_speed = 0.0
var reaction_torque = 0.0
var car:Car = null


func _init(p_car):
	car = p_car


func shift_up():
	if (selected_gear< gear_ratios.size()):
		selected_gear += 1



func shift_down():
	if (selected_gear > -1):
		selected_gear -= 1


func get_gear_ratio() -> float:
	if selected_gear > 0:
		return gear_ratios[selected_gear - 1] * final_drive
	# retromarcia
	if selected_gear == -1:
		return - reverse_ratio * final_drive
	return 0.0


func differential(torque,brake_torque,wheels,delta):
	#print("torque= %s" % torque)
	var t1 = torque * 0.5
	var t2 = torque * 0.5
	var diff_sum = 0.0
	t2 *= diff_split
	t1 *= (1 - diff_split)
	#print("diff torque=%s" % torque)
	#print("diff_split=%s" % diff_split)
	
	diff_sum += wheels[0].apply_torque(t1, brake_torque * 0.5,drive_inertia, delta)
	diff_sum -= wheels[1].apply_torque(t2, brake_torque * 0.5,drive_inertia, delta)
	#wheels[0].apply_torque(t1, brake_torque * 0.5,drive_inertia, delta)
	#wheels[1].apply_torque(t2, brake_torque * 0.5,drive_inertia, delta)
	#print("diff_sum=%s" % diff_sum)
	
	diff_split = 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
	

func apply_torque_to_wheel(torque, front_brake_torque, rear_brake_torque, wheels, delta):
	var front_wheels = [wheels[2], wheels[3]]

	drive_inertia = (engine_inertia + pow(abs(get_gear_ratio()), 2) * gear_inertia)
	var drive_torque = torque * get_gear_ratio()
	
	#print("drive_torque=%s" % drive_torque)
	
	# trazione posteriore
	differential(drive_torque,rear_brake_torque,wheels,delta)
	front_wheels[0].apply_torque(0.0, front_brake_torque * 0.5, drive_inertia,delta)
	front_wheels[1].apply_torque(0.0, front_brake_torque * 0.5, drive_inertia,delta)
	reaction_torque = (wheels[0].get_reaction_torque() + wheels[1].get_reaction_torque()) * 0.5
	reaction_torque *= (1.0 / get_gear_ratio())
