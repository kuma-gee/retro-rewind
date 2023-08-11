class_name BreakoutBlock
extends StaticBody2D

enum Value {
	RED = 7,
	ORANGE = 5,
	GREEN = 3,
	YELLOW = 1,
}

@onready var rect := $ColorRect

var value = Value.YELLOW
var score = 1

func _ready():
	rect.color = _get_value_color()

func _get_value_color():
	match value:
		Value.RED: return Color.RED
		Value.ORANGE: return Color.ORANGE
		Value.GREEN: return Color.GREEN
		Value.YELLOW: return Color.YELLOW

	return Color.WHITE

func remove_block():
	queue_free()
