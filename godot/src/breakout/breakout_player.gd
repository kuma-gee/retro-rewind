class_name BreakoutPlayer
extends StaticBody2D

@export var ball_scene: PackedScene
@export var ball_remote: RemoteTransform2D
@export var speed := 400
@export var max_x := 605
@export var min_x := 35

@export var flip_input := false

@onready var lost_ball_sound := $LostBall
@onready var input := $Input
@onready var timer := $BallSpawnTimer
@onready var orig_pos := global_position

var spawned_ball

var ball_position
var ball_motion
var ball_sound = false
var ball_combo = 1.0
var ball_speed

var active_ball
var motion = 0

func _ready():
	_spawn_ball.call_deferred()

func reset():
	active_ball = spawned_ball
	spawned_ball = null
	
	active_ball.motion = Vector2.ZERO
	active_ball.combo = 1.0
	ball_remote.remote_path = ball_remote.get_path_to(active_ball)
	global_position = orig_pos

func _spawn_ball():
	active_ball = ball_scene.instantiate() as BreakoutBall
	active_ball.out_of_bound.connect(func():
		spawned_ball = null
		lost_ball_sound.play()
		GameManager.lose_health(false)
		timer.start()
	)
	active_ball.global_position = ball_remote.global_position
	get_tree().current_scene.add_child(active_ball)
	
	if ball_position == null:
		ball_remote.remote_path = ball_remote.get_path_to(active_ball)
	else:
		active_ball.global_position = ball_position
		active_ball.motion = ball_motion
		active_ball.combo = ball_combo
		active_ball.play_sound = ball_sound
		active_ball.current_speed = ball_speed if ball_speed else active_ball.speed
		spawned_ball = active_ball
		active_ball = null

func _process(delta):
	if spawned_ball:
		ball_position = spawned_ball.global_position
		ball_motion = spawned_ball.motion
		ball_sound = spawned_ball.play_sound
		ball_combo = spawned_ball.combo
		ball_speed = spawned_ball.current_speed
	else:
		ball_position = null
		ball_motion = null
		ball_sound = false
		ball_combo = 1
		ball_speed = null

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
		active_ball.play_sound = true
		
		spawned_ball = active_ball
		active_ball = null


func _on_ball_spawn_timer_timeout():
	_spawn_ball()
