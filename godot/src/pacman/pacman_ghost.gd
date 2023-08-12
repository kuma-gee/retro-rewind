extends CharacterBody2D

@export var move = false
@export var tilemap: PacmanMap
@export var fleeing = false

var moving
var local_paths = []
var return_dir

var flee_threshold = 0.005

func _process(delta):
	if not move:
		return
	
	if moving != null:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var path = NavigationServer2D.map_get_path(get_world_2d().navigation_map, global_position, player.global_position, false)
		if path.size() > 1:
			local_paths = []
			for p in path:
				var l = to_local(p)
				local_paths.append(l)
				
			var dir = local_paths[1].normalized()
			var rounded = Vector2i(round(dir.x), round(dir.y))
			
			if fleeing:
				var dirs = tilemap.possible_dir(self)
				
				var player_dir = position.direction_to(player.position)
				var possible_dirs = dirs.filter(func(d): return d != return_dir).map(func(d): return {"dir": d, "dot": Vector2(d).dot(player_dir)})
				
				if possible_dirs.size() > 0:
					possible_dirs.sort_custom(func(a, b): return a.dot < b.dot)
					
					var smallest_dot = possible_dirs[0].dot
					var similar_dirs = possible_dirs.filter(func(d): return d.dot - smallest_dot < flee_threshold)
						
					rounded = similar_dirs.pick_random().dir
			
			moving = tilemap.do_move(self, rounded, func(): moving = null, 0.25)
			return_dir = -rounded
			
			queue_redraw()

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
