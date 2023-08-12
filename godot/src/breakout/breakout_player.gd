class_name BreakoutPlayer
extends StaticBody2D

signal update_score(score)

@export var ball_scene: PackedScene
@export var ball_remote: RemoteTransform2D
@export var speed := 400
@export var max_x := 605
@export var min_x := 35

@onready var input := $Input

var active_ball
var score = 0
var motion = 0

func _ready():
	_spawn_ball.call_deferred()

func _spawn_ball():
	active_ball = ball_scene.instantiate() as BreakoutBall
	active_ball.out_of_bound.connect(_spawn_ball)
	active_ball.scored.connect(func(v):
		score += v
		update_score.emit(score)
	)
	get_tree().current_scene.add_child(active_ball)
	ball_remote.remote_path = ball_remote.get_path_to(active_ball)

func _physics_process(delta):
	motion = input.get_action_strength("move_right") - input.get_action_strength("move_left")
	move_local_x(motion * speed * delta)
	global_position.x = clamp(global_position.x, min_x, max_x)

func _on_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("shot") and active_ball:
		ball_remote.remote_path = NodePath()
		active_ball.start_move()
		active_ball = null
