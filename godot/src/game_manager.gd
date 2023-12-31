extends Node

enum Game {
	BREAKOUT,
	PACMAN,
}

@export var game_switch_chance := 0.1

@export var score_label: Label
@export var screen: Control
@export var hp_container: Control
@export var game_ui: Control
@export var gameover_container: Control

@export var ranking_container: Control
@export var ranking_focus: Control
@export var ranking: Ranking

@export var end_score: Label
@export var credits: Control
@export var credits_focus: Control

@onready var back_timer := $BackTimer
@onready var frame_freeze := $FrameFreeze
@onready var glitch_timer := $GlitchTimer
@onready var glitch_sound := $GlitchSound
@onready var lose_sound := $LoseSound
@onready var bgm := $BGM

var health := 0 : set = _set_health 

var breakout_score := 0
var pacman_score := 0
var current_game := Game.BREAKOUT

var player_name := ""
var player_position = -1

var gameover := false
var glitch_tween
var glitch_count = 0

func _ready():
	_show_only()
	
	if Build.SILENT_WOLF_API:
		SilentWolf.configure({
			"api_key": Build.SILENT_WOLF_API,
			"game_id": Build.SILENT_WOLF_GAME,
			"log_level": 0
		})

func _set_health(hp):
	health = hp
	for i in hp_container.get_child_count():
		var node = hp_container.get_child(i)
		node.visible = i < health

#func _unhandled_input(event):

func freeze():
	frame_freeze.freeze(0.01, 1.5)

func _back_to_start():
	back_timer.stop()
	
	var tw = create_tween()
	tw.tween_property(bgm, "volume_db", -10, 1.0)
	gameover = false
	_show_only()
	get_tree().change_scene_to_file("res://src/game.tscn")
	get_tree().paused = false
	CacheManager.clear()

func _show_only(node = null):
	game_ui.visible = node == game_ui
	gameover_container.visible = node == gameover_container
	
	ranking_container.visible = node == ranking_container
	if ranking_container.visible:
		ranking_focus.grab_focus()
	
	credits.visible = node == credits
	if credits.visible:
		credits_focus.grab_focus()

func start_game():
	var tw = create_tween()
	tw.tween_property(bgm, "volume_db", -20, 1.0)

	_show_only(game_ui)
	breakout_score = 0
	pacman_score = 0
	glitch_count = 0
	self.health = hp_container.get_child_count()
	
	_update_score()
	_change_game(current_game, false)
	

func _change_game(game, save = true):
	if save:
		CacheManager.save_scene()
		
	var scene = _game_path(game)
	get_tree().change_scene_to_file(scene)
	current_game = game
	glitch_timer.start()

func lose_health(do_freeze = true):
	self.health -= 1
	
	if do_freeze:
		freeze()
	if health < 0:
		get_tree().paused = true
		gameover = true
		end_score.text = "Score: " + str(_get_total_score())
		_show_only(gameover_container)
		lose_sound.play()
		_reset_glitch()
		if glitch_tween:
			glitch_tween.kill()

func _on_keyboard_submitted(text):
	if text == "":
		_on_ranking_continue_pressed()
		return
	
	_show_only(ranking_container)
	
	player_name = text
	ranking.loading_data()
	
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
		
		glitch_sound.stop()
		var wait_time = callback.call()
		_reset_glitch()
		get_tree().paused = true
		await get_tree().create_timer(wait_time if wait_time else 1.0).timeout
		get_tree().paused = false
		if start_timer:
			glitch_timer.start()
	)

func _reset_glitch():
	var mat = screen.material as ShaderMaterial
	mat.set_shader_parameter("enable_glitch", false)
	mat.set_shader_parameter("glitch_time", 0.5)
	glitch_sound.playing = false

func _set_glitch_time(time: float):
	var mat = screen.material as ShaderMaterial
	mat.set_shader_parameter("enable_glitch", true)
	mat.set_shader_parameter("glitch_time", time)
	
	var playing = int(floor(time)) % 2 == 1
	if glitch_sound.playing != playing:
		glitch_sound.playing = playing
	

func _on_glitch_timer_timeout():
	glitch(func():
		if randf() <= game_switch_chance * glitch_count:
			var games = []
			for g in Game.values():
				if g != current_game:
					games.append(g)
			_change_game(games.pick_random())
			glitch_count = 1 # allow small chance to immediately change change
			return 1.0
		else:
			get_tree().current_scene.random_glitch()
			glitch_count += 1
	)


func _on_continue_pressed():
	_back_to_start()


func _on_ranking_continue_pressed():
	_show_only(credits)
	back_timer.start()


func _on_back_timer_timeout():
	_back_to_start()
