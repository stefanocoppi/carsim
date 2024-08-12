extends Node

var pacejka:PacejkaTireModel = null


func _ready():
	pacejka = PacejkaTireModel.new()

	test_pacejka_long()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func test_pacejka_lat():
	var file = FileAccess.open("res://scenes/test/pacejka.txt",FileAccess.WRITE)
	var mu = 1.0
	var normal_force = 10.0
	var lat_slip = -45.0
	while lat_slip <= 45.0:
		var slip_vec = Vector2(deg_to_rad(lat_slip),0.0)
		var force_vec = pacejka.update_tire_forces(slip_vec,normal_force,mu)
		var text = "%s, %s \n" % [lat_slip,force_vec.x]
		print("lat_slip=%s force_vec.x=%s" % [lat_slip,force_vec.x])
		file.store_string(text)
		lat_slip += 0.5
	file.close()


func test_pacejka_long():
	var file = FileAccess.open("res://scenes/test/pacejka_long.txt",FileAccess.WRITE)
	var mu = 1.0
	var normal_force = 10.0
	var slip_ratio = -0.5
	while slip_ratio <= 0.5:
		var slip_vec = Vector2(0.0,slip_ratio)
		var force_vec = pacejka.update_tire_forces(slip_vec,normal_force,mu)
		var text = "%s, %s \n" % [slip_ratio,force_vec.y]
		print("slip_ratio=%s force_vec.y=%s" % [slip_ratio,force_vec.y])
		file.store_string(text)
		slip_ratio += 0.01
	file.close()
