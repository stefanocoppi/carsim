extends Control


const RPM_MAX = 8000


@onready var needle = $lancetta
@onready var gear_label = $marcia
@onready var speed_label = $velocita

var gear = 0
var speed = 0
var rpm = 0
var sum_rpm = 0
var n = 0


func _ready():
	pass # Replace with function body.
	set_speed(101.1)


func _process(delta):
	# converte la marcia da int in stringa
	var t_gear = decode_gear(gear)
	# valorizza la label
	gear_label.text = t_gear
	
	# valorizza la label della velocità
	speed_label.text = str(speed)
	
	# usiamo la media degli rpm su 3 valori
	# per evitare fluttuazioni troppo veloci del valore
	# che spostano la lancetta avanti ed indietro
	sum_rpm += rpm
	n += 1
	if n>=3:
		var avg_rpm = float(sum_rpm) / n
		sum_rpm = 0
		n = 0
		var rot_deg = -120.0 + (avg_rpm/RPM_MAX)*240.0
		needle.rotation_degrees = rot_deg


func set_rpm(p_rpm):
	rpm = p_rpm


func set_gear(p_gear):
	gear = p_gear


func set_speed(p_speed:float):
	speed = int(p_speed)


# converte la marcia da int in stringa
func decode_gear(p_gear:int) -> String:
	var t_gear
	
	if p_gear == 0:
		t_gear = "N"
	elif p_gear == -1:
		t_gear = "R"
	else:
		t_gear = str(p_gear)
	
	return t_gear
