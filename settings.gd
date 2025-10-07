extends Node2D
@onready var close_button:Button = $Control/Panel/Button
@onready var music_slider: HSlider = $Control/Panel/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Control/Panel/VBoxContainer/HBoxContainer2/SoundSlider

func _ready() -> void:
	music_slider.value = Global.music_volume
	sfx_slider.value = Global.sfx_volume
	music_slider.value_changed.connect(_change_music_volume)
	sfx_slider.value_changed.connect(_change_sfx_volume)
	close_button.pressed.connect(queue_free)
	close_button.pressed.connect(MusicPlayer.button_click_sound)

func _change_music_volume(volume: float) -> void:
	Global.music_volume = volume

func _change_sfx_volume(volume: float) -> void:
	Global.sfx_volume = volume
