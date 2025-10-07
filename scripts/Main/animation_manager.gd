extends Node
class_name AnimationManager

signal all_animation_finished

var awaited_signals: Array[Signal] = []

var timeout_timer: SceneTreeTimer = null

func on_animate_attack(attacker: CreatureInstance, attacked_creatures: Array[CreatureInstance], dead_creatures: Array[CreatureInstance]):
	if len(awaited_signals) > 0:
		await all_animation_finished
	timeout_timer = get_tree().create_timer(3)
	timeout_timer.timeout.connect(_cleanup_and_emit_animation_finished)
	trigger_animation(attacker.creature_with_overlay.sprite, attacker.attack_animations, attacker.template.attack_sound, attacker.template.attack_sound_delay)
	for creature in attacked_creatures:
		trigger_animation(creature.creature_with_overlay.sprite, creature.damaged_animations, null, 0, Color.BLACK)
	for creature in dead_creatures:
		trigger_animation(creature.creature_with_overlay.sprite, creature.death_animations, null, 0,Color.BLACK, "")

func _cleanup_and_emit_animation_finished():
	timeout_timer.timeout.disconnect(_cleanup_and_emit_animation_finished)
	awaited_signals.clear()
	all_animation_finished.emit()

func _on_animation_finished(s: Signal):
	var idx := awaited_signals.find(s)
	if idx == -1:
		return
	awaited_signals.remove_at(idx)
	if len(awaited_signals) == 0:
		_cleanup_and_emit_animation_finished()

func trigger_animation(sprite: AnimatedSprite2D, animation_names: Array[String], sound: AudioAssetWithMetadata = null, sound_delay :float= 0, flashing_color: Color = Color.WHITE, chained_animation := "idle", speed: float = 1):
	awaited_signals.append(sprite.animation_finished);
	sprite.animation_finished.connect(func():
		_on_animation_finished(sprite.animation_finished)
		if chained_animation != "":
			sprite.play(chained_animation),
		CONNECT_ONE_SHOT)
	sprite.play(animation_names.pick_random(), speed)
	var original_color:= sprite.modulate
	var tween = create_tween()
	sprite.modulate = flashing_color
	tween.tween_property(sprite, "modulate", original_color, 0.5)
	if sound != null:
		await get_tree().create_timer(sound_delay).timeout
		MusicPlayer.play_sfx(sound.sound)
		awaited_signals.append(MusicPlayer.instance.sfx_finished);
		MusicPlayer.instance.sfx_finished.connect(_on_animation_finished.bind(MusicPlayer.instance.sfx_finished),CONNECT_ONE_SHOT)
	
