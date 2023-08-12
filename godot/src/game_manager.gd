extends Node

@export var score_label: Label
@export var screen: Control

@export var game_ui: Control

var breakout_score := 0
var pacman_score := 0

func _ready():
	game_ui.hide()
	_update_score()
	
	if Build.SILENT_WOLF_API:
		SilentWolf.configure({
			"api_key": Build.SILENT_WOLF_API,
			"game_id": Build.SILENT_WOLF_GAME,
			"log_level": 1
		})

		SilentWolf.configure_scores({
			"open_scene_on_close": "res://scenes/MainPage.tscn"
		})

func start_game():
	game_ui.show()
	get_tree().change_scene_to_file("res://src/breakout/breakout_game.tscn")

func _update_score():
	score_label.text = str(breakout_score)

func add_breakout_score(v: int):
	breakout_score += v
	_update_score()

func _glitch():
	var mat = screen.material as ShaderMaterial
	mat.set_shader_parameter("enable_glitch", true)

func _on_glitch_timer_timeout():
	_glitch()
