class_name PacmanGhost
extends CharacterBody2D

@export var spawn_pos: Node2D
@export var move = false : set = _set_move
@export var tilemap: PacmanMap
@export var fleeing = false
@export var look_ahead = 0

@onready var pupil_left := $EyeLeft/Pupil
@onready var pupil_right := $EyeRight/Pupil

@onready var respawn_timer := $RespawnTimer
@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D
@onready var orig_modulate = sprite.modulate

var current_modulate = null
var moving
var local_paths = []
var return_dir = Vector2i.ZERO

var flee_threshold = 0.01
var speed = 0.25
var catchable = false : set = _set_catchable

var return_spawn = false
var respawn_time_left := 0.0

var blink_tw: Tween

func _ready():
	collision.disabled = true
	if current_modulate == null:
		current_modulate = orig_modulate
	
	sprite.modulate = current_modulate
	
	if respawn_time_left > 0:
		respawn_timer.start(respawn_time_left)

func _set_catchable(c):
	catchable = c
	_stop_blink()
	
	if catchable:
		fleeing = true
		current_modulate = Color.from_string("1b39bf", Color.BLUE)
		if return_spawn:
			current_modulate = Color.TRANSPARENT
	else:
		catchable = false
		fleeing = false
		current_modulate = orig_modulate

func blink():
	if catchable and not return_spawn:
		_do_blink()

func _do_blink():
	_stop_blink()
	blink_tw = create_tween()
	blink_tw.set_loops()
	blink_tw.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	blink_tw.tween_property(self, "modulate", Color.WHITE, 0.5)
	
func _set_move(m):
	move = m

func change_running():
	self.catchable = true
	
func change_normal():
	if catchable and not return_spawn:
		self.catchable = false

func caught():
	return_spawn = true
	current_modulate = Color.TRANSPARENT

func _stop_blink():
	if blink_tw:
		blink_tw.kill()
		blink_tw = null
	modulate = Color.WHITE

func _get_target():
	if return_spawn:
		return [spawn_pos.global_position, null]
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null or player.collision.disabled:
		return [null, null]
	
	var pac = player as Pacman
	var target = pac.global_position
	
	if look_ahead > 0:
		var ahead = _get_ahead_dir(pac.position, pac.motion)
		if ahead:
			target += tilemap.map_to_local(ahead)
	return [target, pac]
	
func _process(_delta):
	sprite.modulate = current_modulate
	collision.disabled = not catchable
	respawn_time_left = respawn_timer.time_left
	if not catchable:
		modulate = Color.WHITE
		
	if respawn_time_left > 0 and respawn_time_left < 2.0 and (blink_tw == null or not blink_tw.is_running()):
		_do_blink()
	
	if not move:
		return
	
	if moving != null:
		var dir = position.direction_to(moving)
		pupil_left.position = dir
		pupil_right.position = dir
		return
	
	var result = _get_target()
	if result[0]:
		var target = result[0]
		var pac = result[1]
		
		var dist = global_position.distance_to(target)
		if dist < 2 and return_spawn and respawn_timer.is_stopped():
			respawn_timer.start()
		
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
				
				if fleeing and pac:
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
	if not dirs.is_empty():
		var random_dir = dirs.pick_random()
		_move(random_dir)
	else: # reached a deadend
		_move(return_dir)

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

#func _draw():
#	if local_paths.size() > 0:
#		var start = local_paths[0]
#		for i in range(1, local_paths.size()):
#			var end = local_paths[i]
#			draw_line(start, end, Color.RED, 2)
#			start = end


func _on_area_2d_body_entered(body):
	if body is Pacman and not catchable:
		body.killed()


func _on_respawn_timer_timeout():
	return_spawn = false
	change_normal()
