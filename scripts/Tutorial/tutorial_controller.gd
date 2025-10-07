extends Node
class_name TutorialController

var hand: CardContainer
var drawpile: GridContainer
var play_areas: HBoxContainer
@onready var example_card_container : Control = %ExampleCardContainer
var example_card: CardController
@onready var highlight_layer: CanvasLayer = %Highlight
@onready var background_layer: CanvasLayer = %Background
@onready var background_layer2: CanvasLayer = %Background2

@onready var button_sound_asset: AudioAssetWithMetadata = preload("res://assets/AudioResources/SFX/item_wood.tres")

var current_state := 0
var text_boxes : Array[Control] = []


var creature_cond :NinePatchRect
var creature_effect :NinePatchRect
var creature_area: Control
var spell_cond :NinePatchRect
var spell_effect :NinePatchRect
var spell_area :Control
var ui_manager: UIManager
var battlefield_manager: BattlefieldManager
var card_manager: CardManager
var start_fight_button: Button
var battle_manager: BattleManager
var scene_controller: SceneController
var settings_button: Button
var open_creature_overview_button: Button
var drawpile_button: Button
var discardpile_button: Button
var ghost_control: Panel

signal disable_card(card:CardController)
signal enable_card(card:CardController)

func setup(
	p_hand: CardContainer, 
	p_drawpile: Control, 
	p_play_areas: HBoxContainer,
	p_ui_manager: UIManager, 
	p_battlefield_manager:BattlefieldManager,
	p_card_manager: CardManager,
	p_start_fight_button: Button,
	p_battle_manager: BattleManager,
	p_scene_controller: SceneController,
	p_settings_button: Button,
	p_open_creature_overview_button: Button,
	p_drawpile_button: Button,
	p_discardpile_button: Button,
	) -> void:
		
	hand = p_hand
	drawpile = p_drawpile
	play_areas = p_play_areas
	ui_manager = p_ui_manager
	battlefield_manager = p_battlefield_manager
	card_manager = p_card_manager
	start_fight_button = p_start_fight_button
	battle_manager = p_battle_manager
	scene_controller = p_scene_controller
	
	settings_button = p_settings_button
	open_creature_overview_button = p_open_creature_overview_button
	drawpile_button = p_drawpile_button
	discardpile_button = p_discardpile_button
	
	example_card = Global.card_scene.instantiate() as CardController
	example_card.card_data = Global.tutorial_card_datas[0]
	example_card.latex_finished_loading.connect(scene_controller.splash_screen.hide)
	add_card_to_container(example_card)
	creature_cond= example_card.creature_cond_node.get_parent()
	creature_effect= example_card.creature_effect_node.get_parent()
	creature_area = creature_cond.get_parent() as Control
	spell_cond = example_card.spell_cond_node.get_parent()
	spell_effect = example_card.spell_effect_node.get_parent()
	spell_area = spell_cond.get_parent() as Control
	ghost_control = Panel.new()
	
	
	
	
	
	
	for text_box in highlight_layer.get_children():
		text_boxes.append(text_box as Control)
	start_fight_button.set_disabled(true)
	enable_card.connect(ui_manager.add_latex_hovering_effects)
	enable_card.connect(scene_controller.add_card_signals)
	disable_card.connect(scene_controller.remove_card_signals)
	disable_card.connect(func(c:CardController): c.latex_exited.emit())
	disable_card.connect(ui_manager.remove_latex_hovering_effects)
	battlefield_manager.load_creatures_from_level(
			Level.new(
				Level.LevelType.NORMAL, 
				[], 
				[]
				)
			)

func add_card_to_container(card: CardController)-> void:
	card.scale = Vector2(2,2)
	if card.get_parent() == null:
		example_card_container.add_child(card)
	else:
		card.reparent(example_card_container)
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	card.position = Vector2(-card.size.x, -card.size.y)

func add_card_to_hand(card: CardController) -> void:
	var global_pos = card.global_position
	if card.get_parent() == null:
		hand.add_child(card)
	else:
		card.reparent(hand)
	card.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_KEEP_SIZE)
	card.global_position = global_pos
	var tween  = hand.create_layout_tween()
	var prev_scale = Vector2(card.scale)
	tween.parallel().tween_property(
					card, "scale",
					Vector2(1,1),
					0.3
				).from(prev_scale).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	


var parents_of_highlighted_things:Dictionary[Control,Node] = {}

