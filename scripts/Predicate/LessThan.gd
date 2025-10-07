class_name LessThan
extends Expr

@export var left:Expr
@export var right:Expr

func _init(_left:Expr = null, _right:Expr = null):
	if _left != null:
		left = _left
	if _right != null:
		right = _right


func type():
	return Expr.LESSTHAN
