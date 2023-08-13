class_name BreakoutBlock
extends StaticBody2D

signal removed()

enum Value {
	RED = 7,
	ORANGE = 5,
	GREEN = 3,
	YELLOW = 1,
}

@export var speed := 5

@export var max_move_range := 50

@onready var rect := $ColorRect

var pos: Vector2
var value = Value.YELLOW
var move_start
var move_end
var move_to_start = true


func _ready():
	rect.color = _get_value_color()

func _get_value_color():
	match value:
		Value.RED: return Color.RED
		Value.ORANGE: return Color.ORANGE
		Value.GREEN: return Color.GREEN
		Value.YELLOW: return Color.YELLOW

	return Color.WHITE

func _physics_process(delta):
	if move_start == null or move_end == null:
		return
	
	var target = move_start if move_to_start else move_end
	var dir = position.direction_to(target)
	move_local_x(dir.x * speed * delta)
	
	if position.distance_to(move_start) <= 0.1:
		move_to_start = false
	elif position.distance_to(move_end) <= 0.1:
		move_to_start = true

func set_random_move():
	var range = randf_range(0, max_move_range)
	var diff = range / 2
	move_start = position + Vector2(-diff, 0)
	move_end = position + Vector2(diff, 0)

func remove_random_move():
	move_start = null
	move_end = null

func remove_block():
	removed.emit()
	queue_free()
