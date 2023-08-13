class_name Pacman
extends CharacterBody2D

signal died()

@export var tilemap: TileMap

@onready var input: PlayerInput = $Input
@onready var collision := $CollisionShape2D
@onready var invincible_timer := $InvincibilityTimer

@onready var orig_modul = modulate

var moving = null
var tw: Tween
var motion = Vector2.ZERO

var start_invincible = true

func _ready():
	if start_invincible:
		collision.disabled = true
		tw = create_tween()
		tw.set_loops()
		tw.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
		tw.tween_property(self, "modulate", orig_modul, 0.5)
		invincible_timer.start()
	else:
		collision.disabled = false

func _physics_process(delta):
	if moving != null:
		var dir = position.direction_to(moving)
		var angle = dir.angle_to(Vector2.RIGHT)
		rotation_degrees = round(rad_to_deg(angle))
		if abs(rotation_degrees) == 90:
			rotation_degrees *= -1
		return
	
	var motion_x = ceil(input.get_action_strength("move_right")) - ceil(input.get_action_strength("move_left"))
	var motion_y = ceil(input.get_action_strength("move_down")) - ceil(input.get_action_strength("move_up"))
	motion = Vector2i(motion_x, motion_y)
	moving = tilemap.do_move(self, motion, func(): moving = null)


func killed():
	died.emit()
	queue_free()

func _on_invincibility_timer_timeout():
	if tw:
		tw.kill()
	modulate = orig_modul
	collision.disabled = false
	


func _on_area_2d_body_entered(body):
	if body is PacmanGhost:
		body.caught()
		GameManager.add_pacman_score(50)


func _on_area_2d_area_entered(area):
	if area is PacmanPoint:
		area.collect()
