extends Area2D
## Base monster: has health, flashes when hit, falls over and gives points at 0 health.
## This version walks along the ground. Other monsters (like the flying dinosaur)
## extend this script and override _move() and _play_fall_animation().
## The ground monster's origin is at its feet so it tips over from the bottom.

signal fell_over

@export var max_health := 5
@export var walk_speed := 40.0
## The monster stops walking when it reaches this x position.
@export var stop_x := 250.0
@export var score_value := 1
@export var body_color := Color(0.55, 0.3, 0.8)
## Roughly how far the body reaches from its center, used for blast-radius checks.
@export var size_radius := 60.0

var health: int
var is_down := false

@onready var body: CanvasItem = $Body
@onready var health_fill: ColorRect = $HealthBar/Fill
@onready var health_bar_width: float = health_fill.size.x


func _ready() -> void:
	health = max_health
	body.set("color", body_color)
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if not is_down:
		_move(delta)


func _move(delta: float) -> void:
	if position.x > stop_x:
		position.x -= walk_speed * delta


func hit(damage: int) -> void:
	if is_down:
		return
	health = max(health - damage, 0)
	_update_health_bar()
	_flash()
	Game.play_sfx("hit")
	if health == 0:
		_fall_over()


## Middle of the monster's body, used for blast-radius checks.
func get_center() -> Vector2:
	return $CollisionShape2D.global_position


func get_size_radius() -> float:
	return size_radius


func _update_health_bar() -> void:
	health_fill.size.x = health_bar_width * float(health) / max_health


func _flash() -> void:
	# Quick squish and white flash so every hit feels good.
	var tween := create_tween()
	body.modulate = Color(3, 3, 3)
	tween.tween_property(body, "modulate", Color.WHITE, 0.15)
	var squish := create_tween()
	scale = Vector2(1.15, 0.85)
	squish.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)


func _fall_over() -> void:
	is_down = true
	remove_from_group("monsters")
	set_deferred("monitorable", false)  # rocks fly past once it's down
	$HealthBar.hide()
	Game.add_score(score_value)
	Game.play_sfx("monster_die", -2.0, 0.05)
	fell_over.emit()
	_play_fall_animation()


func _play_fall_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", 90.0, 0.6) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
