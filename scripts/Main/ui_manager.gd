extends Node
class_name UIManager

#-----------------------------------------------------------------------------
# EXPORTED VARIABLES
#-----------------------------------------------------------------------------
@export var hover_over_offset := 10

#-----------------------------------------------------------------------------
# ONREADY VARIABLES
#-----------------------------------------------------------------------------
@onready var big_latex: Latex = %Latex
@onready var ally_borders: HBoxContainer = %AllyBorders
@onready var blocking_layer: Control = %BlockingLayer
@onready var arrow: Line2D = %Arrow
@onready var hover_over_information_box: VBoxContainer = %HoverOverInformationBox
@onready var hand: CardContainer = %Cards
@onready var creature_play_area: Control = %CreaturePlayArea
@onready var creature_highlight_border: NinePatchRect = %CreatureHighlightBorder
@onready var spell_play_area: Control = %SpellPlayArea
@onready var spell_highlight_border: NinePatchRect = %SpellHighlightBorder
@onready var draw_pile_button: Button = %DrawPileButton
@onready var draw_pile_count: Label = %DrawPileCount
@onready var discard_pile_button: Button = %DiscardPileButton
@onready var discard_pile_count: Label = %DiscardPileCount
@onready var draw_pile_container: Control = %DrawPile
@onready var discard_pile_container: Control = %DiscardPile

@onready var draw_pile_close_button: Button = %DrawpileCloseButton
@onready var discard_pile_close_button: Button = %DiscardpileCloseButton
@onready var open_creature_overview_button: Button = %OpenCreatureOverviewButton
@onready var creature_overview = %CreatureOverview
#-----------------------------------------------------------------------------
# MEMBER VARIABLES
#-----------------------------------------------------------------------------
var creature_information_element_scene   = preload("res://scripts/Creatures/creature_information_element.tscn")
var attributes_information_element_scene = preload("res://scripts/Creatures/attributes_information_element.tscn")

var current_card: CardController
var mentioned_creatures: Array[CreatureData]
var mentioned_attributes: Array[CreatureData.Attributes]
var attack_patterns: Array[CreatureData.AttackPattern]
var mouse_inside_creature_area := false
var mouse_inside_spell_area    := false

var mouse_enter_creature_callbacks: Dictionary[CreatureInstance, Callable] = {}
var mouse_exit_creature_callbacks: Dictionary[CreatureInstance, Callable] = {}

var _available_creature_information_elements: Array[CreatureInformationElement]
var _available_attributes_information_elements: Array[AttributesInformationElement]

var spell_area_is_disabled := false
var creature_area_is_disabled := false



#-----------------------------------------------------------------------------
# CORE UI METHODS
#-----------------------------------------------------------------------------

func setup() -> void:
	draw_pile_button.pressed.connect(draw_pile_container.show)
	draw_pile_close_button.pressed.connect(draw_pile_container.hide)
	discard_pile_button.pressed.connect(discard_pile_container.show)
	discard_pile_close_button.pressed.connect(discard_pile_container.hide)
	open_creature_overview_button.pressed.connect(creature_overview.show)
	
	draw_pile_button.pressed.connect(MusicPlayer.button_click_sound)
	draw_pile_close_button.pressed.connect(MusicPlayer.button_click_sound)
	discard_pile_button.pressed.connect(MusicPlayer.button_click_sound)
	discard_pile_close_button.pressed.connect(MusicPlayer.button_click_sound)
	open_creature_overview_button.pressed.connect(MusicPlayer.button_click_sound)

func update_ui(mouse_position: Vector2) -> void:
	if current_card:
		update_arrow(mouse_position)
		ally_borders.show()
	else:
		blocking_layer.hide()
		ally_borders.hide()
		arrow.visible = false
	if mentioned_creatures.is_empty() and mentioned_attributes.is_empty() and attack_patterns.is_empty():
		hover_over_information_box.hide()
	else:
		hover_over_information_box.show()
		var size_x = 0
		var size_y = 0
		assert(len(mentioned_creatures)<=len(_available_creature_information_elements))
		assert(len(mentioned_attributes) + len(attack_patterns)<=len(_available_attributes_information_elements))
		for index in len(mentioned_creatures):
			size_y += _available_creature_information_elements[index].size.y
			size_x = max(size_x, _available_creature_information_elements[index].size.x)
		for index in len(mentioned_attributes):
			size_y += _available_attributes_information_elements[index].size.y
			size_x = max(size_x, _available_attributes_information_elements[index].size.x)
		for index in len(attack_patterns):
			size_y += _available_attributes_information_elements[index + len(mentioned_attributes)].size.y
			size_x = max(size_x, _available_attributes_information_elements[index + len(mentioned_attributes)].size.x)
		var hover_box_pos = mouse_position
		if hover_box_pos.x + hover_over_offset + size_x >= 2560:
			hover_box_pos.x -= (size_x + hover_over_offset)
		else:
			hover_box_pos.x += hover_over_offset

		if hover_box_pos.y + hover_over_offset + size_y >= 1440:
			hover_box_pos.y -= (size_y + hover_over_offset)
		else:
			hover_box_pos.y += hover_over_offset
		hover_over_information_box.global_position = hover_box_pos

