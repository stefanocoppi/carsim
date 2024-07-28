class_name BaseTireModel



func _init() -> void:
	pass


# fare l'override di questo metodo astratto
func update_tire_forces(_slip: Vector2, _normal_load: float, _surface_mu: float) -> Vector3:
	return Vector3.ZERO
