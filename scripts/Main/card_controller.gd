class_name CardController
extends Control

# UI references
@onready var creature_cond_node: Node = %CreatureCondition
@onready var creature_effect_node: Node = %CreatureEffect
@onready var spell_cond_node: Node = %SpellCondition
@onready var spell_effect_node: Node = %SpellEffect


var latex_loaded:=false

# Signals
signal latex_entered(latex: String)
signal latex_exited()
signal card_clicked(card: CardController)
signal latex_finished_loading()

@export var card_data: CardData

func _ready() -> void:
	var cd = card_data
	if cd != null:
		await Evaluator.update_latex(creature_cond_node,   cd.creature_cond_expr)
		await Evaluator.update_latex(creature_effect_node, cd.creature_effect_expr)
		await Evaluator.update_latex(spell_cond_node,      cd.spell_cond_expr)
		await Evaluator.update_latex(spell_effect_node,    cd.spell_effect_expr)


	connect_hover_signals([creature_cond_node,
						   creature_effect_node,
						   spell_cond_node,
						   spell_effect_node])
	latex_loaded = true
	latex_finished_loading.emit()



func connect_hover_signals(latex_nodes: Array) -> void:
	for latex_node in latex_nodes:
		latex_node.mouse_entered.connect(func(): latex_entered.emit(latex_node.LatexExpression))
		latex_node.mouse_exited.connect(func(): latex_exited.emit())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_clicked.emit(self)


func animate_draw_card() -> void:
	# start below normal margin_top (so it appears "below" the container line)
	offset_top = size.y * 2
	var tween = get_tree().create_tween()
	var overshoot_amount := -size.y / 8  # a little upward bounce
	tween.tween_property(self, "offset_top", overshoot_amount, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_top", 0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished



	
func animate_discard_card() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, size.y * 2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
