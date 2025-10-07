extends Button

var how_to_play_scene = preload("res://how_to_play.tscn")

func _on_pressed() -> void:
	Global.isTutorial = true
	get_tree().change_scene_to_file("res://mainScene.tscn")
	MusicPlayer.button_click_sound()
