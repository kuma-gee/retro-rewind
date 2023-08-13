extends Node2D

@export var point_scene: PackedScene
@export var pacman_scene: PackedScene
@export var pacman_spawn: Node2D

@export var pinky: PacmanGhost
@export var inky: PacmanGhost
@export var clyde: PacmanGhost

@onready var tilemap: TileMap = $TileMap

var pacman
var pacman_pos

var points = {}

func _ready():
	var rect = tilemap.get_used_rect()
	var new = points.is_empty()
	for x in rect.size.x:
		for y in rect.size.y:
			var v = Vector2i(x, y)
			var cell = tilemap.get_cell_source_id(0, v)
			if cell == -1 and (new or points.has(v)):
				var point = point_scene.instantiate()
				point.position = tilemap.map_to_local(v)
				point.collected.connect(func(): points.erase(v))
				points[v] = point.position
				tilemap.add_child(point)

	_spawn_pacman.call_deferred()

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
