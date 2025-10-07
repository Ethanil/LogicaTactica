extends Button

var credits_scene = preload("res://credits.tscn")

func _on_pressed() -> void:
	var credits = credits_scene.instantiate()
	get_parent().add_child(credits)
	MusicPlayer.button_click_sound()
