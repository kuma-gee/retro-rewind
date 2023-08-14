class_name PacmanMap
extends TileMap

var exclude_pos = [
	Vector2i(0, 8),
	Vector2i(1, 8),
	Vector2i(2, 8),
	Vector2i(0, 12),
	Vector2i(1, 12),
	Vector2i(2, 12),
	Vector2i(18, 8),
	Vector2i(17, 8),
	Vector2i(16, 8),
	Vector2i(18, 12),
	Vector2i(17, 12),
	Vector2i(16, 12),
	Vector2i(8, 10),
	Vector2i(9, 10),
	Vector2i(10, 10),
	Vector2i(9, 9),
]

var ghost_door = Vector2i(9, 9)

func possible_positions():
	var result = []
	var rect = get_used_rect()
	for x in rect.size.x:
		for y in rect.size.y:
			var v = Vector2i(x, y)
			if v in exclude_pos:
				continue
				
			var cell = get_cell_source_id(0, v)
			if cell != -1:
				continue
			
			result.append(v)
	return result

func possible_dir(node_pos: Vector2, is_map = false):
	var result = []
	var pos = local_to_map(node_pos) if not is_map else Vector2i(node_pos)
	for dir in [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]:
		if not _is_wall(pos + dir):
			result.append(dir)
	return result

func do_move(node: Node2D, motion: Vector2i, finish_fn: Callable, speed = 0.2, allow_ghost_door = false, return_tw = false):
	var pos = local_to_map(node.position)
	if motion.x != 0:
		var dest = pos + Vector2i(motion.x, 0)
		if not _is_wall(dest) and (dest != ghost_door or allow_ghost_door):
			return _move(node, dest, finish_fn, speed, return_tw)
			
	if motion.y != 0:
		var dest = pos + Vector2i(0, motion.y)
		if not _is_wall(dest) and (dest != ghost_door or allow_ghost_door):
			return _move(node, dest, finish_fn, speed, return_tw)

func _is_wall(p: Vector2i):
	var cell = get_cell_source_id(0, p)
	return cell != -1

func _move(node: Node2D, dest: Vector2i, finish_fn: Callable, speed = 0.2, return_tw = false):
	var rect = get_used_rect()
	var pos = map_to_local(dest)
	var tw = node.create_tween()
	tw.tween_property(node, "position", pos, speed)
	tw.finished.connect(func():
		if dest.x >= rect.size.x:
			var start = map_to_local(Vector2i(-1, dest.y))
			node.position = start
			
			var other_pos = map_to_local(Vector2i(0, dest.y))
			var tw2 = create_tween()
			tw2.tween_property(node, "position", other_pos, speed)
			await tw2.finished
		elif dest.x <= -1:
			var start = map_to_local(Vector2i(rect.size.x, dest.y))
			node.position = start
			
			var other_pos = map_to_local(Vector2i(rect.size.x - 1, dest.y))
			var tw2 = create_tween()
			tw2.tween_property(node, "position", other_pos, speed)
			await tw2.finished
		
		if node != null and finish_fn:
			finish_fn.call()
	)
	
	if return_tw:
		return [pos, tw]
	
	return pos
