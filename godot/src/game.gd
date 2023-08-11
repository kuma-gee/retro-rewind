extends Node2D

@export var score_label: Label
@export var screen: Control

func _ready():
	score_label.text = "0"

func _on_breakout_player_update_score(score):
	score_label.text = str(score)

func _glitch():
	var mat = screen.material as ShaderMaterial
	mat.set_shader_parameter("enable_glitch", true)
