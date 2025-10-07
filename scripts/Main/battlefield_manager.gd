extends Node
class_name BattlefieldManager

static var allies: Array[CreatureInstance] = []
static var enemies: Array[CreatureInstance] = []

func load_creatures_from_level(level: Level):
	allies = []
	enemies = []
	for data in level.allies:
		allies.append(create_creature(data))
	for data in level.enemies:
		enemies.append(create_creature(data))
	update_containers()


func create_creature(data: CreatureData) -> CreatureInstance:
	var instance = CreatureInstance.new()
	instance.set_creature_data(data)
	return instance

static func get_allies(_args:Array) -> Array:
	assert(len(_args) == 0)
	return allies

static func get_enemies(_args:Array) -> Array:
	assert(len(_args) == 0)
	return enemies

static func get_creatures(_args:Array) -> Array:
	assert(len(_args) == 0)
	return allies + enemies

static func get_attack(creatures:Array) -> int:
	assert(len(creatures) == 1)
	return creatures[0].get_attack_value()

static func get_defense(creatures:Array) -> int:
	assert(len(creatures) == 1)
	return creatures[0].get_defense_value()
	
static func get_max_health(creatures:Array) -> int:
	assert(len(creatures) == 1)
	return creatures[0].get_max_health_value()
	
static func get_cur_health(creatures:Array) -> int:
	assert(len(creatures) == 1)
	return creatures[0].get_cur_health_value()
	
static func heal(creatures:Array) -> void:
	assert(len(creatures) == 1)
	creatures[0].full_heal()

static func spawn_creature(args:Array) -> Array:
	var res := []
	for creature_name in args:
		if not Global.creature_data.has(creature_name):
			push_error("Unknown creature: " + creature_name)
		else:
			var instance = CreatureInstance.new()
			res.append(instance)
			instance.set_creature_data(Global.creature_data[creature_name])
	return res

static func length(args:Array)->int:
	assert(len(args) == 1)
	return len(args[0])

static func has_attributes(args:Array)->bool:
	assert(len(args) > 1)
	var creature: CreatureInstance = args[0] as CreatureInstance
	var creatre_attributes:Array[CreatureData.Attributes] = creature.get_attributes()
	for index in len(args):
		if index == 0:
			continue
		var attribute:String = args[index] as String #attribute should be a string
		if !creatre_attributes.has(CreatureData.attribute_dict[attribute]):
			return false
	return true

static func sum(args:Array)->int:
	assert(len(args) == 2)
	var fun_name = args[1]
	var fun = Evaluator.function_context[fun_name]
	var result = 0
	for arg in args[0]:
		result += fun.call([arg])
	return result

static func set_allies(args:Array):
	assert(len(args) == 1)
	#allies = args[0] #no idea why this does not work
	if len(args[0]) > 5:
		return #make sure never more then 5 allies are in play
	allies = []
	for ally in args[0]:
		allies.append(ally)

static func set_attack(args:Array):
	assert(len(args) == 2)
	var creature: CreatureInstance = args[0]
	var new_value: int = args[1]
	creature.set_attack_value(new_value)

static func set_defense(args:Array):
	assert(len(args) == 2)
	var creature: CreatureInstance = args[0]
	var new_value: int = args[1]
	creature.set_defense_value(new_value)

static func set_cur_health(args:Array):
	assert(len(args) == 2)
	var creature: CreatureInstance = args[0]
	var new_value: int = args[1]
	creature.set_cur_health_value(new_value)

static func set_max_health(args:Array):
	assert(len(args) == 2)
	var creature: CreatureInstance = args[0]
	var new_value: int = args[1]
	creature.set_max_health_value(new_value)

static func set_attributes(args:Array):
	assert(len(args) == 2)
	var creature: CreatureInstance = args[0]
	var new_attributes: Array[String] = args[1] #attribute should be a string
	var attributes = []
	for attribute in new_attributes:
		attributes.append(CreatureData.attribute_dict[attribute])
	creature.set_attributes(attributes)

@onready var allies_container: HBoxContainer = %Allies
@onready var enemies_container: HBoxContainer = %Enemies

signal creatureRemovedFromContainer(creature: CreatureInstance)
signal creatureAddedToContainer(creature: CreatureInstance)


func on_creature_died(creature:CreatureInstance) -> void:
	var idx := allies.find(creature)
	if idx == -1:
		idx = enemies.find(creature)
		if idx == -1:
			return
		enemies.remove_at(idx)
	else:
		allies.remove_at(idx)
	update_containers()


func update_containers() -> void:
	_update_container(allies_container, allies, func(creature: CreatureInstance): creature.look_right())
	_update_container(enemies_container, enemies, func(creature: CreatureInstance): creature.look_left())


func _update_container(container: HBoxContainer, creatures: Array[CreatureInstance], lookFunc: Callable):
	var displayed_creatures  = container.get_children()
	if displayed_creatures != creatures:
		var creatures_to_add := creatures.duplicate()
		for creature in displayed_creatures:
			var idx := creatures_to_add.find(creature)
			if idx == -1:
				container.remove_child(creature)
				creatureRemovedFromContainer.emit(creature)
			else:
				creatures_to_add.remove_at(idx)
		for creature in creatures_to_add:
			container.add_child(creature)
			lookFunc.call(creature)
			creatureAddedToContainer.emit(creature)
