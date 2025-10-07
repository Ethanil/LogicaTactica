extends Button

var settings_scene = preload("res://settings.tscn")

func _on_pressed() -> void:
	var settings = settings_scene.instantiate()
	get_parent().add_child(settings)
	MusicPlayer.button_click_sound()
