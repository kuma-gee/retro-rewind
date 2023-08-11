extends Marker2D

@export var column := 14
@export var rows := 8

@export var gap := 5
@export var block_width := 40
@export var block_height := 10

@export var block_scene: PackedScene

func _ready():
	for y in rows:
		for x in column:
			_create_block.call_deferred(x, y)

func _create_block(x: int, y: int):
	var block = block_scene.instantiate()
	block.value = _get_block_value(y)
	get_tree().current_scene.add_child(block)
	block.global_position = global_position + Vector2(x * block_width, y * block_height) + Vector2(x * gap, y * gap)

func _get_block_value(row: int):
	if row <= 1:
		return BreakoutBlock.Value.RED
	if row <= 3:
		return BreakoutBlock.Value.ORANGE
	if row <= 5:
		return BreakoutBlock.Value.GREEN

	return BreakoutBlock.Value.YELLOW
