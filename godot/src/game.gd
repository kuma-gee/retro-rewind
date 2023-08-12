extends Control

@export var title: Label
@export var ranking: Ranking

@export var breakout: Node2D
@export var pacman: Node2D

func _ready():
	title.text = get_game_name()
	var game = GameManager.current_game
	breakout.visible = game == GameManager.Game.BREAKOUT
	pacman.visible = game == GameManager.Game.PACMAN
	
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(5).sw_get_scores_complete
	var scores = []
	for i in sw_result.scores.size():
		var s = sw_result.scores[i]
		scores.append({"score": s.score, "player_name": s.player_name, "position": i + 1})
	
	ranking.show_scores(scores, -1)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		GameManager.start_game()


func get_game_name():
	match GameManager.current_game:
		GameManager.Game.BREAKOUT: return "Breakout"
		GameManager.Game.PACMAN: return "Pacman"
	return "Retro Rewind"
