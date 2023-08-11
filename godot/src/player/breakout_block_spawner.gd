extends Marker2D

@export var column := 12
@export var rows := 6

@export var gap := 5
@export var block_width := 40
@export var block_height := 10

@export var block_scene: PackedScene

func _ready():
	for x in column:
		for y in rows:
			_create_block.call_deferred(x, y)

func _create_block(x: int, y: int):
	var block = block_scene.instantiate()
	get_tree().current_scene.add_child(block)
	block.global_position = global_position + Vector2(x * block_width, y * block_height) + Vector2(x * gap, y * gap)
