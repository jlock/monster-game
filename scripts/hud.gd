extends CanvasLayer
## Shows the score (a star and a number) in the top-left corner.

@onready var score_label: Label = $ScoreLabel
@onready var star: Polygon2D = $Star


func _ready() -> void:
	Game.score_changed.connect(_on_score_changed)
	score_label.text = str(Game.score)


func _on_score_changed(score: int) -> void:
	score_label.text = str(score)
	# Little celebration pop on the star.
	star.scale = Vector2(1.6, 1.6)
	star.rotation = -0.5
	var tween := create_tween().set_parallel()
	tween.tween_property(star, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(star, "rotation", 0.0, 0.35)
