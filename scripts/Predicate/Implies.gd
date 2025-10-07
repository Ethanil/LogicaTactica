class_name Implies
extends Expr

@export var premise:Expr
@export var conclusion:Expr

func _init(_premise:Expr = null, _conclusion:Expr = null):
	if _premise != null:
		premise = _premise
	if _conclusion != null:
		conclusion = _conclusion


func type():
	return Expr.IMPLIES
