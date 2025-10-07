class_name Var
extends Expr

@export var name: String

func _init(_name: String = ""):
	if _name != "":
		name = _name


func type():
	return Expr.VAR
