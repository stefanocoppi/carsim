# Camera libera di muoversi nel piano xz con i tasti freccia
# sull'asse y con i tasti pageup/pagedown
# e di ruotare la vista con il mouse
extends Camera3D

# velocità di traslazione
var move_speed = 100
# velocità di rotazione
var rotate_speed = 0.05

var last_mouse_position = Vector2.ZERO


func _ready():
	# nasconde il cursore del mouse
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _process(delta):
	
	# traslazione
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_page_up"):
		direction.y += 1
	if Input.is_action_pressed("ui_page_down"):
		direction.y -= 1
	
	direction = direction.normalized()
	
	translate(direction * move_speed * delta)
	
	# rotazione
	var mouse_movement = get_viewport().get_mouse_position() - last_mouse_position
	last_mouse_position = get_viewport().get_mouse_position()
	
	#rotate_y(deg_to_rad(-mouse_movement.x * rotate_speed))
	rotate_object_local(Vector3(0,1,0), deg_to_rad(-mouse_movement.x * rotate_speed))
	#rotation_degrees.y = rotation_degrees.y - mouse_movement.x * rotate_speed
	#var rotation_x = rotation_degrees.x - mouse_movement.y * rotate_speed
	#rotation_x = clamp(rotation_x,-90,90)
	#rotation_degrees.x = rotation_x
	#rotate_x(- mouse_movement.y * rotate_speed)
	
