extends Node

var levelTree: LevelGraphNode

var card_scene:= preload("res://cardScene.tscn")
var deck: Array[CardData]
var currentLevel: Level

var isTutorial := false

signal music_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)

var _music_volume: float = 0.2
var _sfx_volume: float = 0.5

var music_volume: float:
	get:
		return _music_volume
	set(value):
		if _music_volume != value:
			_music_volume = value
			music_volume_changed.emit(value)

var sfx_volume: float:
	get:
		return _sfx_volume
	set(value):
		if _sfx_volume != value:
			_sfx_volume = value
			sfx_volume_changed.emit(value)


var basic_card_datas: Array[CardData] = [
	preload("res://assets/card/CardResources/Startdeck/1_Katze_Heal.tres"),
	preload("res://assets/card/CardResources/Startdeck/2_Fuchs_AttackBuff.tres"),
	preload("res://assets/card/CardResources/Startdeck/3_Gladiator_DefenseBuff.tres"),
	preload("res://assets/card/CardResources/Startdeck/4_phoenix_heal.tres"),
	preload("res://assets/card/CardResources/Startdeck/5_archeologe_attackbugg.tres"),
	preload("res://assets/card/CardResources/Startdeck/6_necromant_damagespell.tres"),

]

var advanced_card_datas: Array[CardData] = [
	preload("res://assets/card/CardResources/Advanced/7_splittersoul_megadamage.tres"),
	preload("res://assets/card/CardResources/Advanced/8_phoenix_megabuffAndDebuff.tres"),
	preload("res://assets/card/CardResources/Advanced/9_necromant_buffAndHeal.tres"),
]

var tutorial_card_datas: Array[CardData] = [
	preload("res://assets/card/CardResources/TutorialCards/tutorialCard.tres"),
]

var creature_data: Dictionary[StringName, CreatureData] = {
		"Roter Panda": preload("res://scripts/Creatures/red_panda.tres"),
		"Zyklop": preload("res://scripts/Creatures/cyclops.tres"),
		
		"Archäologe": preload("res://scripts/Creatures/archaelogist.tres"),
		"Oktopus": preload("res://scripts/Creatures/octopus.tres"),
		"Gehirnmaulwurf": preload("res://scripts/Creatures/brain_mole.tres"),
		"Fuchs": preload("res://scripts/Creatures/fox.tres"),
		"Phönixling": preload("res://scripts/Creatures/phoenixling.tres"),
		"Kakodämon": preload("res://scripts/Creatures/cacodeamon.tres"),
		"Gladiator": preload("res://scripts/Creatures/gladiator.tres"),
		"Katze": preload("res://scripts/Creatures/cat.tres"),
		"Nekromant": preload("res://scripts/Creatures/necromancer.tres"),
		"Splitterseele": preload("res://scripts/Creatures/shardsoul.tres"),
		"Kobold-König": preload("res://scripts/Creatures/goblin_king.tres"),
		"Kobold-Mech": preload("res://scripts/Creatures/goblin_mech.tres"),
		"Inkubus": preload("res://scripts/Creatures/incubus.tres"),
		"Minotaurus": preload("res://scripts/Creatures/minotaur.tres")
}

func _init():
	var bossNode = LevelGraphNode.new(
		Level.new(Level.LevelType.BOSS, [creature_data["Gladiator"], creature_data["Fuchs"]], [
			creature_data["Minotaurus"], 
			creature_data["Kobold-König"],
			creature_data["Minotaurus"],
		]),
		[],
	)
	
	var preBossSharedNode = LevelGraphNode.new(
		Level.new(Level.LevelType.NORMAL, [creature_data["Oktopus"]], [
			creature_data["Nekromant"],
			creature_data["Splitterseele"],
			creature_data["Inkubus"],
			creature_data["Kakodämon"],
			creature_data["Nekromant"],
		]),
		[
			bossNode
		],
	)
	
	levelTree = LevelGraphNode.new(
		Level.new(Level.LevelType.NORMAL, [creature_data["Phönixling"]], [
			creature_data["Nekromant"],
			creature_data["Minotaurus"],
			creature_data["Gladiator"],
		]),
		[
			LevelGraphNode.new(
				Level.new(Level.LevelType.NORMAL, [creature_data["Fuchs"]], [
					creature_data["Inkubus"],
					creature_data["Splitterseele"],
					creature_data["Gladiator"],
					creature_data["Minotaurus"],
				]),
				[
					LevelGraphNode.new(
						Level.new(Level.LevelType.NORMAL, [creature_data["Roter Panda"]], [
							creature_data["Nekromant"],
							creature_data["Gladiator"],
							creature_data["Kakodämon"],
							creature_data["Minotaurus"],
						]),
						[
							preBossSharedNode
						],
					),
					LevelGraphNode.new(
						Level.new(Level.LevelType.NORMAL, [creature_data["Archäologe"]], [
							creature_data["Kobold-Mech"],
							creature_data["Gehirnmaulwurf"],
							creature_data["Zyklop"],
							creature_data["Zyklop"],
						]),
						[
							preBossSharedNode
						],
					),
				],
			),
			LevelGraphNode.new(
				Level.new(Level.LevelType.NORMAL, [creature_data["Katze"], creature_data["Katze"], creature_data["Katze"]], [
					creature_data["Gehirnmaulwurf"],
					creature_data["Splitterseele"],
					creature_data["Gehirnmaulwurf"],
					creature_data["Zyklop"],
				]),
				[
					LevelGraphNode.new(
						Level.new(Level.LevelType.NORMAL, [creature_data["Roter Panda"]], [
							creature_data["Kobold-Mech"],
							creature_data["Kobold-Mech"],
							creature_data["Kobold-Mech"],
						]),
						[bossNode],
					),
				],
			)
		]
	)
	
	create_new_deck()
func create_new_deck() -> void :
	deck = []
	for data in basic_card_datas:
		for i in range(data.amount_of_repetitions):
			deck.append(data)
	resetLevelTree(levelTree)

func resetLevelTree(node: LevelGraphNode)->void:
	node.level.completed = false
	for child in node.children:
		resetLevelTree(child)
