class_name Ranking
extends Control

@export var loading: Control
@export var grid: GridContainer

func show_scores(scores: Array, current_pos):
	loading.hide()
	for score in scores:
		var pos = score.position
		grid.add_child(_label(str(pos), pos == current_pos))
		grid.add_child(_label(str(score.score), pos == current_pos))
		grid.add_child(_label(score.player_name, pos == current_pos))

func _label(text: String, active: bool):
	var l = Label.new()
	l.text = text
	if active:
		l.modulate = Color.RED
	return l
