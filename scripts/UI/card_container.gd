@tool
extends Control
class_name CardContainer


func _ready():
	if Engine.is_editor_hint():
		layout_cards()

func _notification(what):
	if what == NOTIFICATION_CHILD_ORDER_CHANGED or what == NOTIFICATION_READY or what == NOTIFICATION_DRAW:
		if Engine.is_editor_hint() and get_tree() != null:
			layout_cards()

func create_layout_tween() -> Tween:
	var cards = get_children()
	var total_cards = cards.size()
	if total_cards == 0:
		return null

	var tween = get_tree().create_tween()

	var target_positions = []
	if total_cards == 1:
		if cards[0] is Control:
			var target_x = size.x / 2 - cards[0].size.x / 2
			var target_position = Vector2(target_x, 0)
			target_positions.append(target_position)
	else:
		var card_width = cards[0].size.x
		var empty_space = size.x - card_width * total_cards
		assert(total_cards > 1)
		var space_between_cards = empty_space / (total_cards + 1)
		for i in range(total_cards):
			var card = cards[i]
			if card is Control:
				var target_x = space_between_cards * (i + 1) + card_width * i
				var target_position = Vector2(target_x, 0)
				target_positions.append(target_position)
	for i in range(total_cards):
		var card = cards[i]
		tween.parallel().tween_property(
					card, "position",
					target_positions[i],
					0.3
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween

func layout_cards():
	var tween := create_layout_tween()
	if tween != null:
		await tween.finished
