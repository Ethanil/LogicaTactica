class_name CustomArrow2D
extends Node2D

# Arrow settings
var start: Vector2
var end: Vector2
var size: int
var color: Color

func _init(
	p_start: Vector2,
 	p_end: Vector2,
	p_size: int,
	p_color: Color
):
	self.start = p_start
	self.end = p_end
	self.size = p_size
	self.color = p_color

func _draw():
	# Direction and perpendicular vectors
	var direction := (end - start).normalized()
	var perpendicular := Vector2(-direction.y, direction.x)

	# Points for arrowhead triangle
	var arrow_head_size: float = size * 5
	var point1 := end
	var point2 := end - direction * arrow_head_size + perpendicular * arrow_head_size * 0.5
	var point3 := end - direction * arrow_head_size - perpendicular * arrow_head_size * 0.5

	# Draw the main line
	draw_line(start, end - direction * arrow_head_size, color, size)

	# Draw arrowhead
	draw_polygon([point1, point2, point3], [color])
