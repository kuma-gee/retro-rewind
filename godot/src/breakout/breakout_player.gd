class_name BreakoutPlayer
extends StaticBody2D

@export var ball_scene: PackedScene
@export var ball_remote: RemoteTransform2D
@export var speed := 400
@export var max_x := 605
@export var min_x := 35

@export var flip_input := false

@onready var input := $Input
@onready var timer := $BallSpawnTimer

var spawned_ball

var ball_position
var ball_motion

var active_ball
var motion = 0

func _ready():
	_spawn_ball.call_deferred()

func _spawn_ball():
	active_ball = ball_scene.instantiate() as BreakoutBall
	active_ball.out_of_bound.connect(func():
		spawned_ball = null
		GameManager.lose_health()
		timer.start()
	)
	get_tree().current_scene.add_child(active_ball)
	
	if ball_position == null:
		ball_remote.remote_path = ball_remote.get_path_to(active_ball)
	else:
		active_ball.global_position = ball_position
		active_ball.motion = ball_motion
		spawned_ball = active_ball
		active_ball = null

func _process(delta):
	if spawned_ball:
		ball_position = spawned_ball.global_position
		ball_motion = spawned_ball.motion
	else:
		ball_position = null
		ball_motion = null

func _physics_process(delta):
	motion = input.get_action_strength("move_right") - input.get_action_strength("move_left")
	if flip_input:
		motion *= -1
	
	move_local_x(motion * speed * delta)
	global_position.x = clamp(global_position.x, min_x, max_x)

func _on_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("shot") and active_ball:
		ball_remote.remote_path = NodePath()
		active_ball.start_move()
		
		spawned_ball = active_ball
		active_ball = null


func _on_ball_spawn_timer_timeout():
	_spawn_ball()
