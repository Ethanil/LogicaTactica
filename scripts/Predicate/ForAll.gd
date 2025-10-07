class_name ForAll
extends Expr

@export var varname: String
@export var domain: Expr
@export var body: Expr

func _init(_varname:String = "", _domain:Expr = null, _body:Expr = null):
	if _varname != "":
		varname = _varname
	if _domain != null:
		domain = _domain
	if _body != null:
		body = _body

func type():
	return Expr.FORALL
