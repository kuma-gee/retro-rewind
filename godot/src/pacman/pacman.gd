extends CharacterBody2D

@export var tilemap: TileMap

@onready var input: PlayerInput = $Input

var moving
var score = 0

func _physics_process(delta):
	if moving != null:
		var dir = position.direction_to(moving)
		var angle = dir.angle_to(Vector2.RIGHT)
		rotation_degrees = round(rad_to_deg(angle))
		if abs(rotation_degrees) == 90:
			rotation_degrees *= -1
		return
	
	var motion_x = ceil(input.get_action_strength("move_right")) - ceil(input.get_action_strength("move_left"))
	var motion_y = ceil(input.get_action_strength("move_down")) - ceil(input.get_action_strength("move_up"))
	
	var pos = tilemap.local_to_map(position)
	if motion_x != 0:
		var dest = pos + Vector2i(motion_x, 0)
		if not _is_wall(dest):
			_move(dest)
			return
			
	if motion_y != 0:
		var dest = pos + Vector2i(0, motion_y)
		if not _is_wall(dest):
			_move(dest)
			return

func _is_wall(p: Vector2i):
	var cell = tilemap.get_cell_source_id(0, p)
	return cell != -1

func _move(dest: Vector2i):
	var rect = tilemap.get_used_rect()
	var pos = tilemap.map_to_local(dest)
	moving = pos
	var tw = create_tween()
	tw.tween_property(self, "position", pos, 0.2)#.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func():
		if dest.x >= rect.size.x:
			var start = tilemap.map_to_local(Vector2i(-1, dest.y))
			position = start
			
			var other_pos = tilemap.map_to_local(Vector2i(0, dest.y))
			var tw2 = create_tween()
			tw2.tween_property(self, "position", other_pos, 0.2)
			tw2.finished.connect(func(): moving = null)
		elif dest.x <= -1:
			var start = tilemap.map_to_local(Vector2i(rect.size.x, dest.y))
			position = start
			
			var other_pos = tilemap.map_to_local(Vector2i(rect.size.x - 1, dest.y))
			var tw2 = create_tween()
			tw2.tween_property(self, "position", other_pos, 0.2)
			tw2.finished.connect(func(): moving = null)
		else:
			moving = null
	)


func _on_area_2d_area_entered(area):
	area.queue_free()
	score += 1
