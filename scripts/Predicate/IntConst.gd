class_name IntConst
extends Expr

@export var value: int

func _init(_value:int = 0):
	if _value != 0:
		value = _value

func type():
	return Expr.CONST
