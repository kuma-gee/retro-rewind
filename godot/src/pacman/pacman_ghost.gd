class_name PacmanGhost
extends CharacterBody2D

@export var move = false : set = _set_move
@export var tilemap: PacmanMap
@export var fleeing = false
@export var look_ahead = 0

var moving
var local_paths = []
var return_dir = Vector2i.ZERO

var flee_threshold = 0.01
var speed = 0.25

func _set_move(m):
	move = m

func _process(delta):
	if not move:
		return
	
	if moving != null:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and not player.collision.disabled:
		var pac = player as Pacman
		var target = pac.global_position
		
		for d in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			print("%s = %s" % [d, tilemap.map_to_local(d)])
		
		if look_ahead > 0:
			var ahead = _get_ahead_dir(pac.position, pac.motion)
			if ahead:
				target += tilemap.map_to_local(ahead)
		
		var path = NavigationServer2D.map_get_path(get_world_2d().navigation_map, global_position, target, false)
		if path.size() > 1:
			local_paths = []
			for p in path:
				var l = to_local(p)
				local_paths.append(l)
			
			var rounded = return_dir
			for p in local_paths:
				var dir = p.normalized()
				rounded = Vector2i(round(dir.x), round(dir.y))
				
				if fleeing:
					var flee_dir = _get_fleeing_dir(pac)
					if flee_dir:
						rounded = flee_dir
				
				if rounded != return_dir:
					break
			
			if rounded != return_dir:
				_move(rounded)
				queue_redraw()
				return
	
	# Default roaming
	var dirs = _possible_dirs()
	var random_dir = dirs.pick_random()
	if random_dir:
		_move(random_dir)
	else:
		print("Could not find a direction to move")

func _get_ahead_dir(node_pos: Vector2, motion: Vector2i):
	var start = tilemap.local_to_map(node_pos)
	var possible_moves = tilemap.possible_dir(node_pos)
	var ahead_dir = Vector2i.ZERO
	
	for i in look_ahead:
		if possible_moves.size() == 0:
			break
		
		var largest_dot = 0
		var largest = null
		
		for d in possible_moves:
			var dot = Vector2(d).dot(motion)
			if dot > largest_dot:
				largest_dot = dot
				largest = d
		
		ahead_dir += largest if largest != null else possible_moves.pick_random()
		possible_moves = tilemap.possible_dir(start + ahead_dir, true)
	
	return ahead_dir

func _get_fleeing_dir(pacman: Pacman):
	var dirs = _possible_dirs()
	var player_dir = position.direction_to(pacman.position)
	var possible_dirs = dirs.map(func(d): return {"dir": d, "dot": Vector2(d).dot(player_dir)})
	
	if possible_dirs.size() > 0:
		possible_dirs.sort_custom(func(a, b): return a.dot < b.dot)
		
		var smallest_dot = possible_dirs[0].dot
		var similar_dirs = possible_dirs.filter(func(d): return d.dot - smallest_dot < flee_threshold)
			
		return similar_dirs.pick_random().dir
	return null

func _possible_dirs():
	return tilemap.possible_dir(position).filter(func(d): return return_dir == null or Vector2(d) != Vector2(return_dir))

func _move(dir):
	moving = tilemap.do_move(self, dir, func(): moving = null, speed)
	return_dir = -dir

func _draw():
	if local_paths.size() > 0:
		var start = local_paths[0]
		for i in range(1, local_paths.size()):
			var end = local_paths[i]
			draw_line(start, end, Color.RED, 2)
			start = end


func _on_area_2d_body_entered(body):
	if body is Pacman:
		body.killed()
