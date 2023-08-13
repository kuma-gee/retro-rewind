extends Area2D

signal collected()

func _on_area_entered(area):
	collected.emit()
	queue_free()
