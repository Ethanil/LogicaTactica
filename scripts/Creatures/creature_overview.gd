extends Control

@onready var container = $ScrollContainer/GridContainer
@onready var element = preload("res://scripts/Creatures/creature_information_element.tscn")
@onready var close_button:Button = $Panel/CloseButton


func _ready() -> void:
	for creature_name in Global.creature_data:
		var information_element = element.instantiate() as CreatureInformationElement
		container.add_child(information_element)
		information_element.set_creature_data(Global.creature_data[creature_name])
	close_button.pressed.connect(on_close_pressed)

func on_close_pressed() -> void:
	self.hide()
	MusicPlayer.button_click_sound()
