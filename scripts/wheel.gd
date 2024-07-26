class_name Wheel
extends RayCast3D

# parametri delle sospensioni
var spring_length = 0.1
var wheel_mass = 15.0
var tire_radius = 0.31
var spring_stiffness = 45.0
var bump = 3.5
var rebound = 4.0


# variabili delle sospensioni
var spring_curr_length: float = spring_length
var spring_load_mm: float = 0.0
var prev_spring_load_mm:float = 0.0
var spring_load_newton:float = 0.0
var spring_speed_mm_per_seconds:float = 0.0

# parametri delle gomme
var spin: float = 0.0
var y_force: float = 0.0
var force_vec = Vector3.ZERO
var wheel_inertia: float = 0.0

@onready var wheel_mesh = $MeshInstance3D
@onready var car = $'..' # ottiene il nodo padre


func _ready():
	set_target_position(Vector3.DOWN * (spring_length + tire_radius))
	
	wheel_inertia = 0.5 * wheel_mass * pow(tire_radius, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#DebugDraw3D.draw_line(global_position,global_position+target_position,Color.WHITE)
	
	wheel_mesh.position.y = -spring_curr_length
	
	wheel_mesh.rotate_x(wrapf(-spin * delta,0, TAU))
	

func _physics_process(delta):
	pass


func apply_forces(delta):
	if is_colliding():
		spring_curr_length = get_collision_point().distance_to(global_transform.origin) - tire_radius
	else:
		spring_curr_length = spring_length
	
	# calcola la forza della molla
	
	# calcolo la compressione della molla in mm
	spring_load_mm = (spring_length - spring_curr_length) * 1000
	print("spring_load_mm=%s" % spring_load_mm)
	
	# calcola la forza della molla in N (Legge di Hooke)
	spring_load_newton = spring_load_mm * spring_stiffness
	print("spring_load_newton=%s" % spring_load_newton)
	
	# calcola la velocità di movimento della sospensione in mm per sec
	spring_speed_mm_per_seconds = (spring_load_mm - prev_spring_load_mm) / delta
	print("spring_speed_mm_per_seconds=%s" % spring_speed_mm_per_seconds)
	prev_spring_load_mm = spring_load_mm
	
	# calcola la forza di smorzamento in N e la addiziona a spring_load
	if spring_speed_mm_per_seconds >= 0:
		spring_load_newton += spring_speed_mm_per_seconds * bump # bump
	else :
		spring_load_newton += spring_speed_mm_per_seconds * rebound # rebound
	
	y_force = spring_load_newton
	y_force = max(0, y_force)
	print("y_force=%s" % y_force)
	
	# applica le forze allo chassis dell'auto
	if is_colliding():
		
		var contact = get_collision_point() - car.global_transform.origin
		var normal = get_collision_normal()
		
		car.apply_force(normal * y_force, contact)


func apply_torque(drive_torque,brake_torque,delta):
	var net_torque = force_vec.y * tire_radius
	net_torque += drive_torque
	
	if abs(spin) < 5 and brake_torque > abs(net_torque):
		spin = 0
	else:
		net_torque -= brake_torque * sign(spin)
		spin += delta * net_torque / wheel_inertia 
