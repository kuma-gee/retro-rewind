extends CharacterBody2D

@export var move = false
@export var tilemap: TileMap

var moving
var local_paths = []

func _process(delta):
	if not move:
		return
	
	if moving != null:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	var path = NavigationServer2D.map_get_path(get_world_2d().navigation_map, global_position, player.global_position, false)
	if path.size() > 1:
		local_paths = []
		for p in path:
			var l = to_local(p)
			local_paths.append(l)
			
		var dir = local_paths[1].normalized()
		var rounded = Vector2i(round(dir.x), round(dir.y))
		moving = tilemap.do_move(self, rounded, func(): moving = null, 0.25)
		queue_redraw()

func _draw():
	if local_paths.size() > 0:
		var start = local_paths[0]
		for i in range(1, local_paths.size()):
			var end = local_paths[i]
			draw_line(start, end, Color.RED, 2)
			start = end
