extends Node2D

@export var point_scene: PackedScene
@export var pacman_scene: PackedScene
@export var pacman_spawn: Node2D

@onready var tilemap: TileMap = $TileMap

func _ready():
	var rect = tilemap.get_used_rect()
	for x in rect.size.x:
		for y in rect.size.y:
			var v = Vector2i(x, y)
			var cell = tilemap.get_cell_source_id(0, v)
			if cell == -1:
				var point = point_scene.instantiate()
				point.position = tilemap.map_to_local(v)
				tilemap.add_child(point)
				
	_spawn_pacman()
				
func _spawn_pacman():
	var pacman = pacman_scene.instantiate()
	pacman.tilemap = tilemap
	pacman.position = pacman_spawn.position
	pacman.died.connect(func():
		GameManager.lose_health()
		_spawn_pacman()
	)
	tilemap.add_child(pacman)
