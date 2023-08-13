extends Node2D

@export var powerup_scene: PackedScene
@export var point_scene: PackedScene
@export var pacman_scene: PackedScene
@export var pacman_spawn: Node2D

@export var blinky: PacmanGhost
@export var pinky: PacmanGhost
@export var inky: PacmanGhost
@export var clyde: PacmanGhost

@onready var tilemap: TileMap = $TileMap
@onready var powerup_timer: Timer = $PowerupTimer

var pacman
var pacman_pos

var points = {}
var exclude_pos = [
	Vector2i(0, 8),
	Vector2i(1, 8),
	Vector2i(2, 8),
	Vector2i(0, 12),
	Vector2i(1, 12),
	Vector2i(2, 12),
	Vector2i(18, 8),
	Vector2i(17, 8),
	Vector2i(16, 8),
	Vector2i(18, 12),
	Vector2i(17, 12),
	Vector2i(16, 12),
	Vector2i(8, 10),
	Vector2i(9, 10),
	Vector2i(10, 10),
	Vector2i(9, 9),
]

var powerup_pos = [
	Vector2i(1, 3),
	Vector2i(17, 3),
	Vector2i(1, 16),
	Vector2i(17, 16),
]

func _ready():
	_spawn_points()
	_spawn_pacman.call_deferred()

func _activate_powerup():
	blinky.change_running()
	pinky.change_running()
	inky.change_running()
	clyde.change_running()
	powerup_timer.start()

func _spawn_points():
	var rect = tilemap.get_used_rect()
	var new = points.is_empty()
	for x in rect.size.x:
		for y in rect.size.y:
			var v = Vector2i(x, y)
			if v in exclude_pos:
				continue
			
			var cell = tilemap.get_cell_source_id(0, v)
			if cell == -1 and (new or points.has(v)):
				var scene = powerup_scene if v in powerup_pos else point_scene
				var point = scene.instantiate()
				point.position = tilemap.map_to_local(v)
				point.collected.connect(func():
					points.erase(v)
					if v in powerup_pos:
						_activate_powerup()
					if points.is_empty():
						get_tree().paused = true
						await get_tree().create_timer(1.0).timeout
						_spawn_points()
						get_tree().paused = false
				)
				points[v] = point.position
				tilemap.add_child(point)

func _spawn_pacman():
	pacman = pacman_scene.instantiate()
	pacman.tilemap = tilemap
	pacman.position = pacman_spawn.position if pacman_pos == null else pacman_pos
	pacman.start_invincible = pacman_pos == null
	pacman.died.connect(func():
		pacman = null
		GameManager.lose_health()
		await get_tree().create_timer(1.0).timeout
		_spawn_pacman()
	)
	tilemap.add_child(pacman)

func _process(_delta):
	pacman_pos = pacman.position if pacman else null

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

func random_glitch():
	pass


func _on_powerup_timer_timeout():
	blinky.change_normal()
	pinky.change_normal()
	inky.change_normal()
	clyde.change_normal()
