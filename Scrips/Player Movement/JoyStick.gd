extends Area2D

##Nodes from Scene##
@onready var big_circle: Node2D = $BigCircle
@onready var small_circle: Node2D = $BigCircle/SmalCircle

##Variables for Process##
@onready var max_distance: int = 120
var touched : bool = false
var dist: Vector2
var start_pos: Vector2 = Vector2(0, 0)

func _ready():
	set_process(false)
	start_pos = position
	big_circle.visible = false

##Handel User Input
func _input(event):
	if event is InputEventScreenTouch && event.index == 0:
		if !touched && get_global_mouse_position().x < (get_viewport_rect().size.x / 2.7) && get_global_mouse_position().y > (get_viewport_rect().size.y / 2):
			position = get_global_mouse_position()
			touched = true
		else:
			position = start_pos
			small_circle.position = Vector2(0, 0)
			touched = false
		big_circle.visible = touched
		set_process(touched)

func _process(delta):
	
	small_circle.global_position = get_global_mouse_position()
	
	# Clamp small circle to the big one
	dist = small_circle.global_position - big_circle.global_position
	if dist.length() > max_distance:
		small_circle.global_position = big_circle.global_position + dist.normalized() * max_distance

##Retruns the current Vector of the JoyStick
func get_velo() -> Vector2:
	return Vector2(small_circle.position.x / max_distance, small_circle.position.y / max_distance)
