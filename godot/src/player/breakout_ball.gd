class_name BreakoutBall
extends CharacterBody2D

signal out_of_bound

@export var speed := 300

@onready var timer := $OutOfBoundTimer

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

func _on_visible_on_screen_notifier_2d_screen_exited():
	timer.start()


func _on_out_of_bound_timer_timeout():
	out_of_bound.emit()
	queue_free()