func highlight(thing: Control, p_scale:int = 2) -> void:
	parents_of_highlighted_things[thing] = thing.get_parent()
	var s := thing.size
	thing.reparent(highlight_layer)
	thing.scale = Vector2(p_scale,p_scale)
	thing.size = s

func hide_highlight(thing: Control) -> void:
	thing.scale = Vector2(1,1)
	thing.reparent(parents_of_highlighted_things[thing])

func _on_next_button_down() -> void:
	if current_state >= len(text_boxes) - 1:
		return
	MusicPlayer.play_sfx(button_sound_asset.sound)
	update_tutorial(NEXT_STEP_IS.HIGHER)



func _on_previous_button_down() -> void:
	if current_state <= 0:
		return
	MusicPlayer.play_sfx(button_sound_asset.sound)
	update_tutorial(NEXT_STEP_IS.LOWER)

func update_tutorial(next_step: NEXT_STEP_IS)->void:
	hide_step(next_step)
	if (next_step == NEXT_STEP_IS.HIGHER):
		current_state += 1
	else:
		current_state -= 1
	show_step(next_step)

enum NEXT_STEP_IS{
	HIGHER, LOWER
}

func hide_step(next_step: NEXT_STEP_IS) -> void:
	text_boxes[current_state].hide()
	match current_state:
		1:
			hide_highlight(creature_area)
			creature_area.get_parent().remove_child(ghost_control)
			creature_area.get_parent().move_child(creature_area, 0)
		2:
			hide_highlight(spell_area)
		3:
			hide_highlight(creature_area)
			creature_area.get_parent().remove_child(ghost_control)
			creature_area.get_parent().move_child(creature_area, 0)
		4:
			hide_highlight(creature_area)
			creature_area.get_parent().remove_child(ghost_control)
			creature_area.get_parent().move_child(creature_area, 0)
		5:
			hide_highlight(creature_cond)
		6:
			hide_highlight(creature_effect)
		7:
			hide_highlight(example_card)
			example_card.scale = Vector2(2,2)
		8:
			var c :CardController= null
			for card in hand.get_children():
				if card == example_card:
					if next_step == NEXT_STEP_IS.LOWER:
						add_card_to_container(example_card)
					continue
				c = card
				card.queue_free()
				
			await c.tree_exited
			await hand.layout_cards()
		9:
			pass
		10:
			if next_step == NEXT_STEP_IS.LOWER:
				play_areas.get_node("%CreatureHighlightBorder").hide()
				hide_highlight(play_areas)
			else:
				play_areas.get_node("%CreatureHighlightBorder").hide()
		11:
			play_areas.get_node("%SpellHighlightBorder").hide()
		12:
			pass
		13:
			background_layer.show()
			background_layer2.show()
		16:
			background_layer.show()
			background_layer2.show()
		24:
			get_parent().mouse_filter = Control.FOCUS_NONE
		26:
			background_layer.show()
			background_layer2.show()
			get_parent().show()
			play_areas.show()
		28:
			background_layer.show()
			background_layer2.show()
			get_parent().show()
			play_areas.show()
		31:
			hide_highlight(settings_button)
		32:
			hide_highlight(open_creature_overview_button)
		33:
			hide_highlight(drawpile_button)
		34:
			hide_highlight(discardpile_button)
		_:
			pass


