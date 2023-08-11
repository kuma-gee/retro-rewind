extends Node2D

@export var score_label: Label

func _ready():
	score_label.text = "0"

func _on_breakout_player_update_score(score):
	score_label.text = str(score)
