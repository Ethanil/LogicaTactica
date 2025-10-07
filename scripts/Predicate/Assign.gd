class_name Assign
extends Expr

@export var target: PredicateFunc
@export var expr: Expr


func _init(_target:PredicateFunc = null, _expr:Expr = null):
	if _target != null:
		target = _target
	if _expr != null:
		expr = _expr

func type():
	return Expr.ASSIGN
