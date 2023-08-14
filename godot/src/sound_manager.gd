extends Node

@onready var pacman_point: DebounceAudio = $PacmanPoint
@onready var pacman_powerup: DebounceAudio = $PacmanPowerUp

@onready var clear_sound := $ClearSound

func score_pacman_point():
	pacman_point.play_debounce(0.1)

func play_pacman_powerup():
	pacman_powerup.play_debounce(0.1)

func cleared():
	clear_sound.play()
