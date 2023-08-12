extends Node

enum Game {
	BREAKOUT,
	PACMAN,
}

@export var score_label: Label
@export var screen: Control

@export var game_ui: Control

var breakout_score := 0
var pacman_score := 0
var current_game = Game.BREAKOUT

func _ready():
	game_ui.hide()
	
	if Build.SILENT_WOLF_API:
		SilentWolf.configure({
			"api_key": Build.SILENT_WOLF_API,
			"game_id": Build.SILENT_WOLF_GAME,
			"log_level": 1
		})

func start_game(game = current_game):
	game_ui.visible = game != null
	breakout_score = 0
	pacman_score = 0
	_update_score()
	
	var scene = _game_path(game)
	get_tree().change_scene_to_file(scene)
	current_game = game
	

func _game_path(game):
	match game:
		Game.BREAKOUT: return "res://src/breakout/breakout_game.tscn"
		Game.PACMAN: return "res://src/pacman/pacman_game.tscn"
	
	return "res://src/game.tscn"

func get_game_name():
	match current_game:
		Game.BREAKOUT: return "Breakout"
		Game.PACMAN: return "Pacman"
	return "Retro Rewind"

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
