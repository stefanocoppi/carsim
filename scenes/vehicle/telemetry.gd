class_name Telemetry

const FILENAME = "res://telemetry.txt"
const DISTANCE_STEP = 10.0  # m


var file = null
var last_distance = 0.0
var sum_acc = 0.0
var n = 0

func _init():
	file = FileAccess.open(FILENAME,FileAccess.WRITE)
	var header = [ "distance" , "speed","rpm", "selected_gear","drive_torque","diff_split","t1","t2",
		"avg_wheel_rl.traction_torque"]
	file.store_csv_line(header)


func write_data(car:Car):
	var delta_distance = car.odometer - last_distance
	sum_acc += car.wheel_rl.traction_torque
	n += 1
	if delta_distance >= DISTANCE_STEP:
		last_distance = car.odometer
		var avg_acc = float(sum_acc / n)
		sum_acc = 0.0
		n = 0
		var data = [car.odometer, car.speedometer, car.engine.rpm,
					car.drivetrain.selected_gear, car.drivetrain.drive_torque,
					car.drivetrain.diff_split,car.drivetrain.t1,car.drivetrain.t2,
					avg_acc]
		file.store_csv_line(data)
