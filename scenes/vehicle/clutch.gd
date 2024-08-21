class_name Clutch

# parametri
var clutch_linearity = 0.3
var clutch_max_torque = 825.0

var car:Car = null

# stato
var clutch_application = 0.0
var clutch_current_torque = 0.0
# true indica che il motore è collegato alla trasmissione
var prepost_locked = false 


func _init(p_car):
	car = p_car


# imposta l'applicazione della frizione
# app = 0 frizione staccata
# app = 1 frizione attaccata
func set_clutch_application(app):
	app = clampf(app,0.0,1.0)
	app = clutch_linearity * app + (1.0 - clutch_linearity) * (app*app*app)
	clutch_application = app
	clutch_current_torque = app * clutch_max_torque


func calc_forces():
	if not prepost_locked:
		# il motore è disconnesso dal cambio
		# la frizione lavora per rendere uguali le velocità
		# di rotazione del motore e del cambio
		pass
