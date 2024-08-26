class_name Telemetry

const FILENAME = "res://telemetry.txt"
const DISTANCE_STEP = 10.0  # m


var file = null
var last_distance = 0.0


func _init():
	file = FileAccess.open(FILENAME,FileAccess.WRITE)
	var header = [ "distance" , "speed", "drive_torque","diff_split","t1","t2"]
	file.store_csv_line(header)


func write_data(car:Car):
	var delta_distance = car.odometer - last_distance
	if delta_distance >= DISTANCE_STEP:
		last_distance = car.odometer
		var data = [car.odometer, car.speedometer, car.drivetrain.drive_torque,
					car.drivetrain.diff_split,car.drivetrain.t1,car.drivetrain.t2]
		file.store_csv_line(data)
