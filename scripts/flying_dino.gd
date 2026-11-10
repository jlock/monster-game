extends "res://scripts/monster.gd"
## A flying dinosaur. Swoops back and forth across the sky with a gentle bob.
## When defeated it tumbles out of the sky and lands upside down on the grass.

@export var bob_height := 30.0
@export var bob_speed := 2.5
## It turns around when it reaches these x positions.
@export var min_x := 280.0
@export var max_x := 1180.0
## Where it lands when it falls.
@export var ground_y := 620.0

var _dir := -1.0
var _base_y: float
var _t := 0.0


func _ready() -> void:
	super()
	_base_y = position.y
	_t = randf() * TAU  # so several dinos don't bob in sync


func _move(delta: float) -> void:
	_t += delta
	position.x += _dir * walk_speed * delta
	if _dir < 0 and position.x < min_x:
		_dir = 1.0
	elif _dir > 0 and position.x > max_x:
		_dir = -1.0
	position.y = _base_y + sin(_t * bob_speed) * bob_height
	body.scale.x = -_dir  # the drawing faces left


func _play_fall_animation() -> void:
	body.set("flapping", false)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", ground_y, 0.9) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 180.0, 0.6)
	tween.chain().tween_interval(1.0)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(queue_free)
