class_name Wheel
extends RayCast3D


var tire_model:BaseTireModel


# parametri delle sospensioni
var spring_length = 0.15 # 0.1
var wheel_mass = 30.0
var tire_radius = 0.3 #0.31
var spring_stiffness = 60.0
var bump = 8.0
var rebound = 9.0


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
var planar_vect = Vector2.ZERO
var wheel_inertia: float = 1.35
var prev_pos = Vector3.ZERO
var local_vel = Vector3.ZERO
var z_vel:float = 0.0
var slip_vec: Vector2 = Vector2.ZERO
var surface_mu = 1.0
var ackermann = 0.15


@onready var wheel_mesh = $MeshInstance3D
@onready var car = $'..' # ottiene il nodo padre


func _ready():
	set_target_position(Vector3.DOWN * (spring_length + tire_radius))
	
	wheel_inertia = 0.5 * wheel_mass * pow(tire_radius, 2)
	
	tire_model = PacejkaTireModel.new()



func _process(delta):
	#DebugDraw3D.draw_line(global_position,global_position+target_position,Color.WHITE)
	
	wheel_mesh.position.y = -spring_curr_length
	
	wheel_mesh.rotate_x(wrapf(-spin * delta,0, TAU))
	

func _physics_process(delta):
	pass


func apply_forces(delta):
	# local_vel = (global_transform.origin - prev_pos) / delta * global_transform.basis
	#var origin_world = global_transform.origin
	#print("origin_world=%s" % origin_world)
	#var origin_local = global_transform.origin * global_transform.basis.transposed()
	#print("origin_local=%s" % origin_local)
	local_vel = (global_transform.origin - prev_pos) / delta * global_transform.basis
	#print("local_vel=%s" % local_vel)
	z_vel = -local_vel.z
	planar_vect = Vector2(local_vel.x, local_vel.z)
	if planar_vect.length()> 0.01:
		planar_vect = planar_vect.normalized()
	prev_pos = global_transform.origin
	
	if is_colliding():
		spring_curr_length = get_collision_point().distance_to(global_transform.origin) - tire_radius
	else:
		spring_curr_length = spring_length
	
	# calcola la forza della molla
	
	# calcolo la compressione della molla in mm
	spring_load_mm = (spring_length - spring_curr_length) * 1000
	#print("spring_load_mm=%s" % spring_load_mm)
	
	# calcola la forza della molla in N (Legge di Hooke)
	spring_load_newton = spring_load_mm * spring_stiffness
	#print("spring_load_newton=%s" % spring_load_newton)
	
	# calcola la velocità di movimento della sospensione in mm per sec
	spring_speed_mm_per_seconds = (spring_load_mm - prev_spring_load_mm) / delta
	#print("spring_speed_mm_per_seconds=%s" % spring_speed_mm_per_seconds)
	prev_spring_load_mm = spring_load_mm
	
	# calcola la forza di smorzamento in N e la addiziona a spring_load
	if spring_speed_mm_per_seconds >= 0:
		spring_load_newton += spring_speed_mm_per_seconds * bump # bump
	else :
		spring_load_newton += spring_speed_mm_per_seconds * rebound # rebound
	
	y_force = spring_load_newton
	y_force = max(0, y_force)
	#print("y_force=%s" % y_force)
	
	# calcola lo slip
	slip_vec.x = asin(clamp(-planar_vect.x, -1, 1)) # X slip is lateral slip
	slip_vec.y = 0.0 # Y slip is the longitudinal Z slip
	
	
	# applica le forze allo chassis dell'auto
	if is_colliding():
		#z_vel = 8.9
		#spin = 30.0
		if not is_zero_approx(z_vel):
			slip_vec.y = (z_vel - spin * tire_radius) / abs(z_vel)
		else:
			slip_vec.y = (z_vel - spin * tire_radius) / abs(z_vel + 0.0000001)
			
		#print("slip_vec=%s" % slip_vec)
		
		surface_mu = 1.0
		#y_force = 2500.0
		#slip_vec = Vector2(slip_vec.x,-0.01)
		
		# calcola le forze generate dai pneumatici
		force_vec = tire_model.update_tire_forces(slip_vec,y_force,surface_mu)
		
		var contact = get_collision_point() - car.global_transform.origin
		var normal = get_collision_normal()
		
		car.apply_force(normal * y_force, contact)
		car.apply_force(global_transform.basis.x * force_vec.x, contact)
		car.apply_force(global_transform.basis.z * force_vec.y, contact)
	else:
		spin -= sign(spin) * delta * 2 / wheel_inertia # stop undriven wheels from spinning endlessly


func apply_torque(drive_torque,brake_torque,delta) -> float:
	
	var prev_spin = spin
	# traction torque
	var net_torque = force_vec.y * tire_radius
	# aggiungiamo la coppia del motore
	net_torque += drive_torque
	
	if abs(spin) < 5 and brake_torque > abs(net_torque):
		spin = 0
	else:
		net_torque -= brake_torque * sign(spin)
		spin += delta * net_torque / wheel_inertia
	
	if drive_torque * delta == 0:
		return 0.5
	else:
		return (spin - prev_spin) * (wheel_inertia) / (drive_torque * delta)


func steer(input,max_steer):
	rotation.y = max_steer * (input + (1 -cos(input * 0.5 * PI)) * ackermann)
