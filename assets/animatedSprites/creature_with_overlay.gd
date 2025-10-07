extends Node2D
class_name CreatureWithOverlay

@onready var sprite: AnimatedSprite2D = $Creature

@onready var health_label: Label = $Container/HealthBar/HealthLabel
@onready var attack_label: Label = $Container/AttackBackground/AttackContainer/AttackLabel
@onready var defense_label: Label = $Container/DefenseBackground/DefenseContainer/DefenseLabel
@onready var health_bar: ProgressBar = $Container/HealthBar
@onready var attribute_icons: Dictionary[CreatureData.Attributes, TextureRect]={
	CreatureData.Attributes.Flying: $Container/HFlowContainer/Flying,
	CreatureData.Attributes.Animal: $Container/HFlowContainer/Animal,
	CreatureData.Attributes.Magical: $Container/HFlowContainer/Magical,
	CreatureData.Attributes.Insect: $Container/HFlowContainer/Insect,
	CreatureData.Attributes.Mythical: $Container/HFlowContainer/Mythical,
	CreatureData.Attributes.Legendary: $Container/HFlowContainer/Legendary,
	CreatureData.Attributes.Undead: $Container/HFlowContainer/Undead,
	CreatureData.Attributes.Plant: $Container/HFlowContainer/Plant,
	CreatureData.Attributes.Aquatic: $Container/HFlowContainer/Aquatic,
	CreatureData.Attributes.Mechanical: $Container/HFlowContainer/Mechanical,
	CreatureData.Attributes.Humanoid: $Container/HFlowContainer/Humanoid,
	
}
@onready var sprite_container:Control= $Container
@onready var attack_pattern_rect:TextureRect = $Container/AttackBackground/AttackPattern
var attack_pattern:CreatureData.AttackPattern = CreatureData.AttackPattern.FRONT
@onready var attack_pattern_textures: Dictionary[CreatureData.AttackPattern, CompressedTexture2D]={
	CreatureData.AttackPattern.FRONT: preload("res://assets/UI/front_attacker.png"),
	CreatureData.AttackPattern.BACK: preload("res://assets/UI/back_attacker.png"),
	CreatureData.AttackPattern.RANDOM: preload("res://assets/UI/random_attacker.png"),
	CreatureData.AttackPattern.ALL: preload("res://assets/UI/all_attacker.png"),
}

@export var sprite_frames:SpriteFrames

var attack:int = 0
var defense:int = 0

var max_health:int = 0
var cur_health:int = 0
var attributes: Array[CreatureData.Attributes] = []

var sprite_y_offset:float = 0
var _initial_sprite_y_offset:float = 40.667
func _ready() -> void:
	_initialize_overlay()

func _initialize_overlay() -> void:
	sprite.sprite_frames = sprite_frames
	sprite.position.y = _initial_sprite_y_offset + sprite_y_offset
	if !sprite.is_playing() and sprite_frames != null:
		sprite.frame = randi_range(0, sprite_frames.get_frame_count("idle") - 1)
		sprite.play()
	health_label.text = str(cur_health) + "/" + str(max_health)
	attack_label.text = str(attack)
	defense_label.text = str(defense)
	health_bar.max_value = max_health
	health_bar.value = cur_health
	attack_pattern_rect.texture = attack_pattern_textures[attack_pattern]
	_update_attributes()

func update_overlay(use_animations:=true) -> void:
	if !use_animations:
		_initialize_overlay()
		return
	sprite.sprite_frames = sprite_frames
	sprite.position.y = _initial_sprite_y_offset + sprite_y_offset
	if !sprite.is_playing():
		sprite.frame = randi_range(0, sprite_frames.get_frame_count("idle") - 1)
		sprite.play()
	attack_pattern_rect.texture = attack_pattern_textures[attack_pattern]
	health_bar.max_value = max_health
	var tween = get_tree().create_tween()
	var parts = health_label.text.split("/")
	var health_values = Vector2i(int(parts[0]), int(parts[1]))
	tween.parallel().tween_method(_update_health_label, health_values, Vector2i(cur_health, max_health), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var current_attack := int(attack_label.text)
	tween.parallel().tween_method(_update_attack_label, current_attack, attack, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var current_defense := int(defense_label.text)
	tween.parallel().tween_method(_update_defense_label, current_defense, defense, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(health_bar, "value", cur_health, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_update_attributes()
	
func _update_attack_label(value: float) -> void:
	attack_label.text = str(roundi(value))

func _update_defense_label(value: float) -> void:
	defense_label.text = str(roundi(value))

func _update_health_label(health_values: Vector2) -> void:
	health_label.text = str(roundi(health_values.x)) + "/" + str(roundi(health_values.y))
	
func initialize_with_data(data: CreatureData) -> void:
	sprite_frames = data.sprite_Frames
	
	attack = data.attack_value
	defense = data.defense
	max_health = data.health
	cur_health = data.health
	attributes = data.attributes
	sprite_y_offset = data.sprite_y_offset
	attack_pattern = data.attack_pattern

func _update_attributes() -> void:
	for attribute in attribute_icons:
		if attribute in attributes:
			attribute_icons[attribute].show()
		else:
			attribute_icons[attribute].hide()
