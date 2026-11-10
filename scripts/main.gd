extends Node2D
## The single game screen.
## Left click / tap: throw a rock. Right click: fireball (has a cooldown).
## Monsters keep spawning from the right, up to max_monsters at a time.

const ROCK_SCENE := preload("res://scenes/rock.tscn")
const FIREBALL_SCENE := preload("res://scenes/fireball.tscn")
const MONSTER_SCENE := preload("res://scenes/monster.tscn")
const FLYING_DINO_SCENE := preload("res://scenes/flying_dino.tscn")

const MONSTER_COLORS: Array[Color] = [
	Color(0.55, 0.3, 0.8),   # purple
	Color(0.9, 0.35, 0.45),  # pink-red
	Color(0.25, 0.55, 0.9),  # blue
	Color(0.95, 0.7, 0.2),   # yellow
	Color(0.3, 0.7, 0.6),    # teal
]

## Most monsters that can be on screen at once.
@export var max_monsters := 4
## Seconds between spawn attempts.
@export var spawn_interval := 2.0
## Chance (0-1) that a new monster is a flying dinosaur.
@export_range(0.0, 1.0) var flying_chance := 0.3
## Seconds before the fireball can be used again.
@export var fireball_cooldown := 4.0

var _fireball_wait := 0.0
var _spawn_wait := 0.0

@onready var thrower: Node2D = $Thrower
@onready var rocks: Node2D = $Rocks
@onready var monsters: Node2D = $Monsters
@onready var cooldown_ring: Node2D = $Thrower/CooldownRing


func _ready() -> void:
	Game.reset_score()


func _process(delta: float) -> void:
	if _fireball_wait > 0.0:
		_fireball_wait = maxf(_fireball_wait - delta, 0.0)
		cooldown_ring.progress = 1.0 - _fireball_wait / fireball_cooldown

	_spawn_wait -= delta
	if _spawn_wait <= 0.0:
		_spawn_wait = spawn_interval
		if get_tree().get_nodes_in_group("monsters").size() < max_monsters:
			spawn_monster()


func _unhandled_input(event: InputEvent) -> void:
	# Taps on touch screens arrive as left clicks, so they throw rocks.
	if event.is_action_pressed("throw_rock"):
		throw_rock(get_global_mouse_position())
	elif event.is_action_pressed("fireball"):
		cast_fireball(get_global_mouse_position())


func throw_rock(target: Vector2) -> void:
	var rock := ROCK_SCENE.instantiate()
	rock.global_position = thrower.global_position
	rock.direction = (target - thrower.global_position).normalized()
	rocks.add_child(rock)
	Game.play_sfx("throw", -4.0, 0.2)


func cast_fireball(target: Vector2) -> void:
	if _fireball_wait > 0.0:
		return
	_fireball_wait = fireball_cooldown
	cooldown_ring.progress = 0.0
	var fireball := FIREBALL_SCENE.instantiate()
	fireball.global_position = thrower.global_position
	fireball.target = target
	rocks.add_child(fireball)
	Game.play_sfx("fireball_cast")


func spawn_monster() -> void:
	var monster: Node2D
	if randf() < flying_chance:
		monster = FLYING_DINO_SCENE.instantiate()
		monster.position = Vector2(1350, randf_range(110, 320))
	else:
		monster = MONSTER_SCENE.instantiate()
		# Start just off the right edge, somewhere on the grass.
		monster.position = Vector2(1340, randf_range(540, 690))
		monster.stop_x = randf_range(230, 420)
		monster.walk_speed = randf_range(30, 60)
		monster.body_color = MONSTER_COLORS.pick_random()
	monsters.add_child(monster)
