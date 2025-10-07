extends Node
class_name CardManager

@onready var hand: CardContainer = %Cards
@onready var draw_pile: GridContainer = %InnerDrawPile
@onready var discard_pile: GridContainer = %InnerDiscardPile
@onready var negative_sound_effect :AudioAssetWithMetadata= preload("res://assets/AudioResources/SFX/magnetOff.tres")

var cards_loaded := 0

signal needs_ui_update(discard_pile_child_count: int, draw_pile_child_count: int)
signal card_added_to_deck(card: CardController)
signal deck_loaded
signal card_added_to_hand(card: CardController)
signal card_removed_from_hand(card: CardController)
signal needs_battlefield_update

signal cardplay_success(card: CardController)
signal cardplay_fail(card: CardController)


func play_card(card: CardController, type: SceneController.Playtype):
	var cond_expr: Expr= null
	var effect_expr: Expr = null
	var sound: AudioStream = null
	if type == SceneController.Playtype.CREATURE:
		cond_expr = card.card_data.creature_cond_expr
		effect_expr = card.card_data.creature_effect_expr
		sound = card.card_data.creature_effect_play_sound.sound
	else:
		cond_expr = card.card_data.spell_cond_expr
		effect_expr = card.card_data.spell_effect_expr
		sound = card.card_data.spell_effect_play_sound.sound
	var success := Evaluator.evaluate(cond_expr) as bool
	if success:
		Evaluator.evaluate(effect_expr)
		needs_battlefield_update.emit()
		MusicPlayer.play_sfx(sound)
		await _add_to_discard_pile(card)
		cardplay_success.emit(card)
	else:
		sound = negative_sound_effect.sound
		MusicPlayer.play_sfx(sound)
		_add_to_discard_pile(card)
		await _discard_random_card(card)
		cardplay_fail.emit(card)



func create_deck(deck: Array[CardData] = Global.deck) -> void:
	cards_loaded = 0
	for card in deck:
		var card_instance: CardController = Global.card_scene.instantiate() as CardController
		card_instance.card_data = card
		draw_pile.add_child(card_instance)
		card_added_to_deck.emit(card_instance)
	for card in draw_pile.get_children():
		if card.latex_loaded:
			_on_latex_loaded()
		else:
			card.latex_finished_loading.connect(_on_latex_loaded)
	needs_battlefield_update.emit()
	needs_ui_update.emit(discard_pile.get_child_count(), draw_pile.get_child_count())

func _on_latex_loaded() -> void:
	cards_loaded += 1
	if cards_loaded == draw_pile.get_child_count():
		deck_loaded.emit()

func draw_cards(amount: int) -> void:
	var picked_cards: Array[CardController] = []
	for i in range(amount):
		if draw_pile.get_child_count() == 0:
			_refill_draw_pile()
		var drawable_cards: = draw_pile.get_children()
		var picked_card: CardController = drawable_cards.pick_random() as CardController
		_add_to_hand(picked_card)
		picked_cards.append(picked_card)
		picked_card.hide()
	await hand.layout_cards()
	for card in picked_cards:
		card.show()
		await card.animate_draw_card()

func _discard_random_card(except : CardController) -> void:
	var cards := hand.get_children()
	if len(cards) <= 1:
		return
	var card := cards.pick_random() as CardController
	while card == except:
		card = cards.pick_random() as CardController
	await _add_to_discard_pile(card)


func discard_hand() -> void:
	var cards := hand.get_children()
	await _add_cards_to_discard_pile(cards)

func _refill_draw_pile():
	for card in discard_pile.get_children():
		card.reparent(draw_pile)
	needs_ui_update.emit(discard_pile.get_child_count(), draw_pile.get_child_count())

func _add_to_hand(card: CardController) -> void:
	card.reparent(hand)
	needs_ui_update.emit(discard_pile.get_child_count(), draw_pile.get_child_count())
	card_added_to_hand.emit(card)




func _add_cards_to_discard_pile(cards: Array[Node]) -> void:
	for card_idx in cards.size():
		var card := cards[card_idx] as CardController
		if card_idx == cards.size() - 1:
			await card.animate_discard_card()
		else:
			card.animate_discard_card()
	for card in cards:
		card.reparent(discard_pile)
		needs_ui_update.emit(discard_pile.get_child_count(), draw_pile.get_child_count())
		card_removed_from_hand.emit(card)
	await hand.layout_cards()


func _add_to_discard_pile(card: CardController) -> void:
	if card not in hand.get_children():
		return
	await card.animate_discard_card()
	card.reparent(discard_pile)
	needs_ui_update.emit(discard_pile.get_child_count(), draw_pile.get_child_count())
	card_removed_from_hand.emit(card)
	await hand.layout_cards()
