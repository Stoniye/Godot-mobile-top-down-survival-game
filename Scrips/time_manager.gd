extends Node2D

##Time Variables##
var timer: float = 0
var tic_speed: int = 1
signal tic

func _physics_process(delta):
	timer += delta
	if timer >= float(1 * tic_speed):
		tic.emit()
		timer = 0
