extends Control
class_name TextBox

var previous_button:TextureButton
var next_button:TextureButton
@export var animation_time := 0.5
@export var move_length := 10

func _ready() -> void:
	previous_button = get_node_or_null("Previous")
	next_button = get_node_or_null("Next")
	if next_button or previous_button:
		var animation_tween = get_tree().create_tween()
		animation_tween.pause()
		animation_tween.set_loops() 
		if next_button:
			var subtween_next_button :Tween= create_tween()
			var start_pos_next_button = next_button.position
			var end_pos_next_button = Vector2(start_pos_next_button)
			end_pos_next_button.x += move_length
			subtween_next_button.set_ease(Tween.EASE_IN_OUT).tween_property(next_button, "position", end_pos_next_button, animation_time).from(start_pos_next_button)
			subtween_next_button.chain().tween_property(next_button, "position", start_pos_next_button, animation_time).from(end_pos_next_button)
			animation_tween.tween_subtween(subtween_next_button)
		if previous_button:
			var subtween_previous_button :Tween= create_tween()
			var start_pos_previous_button = previous_button.position
			var end_pos_previous_button = Vector2(start_pos_previous_button)
			end_pos_previous_button.x -= move_length
			subtween_previous_button.set_ease(Tween.EASE_IN_OUT).tween_property(previous_button, "position", end_pos_previous_button, animation_time).from(start_pos_previous_button)
			subtween_previous_button.chain().tween_property(previous_button, "position", start_pos_previous_button, animation_time).from(end_pos_previous_button)
			animation_tween.parallel().tween_subtween(subtween_previous_button)
		animation_tween.play()
