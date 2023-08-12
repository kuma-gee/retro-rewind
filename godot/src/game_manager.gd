extends Node

@export var score_label: Label
@export var screen: Control

var breakout_score := 0
var pacman_score := 0

func _ready():
	_update_score()
	
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
