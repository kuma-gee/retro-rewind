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
	_create_blocks()

func _create_blocks():
	for y in rows:
		for x in column:
			if positions.is_empty() or positions.has(Vector2(x, y)):
				_create_block.call_deferred(x, y)


func _create_block(x: int, y: int):
	var block = block_scene.instantiate()
	block.value = _get_block_value(y)
	add_child(block)
	
	var pos = Vector2(x, y)
	block.pos = pos
	block.removed.connect(func():
		positions.erase(pos)
		if positions.is_empty():
			get_tree().paused = true
			await get_tree().create_timer(1.0).timeout
			_create_blocks()
			get_tree().paused = false
	)
	if positions.has(pos):
		block.global_position = positions[pos]
	else:
		block.global_position = global_position + Vector2(x * block_width, y * block_height) + Vector2(x * gap, y * gap)
		positions[pos] = block.global_position

func _get_block_value(row: int):
	if row <= 1:
		return BreakoutBlock.Value.RED
	if row <= 3:
		return BreakoutBlock.Value.ORANGE
	if row <= 5:
		return BreakoutBlock.Value.GREEN

	return BreakoutBlock.Value.YELLOW

func glitch_move_blocks():
	for child in get_children():
		if child is BreakoutBlock:
			child.set_random_move()

func glitch_blocks():
	for child in get_children():
		if child is BreakoutBlock:
			child.global_position += Vector2(
				randf_range(min_glitch_offset_x, max_glitch_offset_x),
				randf_range(min_glitch_offset_y, max_glitch_offset_y)
			)

func reset_blocks():
	for child in get_children():
		if child is BreakoutBlock:
			child.remove_random_move()
			child.global_position = positions[child.pos]
