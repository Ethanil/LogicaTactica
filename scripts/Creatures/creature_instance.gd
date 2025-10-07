@tool
extends Control
class_name CreatureInstance

@export var template: CreatureData

var creature_name: String
var creature_attack_value: int
var creature_health: int
var creature_defense: int
	
var attributes: Array[CreatureData.Attributes]

var attack_pattern: CreatureData.AttackPattern


var creature_with_overlay: CreatureWithOverlay
var attack_animations: Array[String]
var damaged_animations: Array[String]
var death_animations: Array[String]

signal died()
signal animation_finished(inst:CreatureInstance)
var dying := false

var audio_player: AudioStreamPlayer

func _init() -> void:
	custom_minimum_size = Vector2(192,240)
	creature_with_overlay = preload("res://assets/animatedSprites/creature_with_overlay.tscn").instantiate()
	add_child(creature_with_overlay)
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)


func set_creature_data(creature_data: CreatureData) -> void:
	template = creature_data

	creature_name = creature_data.name
	creature_attack_value = creature_data.attack_value
	creature_health = creature_data.health
	creature_defense = creature_data.defense
		
	attributes = creature_data.attributes

	attack_pattern = creature_data.attack_pattern
	attack_animations = creature_data.attack_animations
	damaged_animations = creature_data.damaged_animations
	death_animations = creature_data.death_animations
	creature_with_overlay.initialize_with_data(creature_data)
	if !is_node_ready():
		ready.connect(_on_ready)
	else:
		creature_with_overlay.update_overlay(false)
	template = creature_data

func _on_ready():
	creature_with_overlay.update_overlay(false)
	ready.disconnect(_on_ready)

func look_left() -> void:
	creature_with_overlay.sprite.flip_h = true

func look_right() -> void:
	creature_with_overlay.sprite.flip_h = false
	var health_bar_fill_stylebox = creature_with_overlay.health_bar.get_theme_stylebox("fill") as StyleBoxTexture
	var stylebox = health_bar_fill_stylebox.duplicate()
	stylebox.modulate_color = Color.GREEN
	creature_with_overlay.health_bar.add_theme_stylebox_override("fill", stylebox)


func take_damage(damage: int) -> void:
	if dying:
		return
	var real_damage = min(max((damage - creature_with_overlay.defense), 0), creature_with_overlay.cur_health)
	creature_with_overlay.cur_health -= real_damage
	creature_with_overlay.update_overlay()

func die() -> void:
	dying = true
	var arr:Array
	if self in Evaluator.allies:
		arr = Evaluator.allies
	else:
		arr = Evaluator.enemies
	creature_with_overlay.sprite.play(death_animations.pick_random())
	await creature_with_overlay.sprite.animation_finished
	arr.remove_at(arr.find(self))
	died.emit()

func play_damaged_animation(speed:float = 1) -> void:
	if animation_is_running:
		await animation_finished
	animation_is_running = true
	var original_color :=creature_with_overlay.sprite.modulate
	var tween = create_tween()
	creature_with_overlay.sprite.modulate = Color.BLACK
	tween.tween_property(creature_with_overlay.sprite, "modulate", original_color, 0.3)
	creature_with_overlay.sprite.play(damaged_animations.pick_random(), speed)
	await creature_with_overlay.sprite.animation_finished
	creature_with_overlay.sprite.play("idle")
	animation_is_running = false
	animation_finished.emit(self)

func play_death_animation(speed:float = 1) -> void:
	if animation_is_running:
		await animation_finished
	animation_is_running = true
	var original_color :=creature_with_overlay.sprite.modulate
	var tween = create_tween()
	creature_with_overlay.sprite.modulate = Color.BLACK
	tween.tween_property(creature_with_overlay.sprite, "modulate", original_color, 0.3)
	creature_with_overlay.sprite.play(death_animations.pick_random(), speed)
	await creature_with_overlay.sprite.animation_finished
	animation_is_running = false
	animation_finished.emit(self)

func play_attack_animation(speed: float = 1) -> void:
	if animation_is_running:
		await animation_finished
	animation_is_running = true
	awaited_signals[creature_with_overlay.sprite.animation_finished] = null;
	creature_with_overlay.sprite.animation_finished.connect(func():
		_on_sound_or_animation_finished(creature_with_overlay.sprite.animation_finished)
		creature_with_overlay.sprite.play("idle"),
		CONNECT_ONE_SHOT)
	creature_with_overlay.sprite.play(attack_animations.pick_random(), speed)
	if template.attack_sound != null:
		await get_tree().create_timer(template.attack_sound_delay).timeout
		MusicPlayer.play_sfx(template.attack_sound.sound)
		awaited_signals[MusicPlayer.instance.sfx_finished] = null;
		MusicPlayer.instance.sfx_finished.connect(_on_sound_or_animation_finished.bind(MusicPlayer.instance.sfx_finished),CONNECT_ONE_SHOT)

var animation_is_running := false

var awaited_signals:Dictionary = {}

func _on_sound_or_animation_finished(s: Signal) -> void:
	if not awaited_signals.has(s):
		return
	awaited_signals.erase(s)
	if len(awaited_signals) == 0:
		animation_is_running = false
		animation_finished.emit(self)


func get_attack_value() -> int:
	return creature_with_overlay.attack

func get_defense_value() -> int:
	return creature_with_overlay.defense

func get_max_health_value() -> int:
	return creature_with_overlay.max_health

func get_cur_health_value() -> int:
	return creature_with_overlay.cur_health

func set_attack_value(attack_value: int) -> void:
	creature_with_overlay.attack = attack_value
	creature_with_overlay.update_overlay()

func set_defense_value(defense_value: int) -> void:
	creature_with_overlay.defense = defense_value
	creature_with_overlay.update_overlay()

func set_max_health_value(max_health_value: int) -> void:
	creature_with_overlay.max_health = max_health_value
	if creature_with_overlay.max_health <= 0:
		await die()
	creature_with_overlay.update_overlay()

func set_cur_health_value(cur_health_value: int) -> void:
	creature_with_overlay.cur_health = cur_health_value
	if creature_with_overlay.cur_health <= 0:
		await die()
	creature_with_overlay.update_overlay()
	
func full_heal() -> void:
	creature_with_overlay.cur_health = max(creature_with_overlay.max_health, creature_with_overlay.cur_health)
	creature_with_overlay.update_overlay()

func set_attributes(creature_attributes: Array[CreatureData.Attributes]) -> void:
	creature_with_overlay.attributes = creature_attributes
	creature_with_overlay.update_overlay()

func get_attributes() -> Array[CreatureData.Attributes]:
	return creature_with_overlay.attributes