func update_feedback_ui(discard_pile_child_count: int, draw_pile_child_count: int) -> void:
	discard_pile_count.text = str(discard_pile_child_count)
	draw_pile_count.text = str(draw_pile_child_count)


func on_card_clicked(card: CardController) -> void:
	current_card = card
	on_latex_exited()

func reset_card() -> void:
	current_card = null
	arrow.visible = false
	hide_creature_play_area_highlight()
	hide_spell_play_area_highlight()

#-----------------------------------------------------------------------------
# ARROW DRAWING
#-----------------------------------------------------------------------------
func update_arrow(mouse_position: Vector2) -> void:
	blocking_layer.show()
	arrow.visible = true

	var from_pos = current_card.global_position
	from_pos.x += current_card.size.x * hand.scale.x / 2.0
	var to_pos   = mouse_position

	draw_arrow(from_pos, to_pos)

	update_highlight(creature_play_area, show_creature_play_area_highlight, teaser_creature_play_area_highlight, mouse_position)
	update_highlight(spell_play_area, show_spell_play_area_highlight, teaser_spell_play_area_highlight, mouse_position)

func draw_arrow(from_pos: Vector2, to_pos: Vector2) -> void:
	arrow.clear_points()
	arrow.add_point(from_pos)
	arrow.add_point(to_pos)

	var dir    =  (from_pos - to_pos).normalized()
	var perp   =  Vector2(-dir.y, dir.x)
	var length := 20.0
	var width  := 20.0

	var tip   = to_pos
	var base1 = tip + dir * length + perp * width / 2.0
	var base2 = tip + dir * length - perp * width / 2.0

	arrow.add_point(base1)
	arrow.add_point(tip)
	arrow.add_point(base2)

#-----------------------------------------------------------------------------
# PLAY AREA HIGHLIGHTING
#-----------------------------------------------------------------------------
func update_highlight(area: Control, show_func: Callable, teaser_func: Callable, mouse_position: Vector2) -> void:
	var mouse_pos = mouse_position
	if area.get_global_rect().has_point(mouse_pos):
		show_func.call()
	else:
		teaser_func.call()

func show_creature_play_area_highlight() -> void:
	if creature_area_is_disabled:
		return
	if len(Evaluator.allies) < 5:
		highlight_area(creature_highlight_border, 1.0)
		mouse_inside_creature_area = true
	else:
		highlight_area(creature_highlight_border, 0.1)

func hide_creature_play_area_highlight() -> void:
	if creature_area_is_disabled:
		return
	creature_highlight_border.hide()
	mouse_inside_creature_area = false

func teaser_creature_play_area_highlight() -> void:
	if creature_area_is_disabled:
		return
	if len(Evaluator.allies) < 5:
		highlight_area(creature_highlight_border, 0.5)
		mouse_inside_creature_area = false
	else:
		highlight_area(creature_highlight_border, 0.1)

func show_spell_play_area_highlight() -> void:
	if spell_area_is_disabled:
		return
	highlight_area(spell_highlight_border, 1.0)
	mouse_inside_spell_area = true

func hide_spell_play_area_highlight() -> void:
	if spell_area_is_disabled:
		return
	spell_highlight_border.hide()
	mouse_inside_spell_area = false

func teaser_spell_play_area_highlight() -> void:
	if spell_area_is_disabled:
		return
	highlight_area(spell_highlight_border, 0.5)
	mouse_inside_spell_area = false

func highlight_area(border: NinePatchRect, alpha: float) -> void:
	border.show()
	border.modulate.a = alpha

#-----------------------------------------------------------------------------
# HOVER INFORMATION (LATEX/CREATURES/ATTRIBUTES)
#-----------------------------------------------------------------------------
func on_latex_entered(latex: String) -> void:
	await big_latex.set_latex_expression(latex)
	big_latex.show()
	show_potential_creatures(latex)
	show_potential_attributes(latex)

func on_latex_exited() -> void:
	big_latex.hide()
	mentioned_creatures = []
	mentioned_attributes = []
	attack_patterns = []
	for element in _available_attributes_information_elements:
		element.hide()
	for element in _available_creature_information_elements:
		element.hide()

