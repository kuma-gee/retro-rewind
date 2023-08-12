extends Node2D

@export var point_scene: PackedScene

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
