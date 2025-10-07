extends Node2D
class_name SceneController

# Node references
# Main Scene stuff
@onready var lose_screen := %LoseScreen
@onready var reward_screen: RewardScreen = %RewardScreen
@onready var start_fight_button: Button = %StartFightButton
@onready var splash_screen: TextureRect = %SplashScreen

@onready var battle_manager: BattleManager = %BattleManager
@onready var animation_manager: AnimationManager = %AnimationManager
@onready var battlefield_manager: BattlefieldManager = %BattlefieldManager
@onready var card_manager: CardManager = %CardManager
@onready var ui_manager: UIManager = %UIManager

@onready var win_sound: AudioAssetWithMetadata = preload("res://assets/AudioResources/SFX/win.tres")
@onready var loose_sound: AudioAssetWithMetadata = preload("res://assets/AudioResources/SFX/loose.tres")

@onready var tutorial_scene := preload("res://scenes/tutorial.tscn")
var tutorial_controller :TutorialController
# Setup
func _ready() -> void:
	splash_screen.show()
	if Global.isTutorial:
		_connectSignals()
		battle_manager.combat_finished.disconnect(_start_card_playing_phase)
		var instance := tutorial_scene.instantiate()
		add_child(instance)
		tutorial_controller = instance.get_node("%TutorialController")
		tutorial_controller.setup(
			%Cards, 
			%InnerDrawPile,
			%PlayAreas, 
			ui_manager, 
			battlefield_manager, 
			card_manager,
			start_fight_button,
			battle_manager,
			self,
			%SettingsButton,
			%OpenCreatureOverviewButton,
			%DrawPileButton,
			%DiscardPileButton
			)
		
	else:
		ui_manager.setup()
		_connectSignals() 
		start_fight_button.set_disabled(true)
		battlefield_manager.load_creatures_from_level(Global.currentLevel)
		card_manager.create_deck()

func _connectSignals() -> void:
	animation_manager.all_animation_finished.connect(battle_manager.continue_combat.emit)
	
	battlefield_manager.creatureAddedToContainer.connect(ui_manager.add_creature_signals)
	battlefield_manager.creatureRemovedFromContainer.connect(ui_manager.remove_creature_signals)
	
	battle_manager.attack_animation.connect(animation_manager.on_animate_attack)
	battle_manager.combat_finished.connect(_start_card_playing_phase)
	battle_manager.remove_creature.connect(battlefield_manager.on_creature_died)
	
	reward_screen.card_added_to_selection.connect(ui_manager.add_latex_hovering_effects)
	reward_screen.card_selected.connect(_on_reward_card_selected)
	
	
	#card_manager.cardplay_success.connect(print)
	#card_manager.cardplay_fail.connect(print)
	card_manager.card_added_to_deck.connect(ui_manager.add_latex_hovering_effects)
	card_manager.deck_loaded.connect(_finish_setup)
	card_manager.card_added_to_hand.connect(add_card_signals)
	card_manager.card_removed_from_hand.connect(remove_card_signals)
	card_manager.needs_battlefield_update.connect(battlefield_manager.update_containers)
	card_manager.needs_ui_update.connect(ui_manager.update_feedback_ui)
	
	start_fight_button.pressed.connect(_start_autobattler)
	





func add_card_signals(card: CardController) -> void:
	card.card_clicked.connect(ui_manager.on_card_clicked)


func remove_card_signals(card: CardController) -> void:
	card.card_clicked.disconnect(ui_manager.on_card_clicked)


func _finish_setup() -> void:
	splash_screen.hide()
	_start_card_playing_phase(BattleManager.COMBATRESULT.UNDECIDED)


func _on_reward_card_selected(card: CardData) -> void:
	Global.deck.append(card)

	Global.currentLevel.completed = true
	Global.currentLevel = null
	get_tree().change_scene_to_file("res://levelSelectScene.tscn")



# Game Flow Management

func _start_card_playing_phase(result: BattleManager.COMBATRESULT) -> void:
	if result == BattleManager.COMBATRESULT.WON:
		MusicPlayer.play_sfx(win_sound.sound)
		if Global.currentLevel.type == Level.LevelType.BOSS: # Assumes only one boss level
			MusicPlayer.instance.sfx_finished.connect(func ():
				get_tree().change_scene_to_file("res://endScene.tscn")
			)
		else:
			reward_screen.show_rewards()
	elif result == BattleManager.COMBATRESULT.LOST:
		MusicPlayer.play_sfx(loose_sound.sound)
		lose_screen.show()
	else:
		await card_manager.draw_cards(6)
		start_fight_button.set_disabled(false)


func _start_autobattler() -> void:
	start_fight_button.set_disabled(true)
	ui_manager.on_latex_exited()
	await card_manager.discard_hand()
	battle_manager.start_combat(BattlefieldManager.allies, BattlefieldManager.enemies)

func _process(_delta: float) -> void:
	ui_manager.update_ui(get_global_mouse_position())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		handle_card_release()

# Game Logic
func handle_card_release() -> void:
	var card := ui_manager.current_card
	if card == null:
		return
	var creature_trigger := ui_manager.mouse_inside_creature_area
	var spell_trigger := ui_manager.mouse_inside_spell_area
	ui_manager.reset_card()
	if creature_trigger:
		await card_manager.play_card(card, Playtype.CREATURE)
	elif spell_trigger:
		await card_manager.play_card(card, Playtype.SPELL)

enum Playtype {
	CREATURE = 1,
	SPELL = 2
}
