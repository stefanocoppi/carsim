class_name RayCastSuspension
extends RayCast3D

# parametri delle sospensioni
var spring_length = 0.2
var tire_radius = 0.31

var spring_curr_length: float = spring_length

@onready var wheel_mesh = $MeshInstance3D



func _ready():
	set_target_position(Vector3.DOWN * (spring_length + tire_radius))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#DebugDraw3D.draw_line(global_position,global_position+target_position,Color.WHITE)
	
	wheel_mesh.position.y = -spring_curr_length


func _physics_process(delta):
	pass


func apply_forces(delta):
	if is_colliding():
		spring_curr_length = get_collision_point().distance_to(global_transform.origin) - tire_radius
	else:
		spring_curr_length = spring_length
