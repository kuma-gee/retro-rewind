extends Node2D

@export var powerup_scene: PackedScene
@export var point_scene: PackedScene
@export var pacman_scene: PackedScene
@export var pacman_spawn: Node2D

@export var score_scene: PackedScene

@export var blinky: PacmanGhost
@export var pinky: PacmanGhost
@export var inky: PacmanGhost
@export var clyde: PacmanGhost

@onready var camera := $Camera2D
@onready var tilemap: TileMap = $TileMap
@onready var release_timer: Timer = $ReleaseGhostTimer
@onready var powerup_timer: Timer = $PowerupTimer
@onready var death_sound := $DeathSound
@onready var shake := $Camera2D/Shake

var pacman
var pacman_pos
var powerup_timeleft := 0.0
var blink_called = true
var flipped = false
var ghost_combo = 1

var points = {}

var powerup_pos = [
	Vector2i(1, 3),
	Vector2i(17, 3),
	Vector2i(1, 16),
	Vector2i(17, 16),
]

var glitches = [
	_move_points,
	_shuffle_points,
	_rotate_camera
]
var last_glitch = null

func _ready():
	_spawn_points()
	_spawn_pacman.call_deferred()
	
	if powerup_timeleft > 0:
		powerup_timer.start(powerup_timeleft)
	
	if not blinky.move:
		get_tree().create_timer(1.0).timeout.connect(func(): blinky.move = true)

func random_glitch():
	var glitch = glitches.pick_random()
	while glitch == last_glitch and glitches.size() > 1:
		glitch = glitches.pick_random()
	
	glitch.call()
	last_glitch = glitch

func _rotate_camera():
	flipped = true
	camera.rotation_degrees = 180
	if pacman:
		pacman.flip_input = flipped
	get_tree().create_timer(8.0).timeout.connect(func(): 
		GameManager.glitch(func():
			camera.rotation_degrees = 0
			flipped = false
			if pacman:
				pacman.flip_input = flipped
		, true)
	)

func _move_points():
	for child in tilemap.get_children():
		if not child is PacmanPoint:
			continue
		child.enable_move = true
	get_tree().create_timer(8.0).timeout.connect(func(): GameManager.glitch(func(): _restore_points(), true))

func _shuffle_points():
	var positions = tilemap.possible_positions()
	
	for child in tilemap.get_children():
		if not child is PacmanPoint:
			continue
		
		var pos = positions.pick_random()
		positions.erase(pos)
		
		child.position = tilemap.map_to_local(pos)
	
	get_tree().create_timer(8.0).timeout.connect(func(): GameManager.glitch(func(): _restore_points(), true))

func _restore_points():
	for child in tilemap.get_children():
		if not child is PacmanPoint:
			continue
		
		child.restore()
		if points.has(child.pos):
			child.position = points[child.pos]

func _process(_delta):
	powerup_timeleft = powerup_timer.time_left
	pacman_pos = pacman.position if pacman else null
	
	if powerup_timeleft > 0 and powerup_timeleft < 2.0 and not blink_called:
		blinky.blink()
		pinky.blink()
		inky.blink()
		clyde.blink()
		blink_called = true
		

func _activate_powerup():
	blinky.change_running()
	pinky.change_running()
	inky.change_running()
	clyde.change_running()
	powerup_timer.start()
	blink_called = false

func _on_powerup_timer_timeout():
	blinky.change_normal()
	pinky.change_normal()
	inky.change_normal()
	clyde.change_normal()
	ghost_combo = 1


func _spawn_points():
	var positions = tilemap.possible_positions()
	var new = points.is_empty()
	for v in positions:
		if (new or points.has(v)):
			var scene = powerup_scene if v in powerup_pos else point_scene
			var point = scene.instantiate()
			point.pos = v
			point.tilemap = tilemap
			point.position = tilemap.map_to_local(v)
			point.collected.connect(func():
				points.erase(v)
				if v in powerup_pos:
					_activate_powerup()
				if points.is_empty():
					SoundManager.cleared()
					get_tree().paused = true
					await get_tree().create_timer(1.0).timeout
					_spawn_points()
					_respawn_characters()
					get_tree().paused = false
			)
			points[v] = point.position
			tilemap.add_child(point)

func _spawn_pacman():
	if pacman:
		pacman.queue_free()
		pacman_pos = null
	
	pacman = pacman_scene.instantiate()
	pacman.tilemap = tilemap
	pacman.position = pacman_spawn.position if pacman_pos == null else pacman_pos
	pacman.start_invincible = pacman_pos == null
	pacman.flip_input = flipped
	pacman.caught_ghost.connect(func(pos):
		var score = 100 * ghost_combo
		GameManager.add_pacman_score(score)
		ghost_combo += 1
		
		var score_label = score_scene.instantiate()
		score_label.text = str(score)
		score_label.global_position = pos
		get_tree().current_scene.add_child(score_label)
	)
	pacman.died.connect(func():
		if pacman:
			pacman = null
			shake.shake()
			death_sound.play()
			GameManager.lose_health()
			await get_tree().create_timer(1.0).timeout
			_respawn_characters()
	)
	tilemap.add_child(pacman)

func _respawn_characters():
	_spawn_pacman()
	blinky.reset_position()
	pinky.reset_position()
	inky.reset_position()
	clyde.reset_position()
	release_timer.start()
	
	await get_tree().create_timer(2.0).timeout
	blinky.move = true
	release_timer.start()

func _on_release_ghost_timer_timeout():
	if not pinky.move:
		pinky.move = true
		return
	if not clyde.move:
		clyde.move = true
		return
	if not inky.move:
		inky.move = true
		return
