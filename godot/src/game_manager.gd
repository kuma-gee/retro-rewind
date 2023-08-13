extends Node

enum Game {
	BREAKOUT,
	PACMAN,
}

@export var game_switch_chance := 0.2

@export var score_label: Label
@export var screen: Control
@export var hp_container: Control
@export var game_ui: Control
@export var gameover_container: Control
@export var ranking_container: Control
@export var ranking: Ranking
@export var end_score: Label

@onready var glitch_timer := $GlitchTimer
@onready var health := hp_container.get_child_count() 

var breakout_score := 0
var pacman_score := 0
var current_game := Game.BREAKOUT

var player_name := ""
var player_position = -1

var waiting_continue := false
var gameover := false
var glitch_tween

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
	
	gameover = false
	game_ui.hide()
	gameover_container.hide()
	ranking_container.hide()
	get_tree().change_scene_to_file("res://src/game.tscn")
	get_tree().paused = false
	waiting_continue = false
	CacheManager.clear()

func start_game(game = current_game):
	game_ui.visible = game != null
	breakout_score = 0
	pacman_score = 0
	_update_score()
	_change_game(game, false)
	

func _change_game(game, save = true):
	if save:
		CacheManager.save_scene()
		
	var scene = _game_path(game)
	get_tree().change_scene_to_file(scene)
	current_game = game
	glitch_timer.start()

func lose_health():
	health -= 1
	for i in hp_container.get_child_count():
		var hp = hp_container.get_child(i)
		hp.visible = i < health
	
	if health < 0:
		get_tree().paused = true
		gameover = true
		end_score.text = "Score: " + str(_get_total_score())
		gameover_container.show()
		if glitch_tween:
			glitch_tween.kill()

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

func glitch(callback: Callable, start_timer = false):
	if gameover: return
	
	glitch_tween = create_tween()
	glitch_tween.tween_method(_set_glitch_time, 0.5, 5.0, 3.0)
	glitch_tween.finished.connect(func():
		if gameover: return
		
		var wait_time = callback.call()
		var mat = screen.material as ShaderMaterial
		mat.set_shader_parameter("enable_glitch", false)
		mat.set_shader_parameter("glitch_time", 0.5)
		get_tree().paused = true
		await get_tree().create_timer(wait_time if wait_time else 0.5).timeout
		get_tree().paused = false
		if start_timer:
			glitch_timer.start()
	)

func _set_glitch_time(time):
	var mat = screen.material as ShaderMaterial
	mat.set_shader_parameter("enable_glitch", true)
	mat.set_shader_parameter("glitch_time", time)
	

func _on_glitch_timer_timeout():
	glitch(func():
		if randf() <= game_switch_chance:
			var games = []
			for g in Game.values():
				if g != current_game:
					games.append(g)
			_change_game(games.pick_random())
			return 1.0
		else:
			get_tree().current_scene.random_glitch()
	)
