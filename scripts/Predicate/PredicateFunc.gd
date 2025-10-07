class_name PredicateFunc
extends Expr

@export var name: String
@export var args: Array[Expr]

func _init(_name: String = "", _args: Array[Expr]= []):
	if _name != "":
		name = _name
	if _args != []:
		args = _args


func type():
	return Expr.PREDICATEFUNC
