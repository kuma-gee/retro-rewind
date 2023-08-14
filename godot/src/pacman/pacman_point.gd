class_name PacmanPoint
extends Area2D

signal collected

var enable_move = false
var speed = 3.0
var tilemap: PacmanMap

var moving = null
var return_dir
var tw: Tween

var pos: Vector2i

func restore():
	enable_move = false
	return_dir = null
	if tw:
		tw.kill()

func collect():
	collected.emit()
	GameManager.add_pacman_score(5)
	_play_sound()
	queue_free()

func _play_sound():
	SoundManager.score_pacman_point()

func _process(delta):
	if moving != null or not enable_move:
		return

	var dirs = _possible_dirs()
	if not dirs.is_empty():
		var random_dir = dirs.pick_random()
		_move(random_dir)
	else: # reached a deadend
		_move(return_dir)

func _move(dir):
	var result = tilemap.do_move(self, dir, func(): moving = null, speed, false, true)
	if result:
		moving = result[0]
		tw = result[1]
		return_dir = -dir
	else:
		moving = null

func _possible_dirs():
	return tilemap.possible_dir(position).filter(func(d): return return_dir == null or Vector2(d) != Vector2(return_dir))

