extends PacmanGhost

var min_switch_time = 3.0
var max_switch_time = 8.0

func _set_move(m):
	super._set_move(m)

func change_running():
	$Timer.stop()
	super.change_running()
	
func change_normal():
	super.change_normal()
	fleeing = true
	_start_switch_timer()

func _start_switch_timer():
	$Timer.start(randf_range(min_switch_time, max_switch_time))

func _on_timer_timeout():
	fleeing = not fleeing
	_start_switch_timer()
