class_name BreakoutPlayer
extends CharacterBody2D

@export var ball_scene: PackedScene
@export var ball_remote: RemoteTransform2D
@export var speed := 400

@onready var input := $Input

var active_ball

func _ready():
	_spawn_ball.call_deferred()

func _spawn_ball():
	active_ball = ball_scene.instantiate() as BreakoutBall
	active_ball.out_of_bound.connect(_spawn_ball)
	get_tree().current_scene.add_child(active_ball)
	ball_remote.remote_path = ball_remote.get_path_to(active_ball)

func _physics_process(delta):
	var motion = input.get_action_strength("move_right") - input.get_action_strength("move_left")
	velocity = Vector2(motion, 0) * speed
	
	move_and_slide()

func _on_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("shot") and active_ball:
		ball_remote.remote_path = NodePath()
		active_ball.start_move()
		active_ball = null