func show_potential_creatures(latex: String) -> void:
	mentioned_creatures = []
	for creature_name in Global.creature_data:
		if latex.contains(creature_name):
			mentioned_creatures.append(Global.creature_data[creature_name])
	for _i in range(mentioned_creatures.size() - _available_creature_information_elements.size()):
		var element = creature_information_element_scene.instantiate()
		_available_creature_information_elements.append(element)
		hover_over_information_box.add_child(element)
		hover_over_information_box.move_child(element, 0)

	for element_index in _available_creature_information_elements.size():
		var element: CreatureInformationElement = _available_creature_information_elements[element_index]
		if element_index < mentioned_creatures.size():
			element.show()
			element.set_creature_data(mentioned_creatures[element_index], true)
		else:
			element.hide()

func show_potential_attributes(latex: String) -> void:
	reset_mentioned_attributes()
	add_latex_attributes(latex)
	add_creature_attributes(mentioned_creatures)
	add_attack_patterns(mentioned_creatures)

func reset_mentioned_attributes() -> void:
	mentioned_attributes = []
	attack_patterns = []

func add_latex_attributes(latex: String) -> void:
	for attribute_name in CreatureData.attribute_dict.keys():
		if attribute_name in ["Klein", "Mittel", "Groß"]:
			continue
		if latex.contains(attribute_name):
			var attribute := CreatureData.attribute_dict[attribute_name]
			if !mentioned_attributes.has(attribute):
				mentioned_attributes.append(attribute)

func add_creature_attributes(creatures: Array[CreatureData]) -> void:
	for creature in creatures:
		for attribute in creature.attributes:
			if attribute in [CreatureData.Attributes.Small, CreatureData.Attributes.Medium, CreatureData.Attributes.Large]:
				continue
			if !mentioned_attributes.has(attribute):
				mentioned_attributes.append(attribute)
	add_attribute_instances_to_pool()
	show_attribute_elements()

func add_attack_patterns(creatures: Array[CreatureData]) -> void:
	for creature in creatures:
		attack_patterns.append(creature.attack_pattern)
	add_attribute_instances_to_pool()
	show_attack_patterns_elements()

func add_attribute_instances_to_pool() -> void:
	for _i in range((mentioned_attributes.size() + attack_patterns.size()) - _available_attributes_information_elements.size()):
		var element = attributes_information_element_scene.instantiate()
		_available_attributes_information_elements.append(element)
		hover_over_information_box.add_child(element)
		hover_over_information_box.move_child(element, hover_over_information_box.get_child_count() - 1)

func show_attribute_elements() -> void:
	for element_index in _available_attributes_information_elements.size():
		var element: AttributesInformationElement = _available_attributes_information_elements[element_index]
		if element_index < mentioned_attributes.size():
			element.show()
			element.set_attribute(mentioned_attributes[element_index])
		else:
			element.hide()

func show_attack_patterns_elements() -> void:
	for i in attack_patterns.size():
		var element_index = mentioned_attributes.size() + i
		var element: AttributesInformationElement = _available_attributes_information_elements[element_index]
		if element_index < mentioned_attributes.size() + attack_patterns.size():
			element.show()
			match attack_patterns[i]:
				CreatureData.AttackPattern.FRONT: element.set_text("Greift vorne an")
				CreatureData.AttackPattern.BACK: element.set_text("Greift hinten an")
				CreatureData.AttackPattern.RANDOM: element.set_text("Greift zufällig an")
				CreatureData.AttackPattern.ALL: element.set_text("Greift alle an")
		else:
			element.hide()

#-----------------------------------------------------------------------------
# SIGNAL MANAGEMENT
#-----------------------------------------------------------------------------
func add_latex_hovering_effects(card: CardController)->void:
	card.latex_entered.connect(on_latex_entered)
	card.latex_exited.connect(on_latex_exited)

func remove_latex_hovering_effects(card: CardController)->void:
	card.latex_entered.disconnect(on_latex_entered)
	card.latex_exited.disconnect(on_latex_exited)

func add_creature_signals(creature: CreatureInstance) -> void:
	mouse_enter_creature_callbacks[creature] = func():
		add_creature_attributes([creature.template])
		add_attack_patterns([creature.template])
	creature.creature_with_overlay.sprite_container.mouse_entered.connect(mouse_enter_creature_callbacks[creature])
	creature.creature_with_overlay.sprite_container.mouse_exited.connect(reset_mentioned_attributes)

func remove_creature_signals(creature: CreatureInstance) -> void:
	creature.creature_with_overlay.sprite_container.mouse_entered.disconnect(mouse_enter_creature_callbacks[creature])
	creature.creature_with_overlay.sprite_container.mouse_exited.disconnect(reset_mentioned_attributes)

#-----------------------------------------------------------------------------
# TUTORIAL SPECIAL
#-----------------------------------------------------------------------------
func disable_spell_play_area():
	spell_area_is_disabled = true

func enable_spell_play_area():
	spell_area_is_disabled = false

func disable_creature_play_area():
	creature_area_is_disabled = true

func enable_creaturel_play_area():
	creature_area_is_disabled = false
