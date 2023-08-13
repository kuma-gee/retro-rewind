extends Area2D

signal collected

func _on_area_entered(_area):
	collected.emit()
	GameManager.add_pacman_score(1)
	queue_free()
