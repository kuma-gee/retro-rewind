extends Node2D

@onready var camera := $Camera2D
@onready var player := $BreakoutPlayer
@onready var block_spawner := $BreakoutBlockSpawner
@onready var shake := $Camera2D/Shake

var glitches = [
	_camera_rotation_glitch,
	_blocks_glitch,
	_blocks_move_glitch,
]
var last_glitch = null

func random_glitch():
	var glitch = glitches.pick_random()
	while glitch == last_glitch and glitches.size() > 1:
		glitch = glitches.pick_random()
	
	glitch.call()
	last_glitch = glitch

func _blocks_move_glitch():
	block_spawner.glitch_move_blocks()
	get_tree().create_timer(8.0).timeout.connect(func(): GameManager.glitch(func(): block_spawner.reset_blocks(), true))

func _blocks_glitch():
	block_spawner.glitch_blocks()
	get_tree().create_timer(8.0).timeout.connect(func(): GameManager.glitch(func(): block_spawner.reset_blocks(), true))

func _camera_rotation_glitch():
	camera.rotation_degrees = 180
	player.flip_input = true
	get_tree().create_timer(8.0).timeout.connect(func(): GameManager.glitch(func(): _restore_rotation(), true))

func _restore_rotation():
	camera.rotation_degrees = 0
	player.flip_input = false

