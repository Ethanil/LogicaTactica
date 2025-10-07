extends Node
class_name BattleManager

signal attack_animation(attacker: CreatureInstance, damaged_enemies: Array[CreatureInstance], dead_enemies: Array[CreatureInstance])
signal continue_combat
signal combat_finished(result: COMBATRESULT)
signal remove_creature(creature:CreatureInstance)

enum COMBATRESULT{
	UNDECIDED = 0,
	WON = 1,
	LOST = 2,
}


func start_combat(allies: Array[CreatureInstance], enemies: Array[CreatureInstance]):
	for ally_index in allies.size():
		var ally = allies[-ally_index - 1] #have the rightmost ally attack first
		await _make_attack(ally, enemies)
		if len(allies) == 0:
			combat_finished.emit(COMBATRESULT.LOST)
			return
		elif len(enemies) == 0:
			combat_finished.emit(COMBATRESULT.WON)
			return
	for enemy in enemies: #here the leftmost is fine
		await _make_attack(enemy, allies)
		if len(allies) == 0:
			combat_finished.emit(COMBATRESULT.LOST)
			return
		elif len(enemies) == 0:
			combat_finished.emit(COMBATRESULT.WON)
			return
	combat_finished.emit(COMBATRESULT.UNDECIDED)

func _make_attack(attacking_creature: CreatureInstance, enemies: Array[CreatureInstance]):
	var enemies_that_get_attacked: Array[CreatureInstance] = []
	match attacking_creature.attack_pattern:
		CreatureData.AttackPattern.FRONT: enemies_that_get_attacked.append(enemies[-1])
		CreatureData.AttackPattern.BACK: enemies_that_get_attacked.append(enemies[0])
		CreatureData.AttackPattern.RANDOM: enemies_that_get_attacked.append(enemies.pick_random())
		CreatureData.AttackPattern.ALL: enemies_that_get_attacked.append_array(enemies)
		CreatureData.AttackPattern.CUSTOM: print("no clue what to do")
		_: print("no clue what to do")
	
	var damage = _calculate_damage(attacking_creature)
	var enemies_that_died: Array[CreatureInstance] = []
	for enemy_idx in range(enemies_that_get_attacked.size() - 1, -1, -1):
		var enemy := enemies_that_get_attacked[enemy_idx]
		enemy.take_damage(damage)
		if enemy.get_cur_health_value() <= 0:
			enemies_that_died.append(enemy)
			enemies_that_get_attacked.remove_at(enemy_idx)
	attack_animation.emit(attacking_creature, enemies_that_get_attacked, enemies_that_died)
	await continue_combat
	for creature in enemies_that_died:
		remove_creature.emit(creature)


func _calculate_damage(attacking_creature: CreatureInstance) -> int:
	return attacking_creature.get_attack_value()
