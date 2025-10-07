extends Resource
class_name Expr

func type():
	return Expr.EXPR

enum {
	EXPR, 
	VAR, 
	CONST, 
	PREDICATEFUNC, 
	EQUALS, 
	NOTEQUALS, 
	GREATERTHAN, 
	GREATEREQUAL, 
	LESSTHAN, 
	LESSEQUAL, 
	IMPLIES, 
	AND, 
	OR, 
	NOT, 
	ASSIGN, 
	FORALL, 
	EXISTS,
	
	UNION, 
	INTERSECTION, 
	PLUS,
	MINUS,
	MULT,
	DIV
	}
