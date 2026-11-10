extends Node2D
## A ring drawn around the thrower showing fireball cooldown.
## Fills up while recharging and glows when the fireball is ready.

@export var radius := 46.0
@export var width := 8.0

## 0 = just used, 1 = ready.
var progress := 1.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	if progress >= 1.0:
		queue_redraw()  # keep the ready glow pulsing


func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(0, 0, 0, 0.25), width)
	if progress >= 1.0:
		var pulse := 0.6 + 0.4 * sin(_t * 5.0)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 0.45, 0.1, pulse), width)
	else:
		draw_arc(Vector2.ZERO, radius, -PI / 2, -PI / 2 + TAU * progress, 48,
			Color(1, 0.6, 0.2, 0.8), width)
