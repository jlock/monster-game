extends Node2D
## Fireball explosion: hurts every monster within the blast radius once,
## then plays a flash + shockwave + embers + smoke and cleans itself up.

@export var blast_radius := 170.0
@export var damage := 3
@export var duration := 0.7
@export var shake_strength := 18.0

var _t := 0.0


func _ready() -> void:
	_damage_monsters()
	Game.play_sfx("explosion", 2.0, 0.05)
	$Embers.emitting = true
	$Smoke.emitting = true
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(shake_strength)
	get_tree().create_timer(2.0).timeout.connect(queue_free)


func _damage_monsters() -> void:
	for monster in get_tree().get_nodes_in_group("monsters"):
		# Count a hit if any part of the monster's body is inside the blast.
		var center: Vector2 = monster.get_center()
		if center.distance_to(global_position) <= blast_radius + monster.get_size_radius():
			monster.hit(damage)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var p := clampf(_t / duration, 0.0, 1.0)
	if p >= 1.0:
		return
	var ease_out := 1.0 - pow(1.0 - p, 3.0)
	var fade := 1.0 - p

	# Big soft fireball that swells and fades.
	draw_circle(Vector2.ZERO, blast_radius * ease_out, Color(1, 0.35, 0.05, 0.45 * fade))
	draw_circle(Vector2.ZERO, blast_radius * 0.7 * ease_out, Color(1, 0.6, 0.1, 0.6 * fade))
	# Bright white-hot core, gone quickly.
	var core_fade := clampf(1.0 - p * 2.5, 0.0, 1.0)
	draw_circle(Vector2.ZERO, blast_radius * 0.45 * ease_out, Color(1, 1, 0.8, core_fade))
	# Shockwave ring racing to the edge of the blast.
	draw_arc(Vector2.ZERO, blast_radius * ease_out, 0, TAU, 64,
		Color(1, 0.9, 0.5, fade), 10.0 * fade + 1.0)
