extends Control

@export var title: Label

func _ready():
	title.text = GameManager.get_game_name()
	
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		GameManager.start_game()
