extends Node2D
## Draws a cute flying dinosaur (pterodactyl) facing left, with flapping wings.

@export var color := Color(0.3, 0.75, 0.55)
@export var flap_speed := 10.0

var flapping := true
var _t := 0.0


func _process(delta: float) -> void:
	if flapping:
		_t += delta
		queue_redraw()


func _draw() -> void:
	var dark := color.darkened(0.3)
	var light := color.lightened(0.35)
	var flap := sin(_t * flap_speed) if flapping else 0.4
	# Wing tip goes from high up (flap = 1) to down low (flap = -1).
	var tip_y := lerpf(55.0, -75.0, (flap + 1.0) / 2.0)

	# Far wing, behind the body.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-5, -8), Vector2(30, -8), Vector2(25, tip_y * 0.85 - 5)]), dark)

	# Tail.
	draw_colored_polygon(PackedVector2Array([
		Vector2(35, -8), Vector2(90, -18), Vector2(35, 8)]), color)

	# Body and belly.
	draw_colored_polygon(_ellipse(Vector2.ZERO, 45, 22), color)
	draw_colored_polygon(_ellipse(Vector2(-5, 8), 30, 11), light)

	# Little feet.
	draw_line(Vector2(-5, 18), Vector2(-10, 32), dark, 5)
	draw_line(Vector2(12, 18), Vector2(8, 32), dark, 5)

	# Head crest, head and beak.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-50, -34), Vector2(-5, -52), Vector2(-40, -22)]), dark)
	draw_circle(Vector2(-50, -18), 21, color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-62, -26), Vector2(-112, -14), Vector2(-62, -6)]), Color(1, 0.75, 0.3))

	# Eye.
	draw_circle(Vector2(-55, -24), 8, Color.WHITE)
	draw_circle(Vector2(-58, -24), 4, Color.BLACK)

	# Near wing, in front of the body.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20, -5), Vector2(25, -5), Vector2(5, tip_y)]), color.lightened(0.1))


func _ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		points.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return points
