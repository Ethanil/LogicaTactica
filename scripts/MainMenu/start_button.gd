extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://levelSelectScene.tscn")
	Global.create_new_deck()
	MusicPlayer.button_click_sound()
