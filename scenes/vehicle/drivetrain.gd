class_name Drivetrain


var gear_ratios = [ 3.08, 2.455, 1.66, 1.175, 1.0 ]
var final_drive = 3.7
var reverse_ratio = 3.2
var selected_gear = 0
var diff_split    = 0.5


func shift_up():
	if selected_gear < gear_ratios.size():
		selected_gear += 1
	#gear = clamp(gear, -1, drivetrain_params.gear_ratios.size())


func shift_down():
	if selected_gear > -1:
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
	#var diff_sum = 0.0
	#t2 *= diff_split
	#t1 *= (1 - diff_split)
	#print("diff torque=%s" % torque)
	#print("diff_split=%s" % diff_split)
	
	#diff_sum += wheels[0].apply_torque(t1, brake_torque * 0.5, delta)
	#diff_sum -= wheels[1].apply_torque(t2, brake_torque * 0.5, delta)
	wheels[0].apply_torque(t1, brake_torque * 0.5, delta)
	wheels[1].apply_torque(t2, brake_torque * 0.5, delta)
	#print("diff_sum=%s" % diff_sum)
	
	#diff_split = 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
	

func apply_torque_to_wheel(torque, front_brake_torque, rear_brake_torque, wheels, delta):
	var front_wheels = [wheels[2], wheels[3]]

	var drive_torque = torque * get_gear_ratio()
	
	#print("drive_torque=%s" % drive_torque)
	
	# trazione posteriore
	differential(drive_torque,rear_brake_torque,wheels,delta)
	front_wheels[0].apply_torque(0.0, front_brake_torque * 0.5, delta)
	front_wheels[1].apply_torque(0.0, front_brake_torque * 0.5, delta)
