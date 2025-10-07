extends Button

func _on_pressed() -> void:
	MusicPlayer.button_click_sound()
	get_tree().quit()
