extends Area2D
## A fireball that flies to a target spot and explodes there.
## It also explodes early if it runs into a monster on the way.

const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")

@export var speed := 650.0
@export var radius := 18.0

var target := Vector2.ZERO
var _exploded := false
var _t := 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	$Trail.emitting = true


func _physics_process(delta: float) -> void:
	_t += delta
	var to_target := target - global_position
	var step := speed * delta
	if to_target.length() <= step:
		global_position = target
		explode()
		return
	global_position += to_target.normalized() * step
	queue_redraw()


func _draw() -> void:
	# Flickering layered ball: red glow, orange body, yellow-white core.
	var flicker := 1.0 + sin(_t * 40.0) * 0.08
	draw_circle(Vector2.ZERO, radius * 1.6 * flicker, Color(1, 0.3, 0.05, 0.35))
	draw_circle(Vector2.ZERO, radius * flicker, Color(1, 0.5, 0.1))
	draw_circle(Vector2.ZERO, radius * 0.55, Color(1, 0.95, 0.6))


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("monsters"):
		explode()


func explode() -> void:
	if _exploded:
		return
	_exploded = true
	var explosion := EXPLOSION_SCENE.instantiate()
	explosion.global_position = global_position
	get_parent().add_child.call_deferred(explosion)
	# Let the trail fade out on its own instead of vanishing.
	var trail: CPUParticles2D = $Trail
	trail.emitting = false
	trail.reparent.call_deferred(get_parent())
	get_tree().create_timer(trail.lifetime).timeout.connect(trail.queue_free)
	queue_free()
