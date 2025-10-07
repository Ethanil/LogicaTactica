class_name Not
extends Expr

@export var expr:Expr

func _init(_expr = null):
	if _expr!= null:
		expr = _expr


func type():
	return Expr.NOT