func show_step(next_step: NEXT_STEP_IS) -> void:
	text_boxes[current_state].show()
	match current_state:
		1:
			creature_area.get_parent().add_child(ghost_control)
			creature_area.get_parent().move_child(ghost_control, 0)
			ghost_control.custom_minimum_size.y = creature_area.custom_minimum_size.y
			highlight(creature_area)
		2:
			highlight(spell_area)
		3:
			creature_area.get_parent().add_child(ghost_control)
			creature_area.get_parent().move_child(ghost_control, 0)
			ghost_control.custom_minimum_size.y = creature_area.custom_minimum_size.y
			highlight(creature_area)
		4:
			creature_area.get_parent().add_child(ghost_control)
			creature_area.get_parent().move_child(ghost_control, 0)
			ghost_control.custom_minimum_size.y = creature_area.custom_minimum_size.y
			highlight(creature_area)
		5:
			highlight(creature_cond)
		6:
			highlight(creature_effect)
		7:
			highlight(example_card) # mehr karten?
		8:
			highlight(hand, 1)
			for i in range(5):
				var card := Global.card_scene.instantiate() as CardController
				card.card_data = Global.tutorial_card_datas[0]
				add_card_to_hand(card)
			example_card.scale = Vector2(2,2)
			await add_card_to_hand(example_card)
		9: 
			pass
		10:
			if next_step == NEXT_STEP_IS.HIGHER:
				play_areas.get_node("%CreatureHighlightBorder").show()
				highlight(play_areas, 1)
			else:
				play_areas.get_node("%CreatureHighlightBorder").show()
		11:
			play_areas.get_node("%SpellHighlightBorder").show()
		12: 
			enable_card.emit(example_card)
			play_areas.reparent(get_parent().get_parent())
			background_layer.hide()
			background_layer2.hide() 
			ui_manager.disable_spell_play_area() 
			card_manager.cardplay_success.connect(func(_c):
				hide_step(NEXT_STEP_IS.HIGHER)
				current_state = 13
				update_tutorial(NEXT_STEP_IS.HIGHER), CONNECT_ONE_SHOT)#hier direkt spielen lassen und 13 überspringen?
		13:
			pass
		16:
			#text_boxes[current_state].hide()
			background_layer.hide()
			background_layer2.hide()
			#get_parent().hide()
			for i in range(3):
				var card := Global.card_scene.instantiate() as CardController
				card.card_data = Global.tutorial_card_datas[0]
				add_card_to_hand(card)
			for card in hand.get_children():
				enable_card.emit(card)
			card_manager.cardplay_fail.connect(
					func(_c):
						hide_step(NEXT_STEP_IS.HIGHER)
						current_state = 17
						update_tutorial(TutorialController.NEXT_STEP_IS.HIGHER)
						, CONNECT_ONE_SHOT)
		18:
			for card in hand.get_children():
				disable_card.emit(card)
		22:
			var arch_data:=Global.creature_data["Archäologe"].duplicate()
			arch_data.attack_value = 7
			arch_data.defense = 3
			arch_data.health = 13
			battlefield_manager.load_creatures_from_level(
			Level.new(
				Level.LevelType.NORMAL, 
				[
					Global.creature_data["Roter Panda"],
					Global.creature_data["Roter Panda"],
				], 
				[
					arch_data,
				]
				)
			)
			for card in hand.get_children():
				enable_card.emit(card) #we need to enable, because discard_hand removes the signals 
			card_manager.discard_hand()
		24:
			background_layer.hide()
			background_layer2.hide()
			get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
			start_fight_button.set_disabled(false)
			play_areas.hide()
			battle_manager.combat_finished.connect(func(_r):
				update_tutorial(NEXT_STEP_IS.HIGHER), CONNECT_ONE_SHOT)
		25:
			play_areas.show()
			example_card = Global.card_scene.instantiate() as CardController
			example_card.card_data = Global.tutorial_card_datas[0]
			example_card.hide()
			await add_card_to_hand(example_card)
			example_card.show()
			ui_manager.enable_spell_play_area()
			ui_manager.disable_creature_play_area()
			enable_card.emit(example_card)
			card_manager.cardplay_success.connect(func(_c):
						hide_step(NEXT_STEP_IS.HIGHER)
						current_state = 26
						update_tutorial(NEXT_STEP_IS.HIGHER), CONNECT_ONE_SHOT)
		26:
			pass
			#text_boxes[current_state].hide()
			#background_layer.hide()
			#background_layer2.hide()
			#get_parent().hide()
			#enable_card.emit(example_card)
			#card_manager.cardplay_success.connect(func(_c):update_tutorial(NEXT_STEP_IS.HIGHER), CONNECT_ONE_SHOT)
		27:
			hide_highlight(hand)
			background_layer.hide()
			background_layer2.hide()
			start_fight_button.set_disabled(false)
			play_areas.hide()
			get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
			battle_manager.combat_finished.connect(
				func(_r):
					start_fight_button.set_disabled(false)
					update_tutorial(NEXT_STEP_IS.HIGHER)
					battle_manager.combat_finished.connect(func(__r):
						update_tutorial(NEXT_STEP_IS.HIGHER)
						, CONNECT_ONE_SHOT)
					, CONNECT_ONE_SHOT)
		31:
			highlight(settings_button, 1)
		32:
			highlight(open_creature_overview_button, 1)
		33:
			highlight(drawpile_button, 1)
		34:
			highlight(discardpile_button, 1)
		40:
			Global.isTutorial = false
			get_tree().change_scene_to_file("res://mainMenuScene.tscn")
		_:
			pass
	
