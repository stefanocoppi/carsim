class_name Car
extends RigidBody3D


const MS_TO_KMH = 3.6


@onready var wheel_fr = $WheelFR as Wheel
@onready var wheel_fl = $WheelFL as Wheel
@onready var wheel_rr = $WheelRR as Wheel
@onready var wheel_rl = $WheelRL as Wheel
@onready var wheels:Array[Wheel] = [ wheel_rl, wheel_rr, wheel_fl, wheel_fr]
@onready var rev_counter = $"../Gui/Rpm"

var engine:Engine_t = null
var drivetrain:Drivetrain = null
var clutch:Clutch = null
var brakes:Brake = null
var telemetry:Telemetry = null

# parametri fisici
var max_steer = 0.0 #0.3
var steer_speed = 0.0 #5.0


var throttle_input: float = 0.0
var brake_input = 0.0
var steering_input = 0.0
var steering_amount = 0.0
var clutch_input = 0.0
var torque_out = 0.0

var avg_front_spin = 0.0
var avg_rear_spin = 0.0
var rear_brake_torque = 0.0
var front_brake_torque = 0.0
var speedometer = 0.0    # Km/h
var odometer = 0.0       # m
var drive_reaction_torque = 0.0
var clutch_reaction_torque = 0.0


func _ready():
	var physics_params = load_physics_params("res://assets/car/sport_car.json")
	wheel_fl.init_params(physics_params["wheel_fl"],physics_params["pacejka"])
	wheel_fr.init_params(physics_params["wheel_fr"],physics_params["pacejka"])
	wheel_rl.init_params(physics_params["wheel_rl"],physics_params["pacejka"])
	wheel_rr.init_params(physics_params["wheel_rr"],physics_params["pacejka"])
	
	engine = Engine_t.new(self)
	engine.init_params(physics_params["engine"])
	engine.start()
	clutch = Clutch.new()
	clutch.init_params(physics_params["clutch"])
	drivetrain = Drivetrain.new(self)
	drivetrain.init_params(physics_params["drivetrain"])
	drivetrain.engine_inertia = engine.inertia_moment
	brakes = Brake.new()
	brakes.init_params(physics_params["brakes"])
	telemetry = Telemetry.new()
	init_params(physics_params)


func init_params(json_data):
	max_steer = json_data["steer"]["max_steer"]
	steer_speed = json_data["steer"]["steer_speed"]


func _process(delta):
	rev_counter.set_gear(drivetrain.selected_gear)
	rev_counter.set_speed(speedometer)
	rev_counter.set_rpm(engine.rpm)


func _physics_process(delta):
	
	throttle_input = Input.get_action_strength("Throttle")
	brake_input = Input.get_action_strength("Brake")
	steering_input = Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight")
	
	# frenatura
	var brakes_torques = brakes.get_brake_torques(brake_input, delta)
	front_brake_torque = brakes_torques.x
	rear_brake_torque = brakes_torques.y
	
	# sterzatura delle ruote
	if (steering_input < steering_amount):
		steering_amount -= steer_speed * delta
		if (steering_input > steering_amount):
			steering_amount = steering_input
	elif (steering_input > steering_amount):
		steering_amount += steer_speed * delta
		if (steering_input < steering_amount):
			steering_amount = steering_input
	
	wheel_fl.steer(steering_amount,max_steer)
	wheel_fr.steer(steering_amount,max_steer)
	
	# cambio
	if Input.is_action_just_pressed("ShiftUp"):
		drivetrain.shift_up()
	if Input.is_action_just_pressed("ShiftDown"):
		drivetrain.shift_down()
	
	
	
	
	#print("torque= %s" % engine.torque_out)
	
	if drivetrain.selected_gear == 0:
		freewheel(delta)
	else:
		engage(engine.torque_out,delta)
	
	engine.throttle = throttle_input
	drivetrain.gearbox_loop()
	engine.loop(delta)
	
	wheel_fr.apply_forces(delta)
	wheel_fl.apply_forces(delta)
	wheel_rr.apply_forces(delta)
	wheel_rl.apply_forces(delta)
	
	# aggiorna l'odometro con la distanza percorsa
	var distance = (speedometer / MS_TO_KMH) * delta  # in m
	odometer += distance

	telemetry.write_data(self)


func freewheel(delta):
	avg_front_spin = 0.0
	clutch_reaction_torque = 0.0
	# applica la coppia frenante
	wheel_fl.apply_torque(0.0,front_brake_torque,0.0,delta)
	wheel_fr.apply_torque(0.0,front_brake_torque,0.0,delta)
	wheel_rl.apply_torque(0.0,rear_brake_torque,0.0,delta)
	wheel_rr.apply_torque(0.0,rear_brake_torque,0.0,delta)
	# calcola la velocità mostrata nel tachimetro
	avg_front_spin += (wheel_fl.spin + wheel_fr.spin) * 0.5
	speedometer = avg_front_spin * wheel_fl.tire_radius * MS_TO_KMH


func engage(torque,delta):
	Utils.log("engage() start")
	avg_front_spin = 0.0
	avg_rear_spin = 0.0
	#print("torque= %s" % torque)
	#var drive_torque = torque * drivetrain.get_gear_ratio()
	avg_front_spin += (wheel_fl.spin + wheel_fr.spin) * 0.5
	avg_rear_spin += (wheel_rl.spin + wheel_rr.spin) * 0.5
	Utils.log("avg_front_spin=%s, avg_rear_spin=%s" % [avg_front_spin,avg_rear_spin])
	
	var gearbox_shaft_speed = avg_rear_spin * drivetrain.get_gear_ratio()
	Utils.log("engine.av=%s, gearbox_shaft_speed=%s" % [engine.get_angular_vel(),gearbox_shaft_speed])
	var speed_error = engine.get_angular_vel() - gearbox_shaft_speed
	var clutch_kick = absf(speed_error) * 0.2
	Utils.log("speed_error=%s, clutch_kick=%s" % [speed_error,clutch_kick])
	var tr = drivetrain.reaction_torque
	Utils.log("tr=%s" % tr)
	var clutch_slip_torque = 0.8 * clutch.friction
	var reaction_torques = clutch.get_reaction_torques(engine.get_angular_vel(),gearbox_shaft_speed,
		engine.torque_out,tr,clutch_slip_torque,clutch_kick)
	
	if clutch.locked:
		reaction_torques.x = engine.torque_out
		#reaction_torques.y = 0.0
	
	drive_reaction_torque = reaction_torques.x * (1 - clutch_input)
	clutch_reaction_torque = reaction_torques.y * (1 - clutch_input)
	Utils.log("drive_reaction_torque=%s, clutch_reaction_torque=%s" % [drive_reaction_torque,clutch_reaction_torque])
	
	# simulazione della trasmissione
	drivetrain.apply_torque_to_wheel(drive_reaction_torque,front_brake_torque,rear_brake_torque,wheels,delta)
	
	speedometer = avg_front_spin * wheel_fl.tire_radius * MS_TO_KMH
	
	# applica la coppia frenante
	#wheel_fl.apply_torque(0.0,front_brake_torque,delta)
	#wheel_fr.apply_torque(0.0,front_brake_torque,delta)
	

# carica i parametri fisici dell'auto da un file JSON
# ritorna un dizionario con i parametri
func load_physics_params(filename) -> Dictionary:
	var file = FileAccess.open(filename,FileAccess.READ)
	var content = file.get_as_text()
	var json_data = JSON.parse_string(content)
	file.close()
	
	return json_data
	
