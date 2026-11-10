extends Node
## Global game state, loaded as the "Game" autoload.
## Holds the score and plays music and sound effects from anywhere: Game.play_sfx("hit")

signal score_changed(score: int)

const MUSIC := preload("res://assets/audio/music.wav")
const SOUNDS := {
	"hit": preload("res://assets/audio/hit.wav"),
	"throw": preload("res://assets/audio/throw.wav"),
	"fireball_cast": preload("res://assets/audio/fireball_cast.wav"),
	"monster_die": preload("res://assets/audio/monster_die.wav"),
	"explosion": preload("res://assets/audio/explosion.wav"),
}
## How many sound effects can play at the same time.
const SFX_VOICES := 12

@export var music_volume_db := -10.0

var score := 0

var _music: AudioStreamPlayer
var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music = AudioStreamPlayer.new()
	_music.stream = MUSIC
	_music.volume_db = music_volume_db
	_music.finished.connect(_music.play)  # loop forever
	add_child(_music)
	_music.play()

	for i in SFX_VOICES:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func reset_score() -> void:
	score = 0
	score_changed.emit(score)


## Plays a sound by name. Pitch wobbles a little so repeated sounds don't get boring.
func play_sfx(sound: String, volume_db := 0.0, pitch_variation := 0.1) -> void:
	if not SOUNDS.has(sound):
		push_warning("Unknown sound: %s" % sound)
		return
	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stream = SOUNDS[sound]
	voice.volume_db = volume_db
	voice.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	voice.play()
