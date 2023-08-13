class_name BreakoutBall
extends CharacterBody2D

signal out_of_bound

@export var max_speed := 500
@export var speed := 300
@export var spin_angle := PI/8

@onready var current_speed = speed

var motion := Vector2.ZERO

func start_move():
	var angle = randf_range(-PI/4, PI/4)
	motion = Vector2.UP.rotated(angle)

func _physics_process(delta):
	velocity = motion * current_speed
	if move_and_slide():
		var collision = get_last_slide_collision()
		var n = collision.get_normal()
		
		motion = motion.bounce(n)
		if abs(motion.dot(Vector2.UP)) < 0.07:
			#print("too narrow ", motion.normalized().dot(Vector2.LEFT))
			var angle = motion.angle_to(Vector2.UP)
			motion = motion.rotated(angle/2)
		
		current_speed *= 1.01
		current_speed = min(current_speed, max_speed)
		
		var collider = collision.get_collider()
		if collider is BreakoutBlock:
			collider.remove_block()
			GameManager.add_breakout_score(collider.value)
		
		if collider is BreakoutPlayer:
			var spin_dir = sign(collider.motion)
			motion = motion.rotated(spin_angle * spin_dir)


func _on_visible_on_screen_notifier_2d_screen_exited():
	out_of_bound.emit()
	queue_free()
