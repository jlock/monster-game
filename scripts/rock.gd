extends Area2D
## A thrown rock. Flies in a straight line and bonks the first monster it touches.

@export var speed := 900.0
@export var damage := 1
@export var radius := 14.0

var direction := Vector2.RIGHT


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += 12.0 * delta  # spin for fun
	if not get_viewport_rect().grow(100).has_point(global_position):
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.45, 0.42, 0.4))
	draw_circle(Vector2(-4, -4), radius * 0.35, Color(0.6, 0.57, 0.55))


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("hit"):
		area.hit(damage)
		queue_free()
