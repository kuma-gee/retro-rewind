class_name PacmanMap
extends TileMap

func possible_dir(node_pos: Vector2, is_map = false):
	var result = []
	var pos = local_to_map(node_pos) if not is_map else Vector2i(node_pos)
	for dir in [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]:
		if not _is_wall(pos + dir):
			result.append(dir)
	return result

func do_move(node: Node2D, motion: Vector2i, finish_fn: Callable, speed = 0.2):
	var pos = local_to_map(node.position)
	if motion.x != 0:
		var dest = pos + Vector2i(motion.x, 0)
		if not _is_wall(dest):
			return _move(node, dest, finish_fn, speed)
			
	if motion.y != 0:
		var dest = pos + Vector2i(0, motion.y)
		if not _is_wall(dest):
			return _move(node, dest, finish_fn, speed)

func _is_wall(p: Vector2i):
	var cell = get_cell_source_id(0, p)
	return cell != -1

func _move(node: Node2D, dest: Vector2i, finish_fn: Callable, speed = 0.2):
	var rect = get_used_rect()
	var pos = map_to_local(dest)
	var tw = create_tween()
	tw.tween_property(node, "position", pos, speed)
	tw.finished.connect(func():
		if dest.x >= rect.size.x:
			var start = map_to_local(Vector2i(-1, dest.y))
			node.position = start
			
			var other_pos = map_to_local(Vector2i(0, dest.y))
			var tw2 = create_tween()
			tw2.tween_property(node, "position", other_pos, speed)
			tw2.finished.connect(finish_fn)
		elif dest.x <= -1:
			var start = map_to_local(Vector2i(rect.size.x, dest.y))
			node.position = start
			
			var other_pos = map_to_local(Vector2i(rect.size.x - 1, dest.y))
			var tw2 = create_tween()
			tw2.tween_property(node, "position", other_pos, speed)
			tw2.finished.connect(finish_fn)
		else:
			finish_fn.call()
	)
	return pos
