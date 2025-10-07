extends Control
class_name RewardScreen

signal card_selected(card_data: CardData)
signal card_added_to_selection(card: CardContainer)

@onready var card_container: HBoxContainer = $CardContainer

const CARD_SCENE := preload("res://cardScene.tscn")

func show_rewards() -> void:
	for child in card_container.get_children():
		child.queue_free()

	var possible_cards = Global.basic_card_datas + Global.advanced_card_datas
	possible_cards.shuffle()
	possible_cards = possible_cards.slice(0, 3)
		
	for data in possible_cards:
		var card_instance := CARD_SCENE.instantiate() as CardController
		card_instance.card_data = data
		card_instance.card_clicked.connect(_on_card_clicked)
		card_added_to_selection.emit(card_instance)
		card_container.add_child(card_instance)
		card_instance.animate_draw_card()
	show() 
	

func _on_card_clicked(card: CardController) -> void:
	card_selected.emit(card.card_data)
	MusicPlayer.button_click_sound()
	hide()
