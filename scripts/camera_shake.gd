extends Camera2D
## Call shake() to rattle the screen. The shake fades out on its own.

@export var decay := 40.0  # how fast the shake settles, in pixels per second

var _strength := 0.0


func shake(strength: float) -> void:
	_strength = maxf(_strength, strength)


func _process(delta: float) -> void:
	if _strength <= 0.0:
		offset = Vector2.ZERO
		return
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _strength
	_strength = maxf(_strength - decay * delta, 0.0)
