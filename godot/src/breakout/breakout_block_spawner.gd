extends Marker2D

@export var column := 12
@export var rows := 8

@export var gap := 5
@export var block_width := 40
@export var block_height := 10

@export var block_scene: PackedScene

@export var min_glitch_offset_x := -5
@export var min_glitch_offset_y := -5
@export var max_glitch_offset_x := 5
@export var max_glitch_offset_y := 5

var positions = {}

func _ready():
	for y in rows:
		for x in column:
			_create_block.call_deferred(x, y)

func _create_block(x: int, y: int):
	var block = block_scene.instantiate()
	block.value = _get_block_value(y)
	add_child(block)
	block.global_position = global_position + Vector2(x * block_width, y * block_height) + Vector2(x * gap, y * gap)
	positions[block] = block.global_position

func _get_block_value(row: int):
	if row <= 1:
		return BreakoutBlock.Value.RED
	if row <= 3:
		return BreakoutBlock.Value.ORANGE
	if row <= 5:
		return BreakoutBlock.Value.GREEN

	return BreakoutBlock.Value.YELLOW

func glitch_blocks():
	for child in get_children():
		child.global_position += Vector2(
			randf_range(min_glitch_offset_x, max_glitch_offset_x),
			randf_range(min_glitch_offset_y, max_glitch_offset_y)
		)

func reset_blocks():
	for child in get_children():
		child.global_position = positions[child]
