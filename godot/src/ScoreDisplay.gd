extends Label

func _ready():
	var tw = create_tween()
	var dir = Vector2.UP * 10
	var actual = dir.rotated(PI/4)
	
	tw.tween_property(self, "global_position", global_position + actual, 0.5)
	tw.finished.connect(func(): queue_free())
