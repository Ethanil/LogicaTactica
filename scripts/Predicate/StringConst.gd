class_name StringConst
extends Expr

@export var value:String

func _init(_value:String = ""):
	if _value != "":
		value = _value

func type():
	return Expr.CONST
