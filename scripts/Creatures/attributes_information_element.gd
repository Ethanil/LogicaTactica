extends Control
class_name AttributesInformationElement

@onready var attributes:Dictionary[CreatureData.Attributes, TextureRect] = {
	CreatureData.Attributes.Flying: $VBoxContainer/Flying,
	CreatureData.Attributes.Humanoid: $VBoxContainer/Humanoid,
	CreatureData.Attributes.Insect: $VBoxContainer/Insect,
	CreatureData.Attributes.Legendary: $VBoxContainer/Legendary,
	CreatureData.Attributes.Magical: $VBoxContainer/Magical,
	CreatureData.Attributes.Mechanical: $VBoxContainer/Mechanical,
	CreatureData.Attributes.Mythical: $VBoxContainer/Mythical,
	CreatureData.Attributes.Animal: $VBoxContainer/Animal,
	CreatureData.Attributes.Undead: $VBoxContainer/Undead,
	CreatureData.Attributes.Aquatic: $VBoxContainer/Aquatic,
	CreatureData.Attributes.Plant: $VBoxContainer/Plant,
	
}
@onready var name_label:Label = $VBoxContainer/AttributeName

var _current_attribute: CreatureData.Attributes = -1 as CreatureData.Attributes

func set_attribute(attribute: CreatureData.Attributes) -> void:
	if _current_attribute != -1:
		attributes[_current_attribute].hide()
	_current_attribute = attribute
	attributes[attribute].show()
	for text in CreatureData.attribute_dict.keys():
		if CreatureData.attribute_dict[text] == attribute:
			name_label.text = text
			break

func set_text(text:String) -> void:
	if _current_attribute != -1:
		attributes[_current_attribute].hide()
	_current_attribute = -1 as CreatureData.Attributes
	name_label.text = text
 
