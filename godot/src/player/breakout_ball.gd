extends CharacterBody2D

@export var speed := 300

var motion := Vector2.ZERO

func start_move():
	var angle = randf_range(-PI/4, PI/4)
	motion = Vector2.UP.rotated(angle)

func _physics_process(delta):
	velocity = motion * speed
	if move_and_slide():
		var collision = get_last_slide_collision()
		var n = collision.get_normal()
		motion = motion.bounce(n)
