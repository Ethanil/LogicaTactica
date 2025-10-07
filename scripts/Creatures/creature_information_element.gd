extends Control
class_name CreatureInformationElement

@onready var container:Container = %SpriteContainer
@onready var name_label:Label = %CreatureName

var _creature_instance:CreatureInstance

func set_creature_data(data: CreatureData, look_right:=false) -> void:
	if _creature_instance == null:
		_creature_instance = CreatureInstance.new()
		container.add_child(_creature_instance)
		_creature_instance.set_creature_data(data)
		if look_right:
			_creature_instance.look_right()
	else:
		_creature_instance.set_creature_data(data)
	name_label.text = data.name
	var current = 3
	for i in range(56):
		name_label.add_theme_font_size_override("font_size", i + 1)
		if name_label.size.x > size.x or name_label.size.y > size.y:
			break
		current = i
	name_label.add_theme_font_size_override("font_size", current - 3)
