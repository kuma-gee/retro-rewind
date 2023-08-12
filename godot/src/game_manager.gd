extends Node

enum Game {
	BREAKOUT,
	PACMAN,
}

@export var score_label: Label
@export var screen: Control
@export var hp_container: Control
@export var game_ui: Control
@export var gameover_container: Control
@export var ranking_container: Control
@export var ranking: Ranking
@export var end_score: Label

@onready var health := hp_container.get_child_count() 
var breakout_score := 0
var pacman_score := 0
var current_game := Game.PACMAN

var player_name := ""
var player_position = -1

var waiting_continue := false

func _ready():
	game_ui.hide()
	gameover_container.hide()
	ranking_container.hide()
	
	if Build.SILENT_WOLF_API:
		SilentWolf.configure({
			"api_key": Build.SILENT_WOLF_API,
			"game_id": Build.SILENT_WOLF_GAME,
			"log_level": 1
		})

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		_back_to_start()

func _back_to_start():
	if not waiting_continue: return
	
	game_ui.hide()
	gameover_container.hide()
	ranking_container.hide()
	get_tree().change_scene_to_file("res://src/game.tscn")
	get_tree().paused = false
	waiting_continue = false

func start_game(game = current_game):
	game_ui.visible = game != null
	breakout_score = 0
	pacman_score = 0
	_update_score()
	
	var scene = _game_path(game)
	get_tree().change_scene_to_file(scene)
	current_game = game

func lose_health():
	health -= 1
	for i in hp_container.get_child_count():
		var hp = hp_container.get_child(i)
		hp.visible = i < health
	
	if health < 0:
		get_tree().paused = true
		end_score.text = "Score: " + str(_get_total_score())
		gameover_container.show()

func _on_keyboard_submitted(text):
	gameover_container.hide()
	player_name = text
	
	ranking_container.show()
	
	var total_score = _get_total_score()
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, total_score).sw_save_score_complete
	print("Score persisted successfully: " + str(sw_result.score_id))
	
	var scores_around = await SilentWolf.Scores.get_scores_around(sw_result.score_id, 2).sw_get_scores_around_complete
	
	var scores = []
	scores.append_array(scores_around.scores_above)
	scores.append({"score": total_score, "player_name": player_name, "position": scores_around.position})
	scores.append_array(scores_around.scores_below)
	
	player_position = scores_around.position
	ranking.show_scores(scores, scores_around.position)
	waiting_continue = true
	get_tree().create_timer(10.0).timeout.connect(_back_to_start)

func _get_total_score():
	return breakout_score + pacman_score

func _game_path(game):
	match game:
		Game.BREAKOUT: return "res://src/breakout/breakout_game.tscn"
		Game.PACMAN: return "res://src/pacman/pacman_game.tscn"
	
	return "res://src/game.tscn"

func _update_score():
	score_label.text = str(_get_total_score())

func add_breakout_score(v: int):
	breakout_score += v
	_update_score()
	
func add_pacman_score(v: int):
	pacman_score += v
	_update_score()

func _glitch():
	var mat = screen.material as ShaderMaterial
	mat.set_shader_parameter("enable_glitch", true)

func _on_glitch_timer_timeout():
	_glitch()
