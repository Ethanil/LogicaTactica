class_name ZoomingCamera2D
extends Camera2D

# Configurable zoom properties
@export var min_zoom := 0.8
@export var max_zoom := 2.0
@export var zoom_factor := 0.1

# Camera movement bounds — set this from outside
@export var camera_limits_min: Vector2
@export var camera_limits_max: Vector2
@export var move_speed := 10

var _zoom_level := 1.0: set = _set_zoom_level

# Dragging state
var dragging := false
var drag_origin := Vector2()

func _set_zoom_level(value: float) -> void:
	_zoom_level = clamp(value, min_zoom, max_zoom)
	self.zoom = Vector2(_zoom_level, _zoom_level)
	_clamp_camera_position()
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		position.y -= 10
		_clamp_camera_position()
	if Input.is_action_pressed("move_right"):
		position.x += 10
		_clamp_camera_position()
	if Input.is_action_pressed("move_down"):
		position.y += 10	
		_clamp_camera_position()
	if Input.is_action_pressed("move_left"):
		position.x -= 10
		_clamp_camera_position()

func _unhandled_input(event):
	# Zoom control
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level - zoom_factor)
	elif event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)

func _clamp_camera_position():
	# Compute visible size in world units (taking zoom into account)
	var half_screen = get_viewport_rect().size * 0.5 / zoom
	var min_pos = camera_limits_min + half_screen
	var max_pos = camera_limits_max - half_screen
	
	position = position.clamp(min_pos, max_pos)
