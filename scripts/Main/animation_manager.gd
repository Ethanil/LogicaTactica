extends Node
class_name AnimationManager

signal all_animation_finished

var awaited_signals: Dictionary = {}
func on_animate_attack(attacker: CreatureInstance, attacked_creatures: Array[CreatureInstance], dead_creatures: Array[CreatureInstance]):
	if len(awaited_signals) > 0:
		await all_animation_finished
	attacker.animation_finished.connect(func(_c):
		_on_animation_finished(attacker.animation_finished),
		CONNECT_ONE_SHOT)
	awaited_signals[attacker.animation_finished] = null
	for creature in attacked_creatures:
		creature.animation_finished.connect(func(_c):
			_on_animation_finished(creature.animation_finished),
			CONNECT_ONE_SHOT)
		awaited_signals[creature.animation_finished] = null
	for creature in dead_creatures:
		creature.animation_finished.connect(func(_c):
			_on_animation_finished(creature.animation_finished),
			CONNECT_ONE_SHOT)
		awaited_signals[creature.animation_finished] = null
	attacker.play_attack_animation()
	for creature in attacked_creatures:
		creature.play_damaged_animation()
	for creature in dead_creatures:
		creature.play_death_animation()


func _on_animation_finished(s: Signal):
	if not awaited_signals.has(s):
		return
	awaited_signals.erase(s)
	if len(awaited_signals) == 0:
		all_animation_finished.emit()
