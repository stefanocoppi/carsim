class_name Telemetry

const FILENAME = "res://telemetry.txt"
const DISTANCE_STEP = 10.0  # m


var file = null
var last_distance = 0.0
var sum_fl_force_vec = 0.0
var sum_fr_force_vec = 0.0
var sum_fl_slip_vec = 0.0
var sum_fr_slip_vec = 0.0
var sum_fl_z_vel = 0.0
var sum_fr_z_vel = 0.0
var sum_fl_spin = 0.0
var sum_fr_spin = 0.0
var n = 0

func _init():
	file = FileAccess.open(FILENAME,FileAccess.WRITE)
	var header = [ "distance" , "speed","rpm", "selected_gear",
	"fl_force_vec.y","fl_slip_vec.y","fl_z_vel","fl_spin",
	"fr_force_vec.y","fr_slip_vec.y","fr_z_vel","fr_spin"]
	file.store_csv_line(header)


func write_data(car:Car):
	var delta_distance = car.odometer - last_distance
	sum_fl_force_vec += car.wheel_fl.force_vec.y
	sum_fr_force_vec += car.wheel_fr.force_vec.y
	sum_fl_slip_vec += car.wheel_fl.slip_vec.y
	sum_fr_slip_vec  += car.wheel_fr.slip_vec.y
	sum_fl_z_vel += car.wheel_fl.z_vel
	sum_fr_z_vel += car.wheel_fr.z_vel
	sum_fl_spin += car.wheel_fl.spin * car.wheel_fl.tire_radius
	sum_fr_spin += car.wheel_fr.spin * car.wheel_fr.tire_radius
	n += 1
	if delta_distance >= DISTANCE_STEP:
		last_distance = car.odometer
		var avg_fl_force_vec = float(sum_fl_force_vec / n)
		var avg_fr_force_vec = float(sum_fr_force_vec / n)
		var avg_fl_slip_vec = float(sum_fl_slip_vec / n)
		var avg_fr_slip_vec = float(sum_fr_slip_vec / n)
		var avg_fl_z_vel = float(sum_fl_z_vel / n)
		var avg_fr_z_vel = float(sum_fr_z_vel / n)
		var avg_fl_spin = float(sum_fl_spin / n)
		var avg_fr_spin = float(sum_fr_spin / n)
		n = 0
		sum_fl_force_vec = 0.0
		sum_fr_force_vec = 0.0
		sum_fl_slip_vec = 0.0
		sum_fr_slip_vec = 0.0
		sum_fl_z_vel = 0.0
		sum_fr_z_vel = 0.0
		sum_fl_spin = 0.0
		sum_fr_spin = 0.0
		var data = [car.odometer, car.speedometer, car.engine.rpm,
					car.drivetrain.selected_gear,
					avg_fl_force_vec,avg_fl_slip_vec,avg_fl_z_vel,avg_fl_spin,
					avg_fr_force_vec,avg_fr_slip_vec,avg_fr_z_vel,avg_fr_spin]
		file.store_csv_line(data)
