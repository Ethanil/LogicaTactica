extends Resource
class_name CardData

@export var creature_cond_expr: Expr
@export var creature_effect_expr: Expr
@export var spell_cond_expr: Expr
@export var spell_effect_expr: Expr

enum CardType { BASIC, ADVANCED }
@export var card_type: CardType = CardType.BASIC

@export var amount_of_repetitions: int = 2


@export var creature_effect_play_sound: AudioAssetWithMetadata
@export var spell_effect_play_sound: AudioAssetWithMetadata
